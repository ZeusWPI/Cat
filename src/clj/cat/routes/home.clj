(ns cat.routes.home
  (:require [cat.layout :as layout]
            [cat.db.core :refer [*db*] :as db]
            [compojure.core :refer [defroutes GET POST]]
            [ring.util.http-response :as response]
            [clojure.java.io :as io]
            [struct.core :as st]
            [clojure.edn :as edn]
            [clojure.tools.logging :as log]
            [clojure.data.json :as json]
            [oauth.client :as oauth]))

(def user-schema
  [[:name st/required st/string]
   [:gender st/string]])

(def relation-schema
  [[:from_id st/required st/integer-str]
   [:to_id st/required st/integer-str]])

(defn home-page [params]
  (layout/render "home.html" params))

(defn get-relations []
  (map
    (fn [relation] (select-keys relation [:name :name_2]))
    (db/get-relations)))

(defn get-users []
  (db/get-users))

(defroutes home-routes
           (GET "/" req
             (let [users (get-users)
                   relations (get-relations)]
               (log/info (str "Session: " (:session req)))
               (home-page {:relations relations :users users :user (get-in req [:session :user])})))
           ;(GET "/docs" []
           ;  (-> (response/ok (-> "docs/docs.md" io/resource slurp))
           ;      (response/header "Content-Type" "text/plain; charset=utf-8")))
           (GET "/relations" []
             (let []
               (response/ok {})))
           (GET "/relations_zeroed" []
             (let [users (db/get-users)
                   relations (db/get-relations)
                   used-node-ids (set (flatten (map (fn [ln] [(:from_id ln) (:to_id ln)]) relations)))
                   filtered-users (filter (fn [{id :id}] (contains? used-node-ids id)) users)
                   id-index-map (:map (reduce (fn [{map :map idx :index} usr]
                                                {:map   (assoc map (:id usr) idx)
                                                 :index (inc idx)})
                                              {:map {} :index 0}
                                              filtered-users))
                   rels-indexed (map (fn [{src :from_id target :to_id}]
                                       {:source (get id-index-map src)
                                        :target (get id-index-map target)
                                        :value  (+ 20 (rand-int 30))})
                                     relations)
                   nodes-indexed (->> filtered-users
                                      (map (fn [usr]
                                             (-> usr
                                                 (dissoc :gender :id)
                                                 (assoc :index (get id-index-map (:id usr)))
                                                 (assoc :group (rand-int 5))))))]
               (response/ok {:nodes nodes-indexed
                             :links rels-indexed})))
           (POST "/relations" req
             (let [data (:params req) [err result] (st/validate data relation-schema)]
               (log/info "Post to " (:uri req))
               (if (nil? err)
                 (do
                   (db/create-relation! result)
                   (response/no-content))
                 (do
                   (response/bad-request "Incorrect input")))))
           (POST "/users" req
             (let [data (:params req)]
               (log/info "Post to " (:uri req))
               (println data)
               (if (st/valid? data user-schema)
                 (do
                   (db/create-user! data)
                   (response/no-content))
                 (do
                   (response/bad-request "Incorrect input"))))))





