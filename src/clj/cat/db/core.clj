(ns cat.db.core
  (:require
    [clj-time.jdbc]
    [clojure.java.jdbc :as jdbc]
    [clojure.tools.logging :as log]
    [conman.core :as conman]
    [java-time.pre-java8 :as jt]
    [cat.config :refer [env]]
    [mount.core :refer [defstate]]
    [clojure.string :as s])
  (:import [java.sql
            BatchUpdateException
            PreparedStatement]))

(defstate ^:dynamic *db*
          :start (if-let [jdbc-url (env :database-url)]
                   (conman/connect! {:jdbc-url jdbc-url})
                   (do
                     (log/warn "database connection URL was not found, please set :database-url in your config, e.g: dev-config.edn")
                     *db*))
          :stop (conman/disconnect! *db*))

(conman/bind-connection *db* "sql/queries.sql")


(extend-protocol jdbc/IResultSetReadColumn
  java.sql.Timestamp
  (result-set-read-column [v _2 _3]
    (.toLocalDateTime v))
  java.sql.Date
  (result-set-read-column [v _2 _3]
    (.toLocalDate v))
  java.sql.Time
  (result-set-read-column [v _2 _3]
    (.toLocalTime v)))

(extend-protocol jdbc/ISQLValue
  java.util.Date
  (sql-value [v]
    (java.sql.Timestamp. (.getTime v)))
  java.time.LocalTime
  (sql-value [v]
    (jt/sql-time v))
  java.time.LocalDate
  (sql-value [v]
    (jt/sql-date v))
  java.time.LocalDateTime
  (sql-value [v]
    (jt/sql-timestamp v))
  java.time.ZonedDateTime
  (sql-value [v]
    (jt/sql-timestamp v)))