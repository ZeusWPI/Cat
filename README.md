# cat

generated using Luminus version "3.10.29"
init with options: postgres, cljs, auth, oauth, site, kibit


## Prerequisites

You will need [Leiningen][1] 2.0 or above installed.

[1]: https://github.com/technomancy/leiningen

## Running

Copy `dev-config.edn_example` to `dev-config.edn` and fill in the needed fields

`test-config.edn` is used for test execution.

To start a web server for the application, run:

    lein run

To start the ui live rendering, run:

    lein figwheel

## Development
### Database
* ENUM TYPE

    Because of the lack of typing in clojure and the forced typing of the jdbc driver
we need to manually manage conversion of enum types to clojure keywords.

    When adding an enum to the database, make sure to add it to the '+schema-enums+' set [src/clj/cat/db/core.clj]



## License

Copyright © 2019 FIXME