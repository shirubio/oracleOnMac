package main

import (
	"database/sql"
	"log"
	"math/rand"
	"strings"
	"time"

	"github.com/google/uuid"
	_ "github.com/sijms/go-ora/v2"
)

type OraParams struct {
	host    string
	port    string
	service string
	user    string
	pwd     string
}

var oraDB OraParams

func init() {
	oraDB = OraParams{
		host:    "localhost",
		port:    "1521",
		service: "MYORADB1",
		user:    "MY_USER",
		pwd:     "My_Password1",
	}
	connectStr = "oracle://" + oraDB.user + ":" + oraDB.pwd + "@" + oraDB.host + ":" + oraDB.port + "/" + oraDB.service
}

const createTable = "CREATE TABLE TEST101 (ID VARCHAR2(100) PRIMARY KEY, AN_INT NUMBER(5))"
const insert = "INSERT INTO TEST101 ( ID , AN_INT) VALUES (:uuid_key, :theInt)"
const selectSQL = "SELECT * FROM TEST101"
const dropTable = "DROP TABLE TEST101"
const rowsToCreate = 1000

var connectStr string

func main() {
	log.Println(">>>>>>>>>>>>>>>>>> Connecting to local Oracle Database")

	db, timeToConnect := connect()
	defer func() {
		err := db.Close()
		if err != nil {
			log.Println("Error closing connection: ", err)
		}
	}()

	log.Println(">>>>>>>>>>>>>>>>>> Doing some DB stuff")
	timeToCreateTable := create(db)
	timeToInserts := inserts(db)
	timeToSelect := selects(db)
	timeToDropTable := drop(db)

	log.Println("Time to connect: ", timeToConnect)
	log.Println("Time to create table: ", timeToCreateTable)
	log.Printf("Time to insert %d rows: %v\n", rowsToCreate, timeToInserts)
	log.Printf("Time to select and print %d rows: %v\n", rowsToCreate, timeToSelect)
	log.Println("Time to drop table: ", timeToDropTable)
}

func connect() (*sql.DB, time.Duration) {
	t := time.Now()
	db, err := sql.Open("oracle", connectStr)
	if err != nil {
		log.Fatalf("error connecting to database: %v", err)
	}

	err = db.Ping()
	if err != nil {
		log.Fatalf("error pinging db: %v", err)
	}
	timeToConnect := time.Since(t)
	return db, timeToConnect
}

func create(db *sql.DB) time.Duration {
	log.Println("Create a table")
	t := time.Now()
	_, err := db.Exec(createTable)
	if err != nil && !strings.Contains(err.Error(), "ORA-00955") {
		log.Fatalf("error creating table %v\n", err)
	}
	return time.Since(t)
}

func inserts(db *sql.DB) time.Duration {
	t := time.Now()

	log.Println("Create some data")
	// Prepare the SQL statement
	stmt, err := db.Prepare(insert)
	if err != nil {
		log.Fatalf("Error preparing statement: %v\n", err)
	}
	defer stmt.Close()

	for i := 0; i < rowsToCreate; i++ {
		// Generate random UUID and integer
		uuidValue := uuid.New().String()
		randomInt := rand.Intn(100000) // Random integer between 0 and 99999

		// Execute the insert statement
		_, err = stmt.Exec(uuidValue, randomInt)
		if err != nil {
			log.Fatalf("Error inserting row: %v", err)
		}
	}
	log.Println("1000 random rows inserted successfully!")
	return time.Since(t)
}

func selects(db *sql.DB) time.Duration {
	// Execute the query
	t := time.Now()
	rows, err := db.Query(selectSQL)
	if err != nil {
		log.Fatalf("Error executing SELECT: %v", err)
	}
	defer rows.Close()

	// Iterate through the rows and print each one
	log.Println("Rows in table TEST101:")
	for rows.Next() {
		var id string
		var anInt int
		if err = rows.Scan(&id, &anInt); err != nil {
			log.Fatalf("Error scanning row: %v", err)
		}
		log.Printf("ID: %s, AN_INT: %d\n", id, anInt)
	}

	// Check for any errors after the loop
	if err = rows.Err(); err != nil {
		log.Fatalf("Error reading rows: %v", err)
	}

	return time.Since(t)
}

func drop(db *sql.DB) time.Duration {
	log.Println("Drop a table")
	t := time.Now()
	_, err := db.Exec(dropTable)
	if err != nil {
		log.Fatalf("error dropping table %v\n", err)
	}
	timeToDropTable := time.Since(t)
	return timeToDropTable
}
