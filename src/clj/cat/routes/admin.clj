(ns cat.routes.admin
  (:require [cat.db.core :refer [*db*] :as db]
            [compojure.core :refer [defroutes GET POST]]
            [struct.core :as st]
            [clojure.tools.logging :as log]
            [ring.util.http-response :as response]))

(def user-schema
  [[:name st/required st/string]
   [:gender st/string]])

(def relation-schema
  [[:from_id st/required st/integer-str]
   [:to_id st/required st/integer-str]])

(defroutes admin-routes
           (GET "/admin/enable" req (-> (response/found "/")
                                        (assoc :session (assoc-in (:session req) [:user :admin :enabled] true))))
           (GET "/admin/disable" req (-> (response/found "/")
                                         (assoc :session (assoc-in (:session req) [:user :admin :enabled] false))))

           (POST "/relations" req
                 (let [data (:params req) [err result] (st/validate data relation-schema)]
                   (log/info "Post to " (:uri req))
                   (if (nil? err)
                     (do
                       (db/create-relation! result)
                       (response/found "/"))
                     (do
                       (response/bad-request "Incorrect input")))))
           (POST "/users" req
                 (let [data (:params req)]
                   (log/info "Post to " (:uri req))
                   (println data)
                   (if (st/valid? data user-schema)
                     (do
                       (db/create-user! (assoc data :zeusid nil))
                       (response/found "/"))
                     (do
                       (response/bad-request "Incorrect input")))))
           )