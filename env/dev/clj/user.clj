(ns user
  (:require [cat.config :refer [env]]
            [clojure.spec.alpha :as s]
            [expound.alpha :as expound]
            [mount.core :as mount]
            [cat.figwheel :refer [start-fw stop-fw cljs]]
            [cat.core :refer [start-app]]
            [cat.db.core]
            [conman.core :as conman]
            [luminus-migrations.core :as migrations]))

(alter-var-root #'s/*explain-out* (constantly expound/printer))

(defn start []
  (mount/start-without #'cat.core/repl-server))

(defn stop []
  (mount/stop-except #'cat.core/repl-server))

(defn restart []
  (stop)
  (start))

(defn restart-db []
  (mount/stop #'cat.db.core/*db*)
  (mount/start #'cat.db.core/*db*)
  (binding [*ns* 'cat.db.core]
    (conman/bind-connection cat.db.core/*db* "sql/queries.sql")))

(defn reset-db []
  (migrations/migrate ["reset"] (select-keys env [:database-url])))

(defn migrate []
  (migrations/migrate ["migrate"] (select-keys env [:database-url])))

(defn rollback []
  (migrations/migrate ["rollback"] (select-keys env [:database-url])))

(defn create-migration [name]
  (migrations/create name (select-keys env [:database-url])))


