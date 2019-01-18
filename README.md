# cat

generated using Luminus version "3.10.29"
init with options: postgres, cljs, auth, oauth, site, kibit


## Prerequisites

You will need [Leiningen][1] 2.0 or above installed.

[1]: https://github.com/technomancy/leiningen


## Development

### Running

Environment variables:

Copy `dev-config.edn_example` to `dev-config.edn` and fill in the needed fields.

Use `test-config.edn` for tests.

Install the needed dependecies

    lein deps

To start the web server for the application, run:

    lein run

To start the clientside server (this watches the cljs files and automatically recompiles on change), run:

    lein figwheel


When making database schema changes, start a repl user environment using
	
    lein repl

You can start the webserver in this repl using

    (start)

Make a new database migration:

    (create-migration "migration name")

Now edit the newly created .sql files.

Run the pending migrations

    (migrate)

Roll back the last set of migrations

    (rollback)

Reset the state of the database

    (reset-db)

Restart the database (this is needed after changes in the sql querries)

    (restart-db)

Note that you can't do this when running the server with `lein run`.
In this case you need to shutdown and restart using run or repl.

You can find these function available in the [userspace definitions][2]

### Notes
#### Database
* ENUM TYPE

    Because of the lack of typing in clojure and the forced typing of the jdbc driver
we need to manually manage conversion of enum types to clojure keywords.

    When adding an enum to the database, make sure to add it to the '+schema-enums+' set [src/clj/cat/db/core.clj]



## Production

	lein uberjar
	
	export DATABASE_URL="jdbc:postgres://localhost:port/dbname?user=username&password=password"
	java -jar target/uberjar/cat.jar


[2]: env/dev/clj/user.clj
