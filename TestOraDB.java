import java.sql.*;
import java.time.Duration;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

public class TestOraDB {

    // --- Oracle connection parameters (match your Go defaults) ---
    private static final String ORA_HOST = env("ORA_HOST", "localhost");
    private static final String ORA_PORT = env("ORA_PORT", "1521");
    private static final String ORA_SERVICE = env("ORA_SERVICE", "MYORADB1");
    private static final String ORA_USER = env("ORA_USER", "MY_USER");
    private static final String ORA_PWD = env("ORA_PWD", "My_Password123!");

    // JDBC URL (Oracle Thin)
    // Service-name form:
    // jdbc:oracle:thin:@//host:port/service
    private static String jdbcUrl() {
        return String.format("jdbc:oracle:thin:@//%s:%s/%s", ORA_HOST, ORA_PORT, ORA_SERVICE);
    }

    private static final String CREATE_TABLE =
            "CREATE TABLE TEST101 (ID VARCHAR2(100) PRIMARY KEY, AN_INT NUMBER(5))";
    private static final String INSERT_SQL =
            "INSERT INTO TEST101 (ID, AN_INT) VALUES (?, ?)";
    private static final String SELECT_SQL =
            "SELECT ID, AN_INT FROM TEST101";
    private static final String DROP_TABLE =
            "DROP TABLE TEST101";

    private static final int ROWS_TO_CREATE = Integer.parseInt(env("ROWS_TO_CREATE", "1000"));
    private static final boolean PRINT_ROWS = Boolean.parseBoolean(env("PRINT_ROWS", "false"));

    public static void main(String[] args) throws Exception {
        long start = System.nanoTime();

        System.out.println(">>>>>>>>>>>>>>>>>> Connecting to local Oracle Database");

        long t0 = System.nanoTime();
        try (Connection conn = DriverManager.getConnection(jdbcUrl(), ORA_USER, ORA_PWD)) {
            long timeToConnect = since(t0);
            System.out.println(">>>>>>>>>>>>>>>>>> Doing some DB stuff");
            long timeToCreateTable = time(createTable(conn));
            long timeToInsert = time(inserts(conn, ROWS_TO_CREATE));
            SelectResult sel = selects(conn, PRINT_ROWS);
            long timeToSelect = sel.durationMs();
            long timeToDrop = time(drop(conn));

            System.out.println("Time to connect:  " + timeToConnect + " ms");
            System.out.println("Time to create table:  " + timeToCreateTable + " ms");
            System.out.println("Time to insert " + ROWS_TO_CREATE + " rows: " + timeToInsert + " ms");
            System.out.println("Time to select " + ROWS_TO_CREATE + " rows: " + timeToSelect +
                    " ms with a total value of " + sel.total());
            System.out.println("Time to drop table:  " + timeToDrop + " ms");
            System.out.println("Total runtime:  " + since(start) + " ms");        }
    }

    private static TimedOp createTable(Connection conn) {
        return () -> {
            System.out.println("Create a table");
            try (Statement st = conn.createStatement()) {
                st.execute(CREATE_TABLE);
            } catch (SQLException e) {
                // Mimic Go behavior: ignore "name already used" error
                // ORA-00955: name is already used by an existing object
                if (!containsOraCode(e, 955) && !messageContains(e, "ORA-00955")) {
                    throw e;
                }
            }
        };
    }

    private static TimedOp inserts(Connection conn, int rowsToCreate) {
        return () -> {
            System.out.println("Create some data");
            try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL)) {
                for (int i = 0; i < rowsToCreate; i++) {
                    String id = UUID.randomUUID().toString();
                    int randomInt = ThreadLocalRandom.current().nextInt(100_000);
                    ps.setString(1, id);
                    ps.setInt(2, randomInt);
                    ps.executeUpdate();
                }
            }
            System.out.println(rowsToCreate + " random rows inserted successfully!");
        };
    }

    private static SelectResult selects(Connection conn, boolean print) throws SQLException {
        long t = System.nanoTime();
        long total = 0;

        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(SELECT_SQL)) {

            if (print) {
                System.out.println("Rows in table TEST101:");
            }

            while (rs.next()) {
                String id = rs.getString(1);
                int anInt = rs.getInt(2);

                if (print) {
                    System.out.println("ID: " + id + ", AN_INT: " + anInt);
                }
                total += anInt;
            }
        }

        return new SelectResult(since(t), total);
    }

    private static TimedOp drop(Connection conn) {
        return () -> {
            System.out.println("Drop a table");
            try (Statement st = conn.createStatement()) {
                st.execute(DROP_TABLE);
            }
        };
    }

    // --- Timing helpers ---

    @FunctionalInterface
    private interface TimedOp {
        void run() throws SQLException;
    }

    private static long time(TimedOp op) throws SQLException {
        long t = System.nanoTime();
        op.run();
        return since(t);
    }

    private static long since(long nanoStart) {
//        return Duration.ofNanos(System.nanoTime() - nanoStart);
        return (System.nanoTime() - nanoStart) / 1_000_000;
    }

    private record SelectResult(long durationMs, long total) {}

    // --- Error helpers ---

    private static boolean containsOraCode(SQLException e, int oraCode) {
        for (Throwable t = e; t != null; t = (t instanceof SQLException se) ? se.getNextException() : null) {
            if (t instanceof SQLException se && se.getErrorCode() == oraCode) {
                return true;
            }
        }
        return false;
    }

    private static boolean messageContains(SQLException e, String token) {
        String m = e.getMessage();
        return m != null && m.contains(token);
    }

    private static String env(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isBlank()) ? def : v;
    }
}