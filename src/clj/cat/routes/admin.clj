(ns cat.routes.admin
  (:require [cat.db.core :refer [*db*] :as db]
            [struct.core :as st]
            [clojure.tools.logging :as log]
            [ring.util.http-response :as response]))

(def user-schema
  [[:name st/required st/string]
   [:gender st/string]])

(def relation-schema
  [[:from_id st/required st/integer-str]
   [:to_id st/required st/integer-str]])

(defn set-admin! [req enabled?]
  (-> (response/found "/")
      (assoc :session (assoc-in (:session req) [:user :admin :enabled] enabled?))))

(defn create-new-relation! [req]
  (let [data (:params req)
        [err result] (st/validate data relation-schema)]
    (if (nil? err)
      (do
        (log/info "Admin creates relation from " (:from_id data) "to" (:to_id data))
        (db/create-relation! result)
        (response/found "/"))
      (do
        (response/bad-request "Incorrect input")))))

(defn create-user! [req]
  (let [data (:params req)]
    (println data)
    (if (st/valid? data user-schema)
      (do
        (log/info "Admin creates user: " (:name data))
        (db/create-user! (assoc data :zeusid nil))
        (response/found "/"))
      (do
        (response/bad-request "Incorrect input")))))
