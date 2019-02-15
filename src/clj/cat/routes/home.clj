(ns cat.routes.home
  (:require [cat.layout :as layout]
            [cat.config :refer [env]]
            [cat.db.core :refer [*db*] :as db]
            [compojure.core :refer [defroutes GET POST]]
            [ring.util.http-response :as response]
            [struct.core :as st]
            [clojure.tools.logging :as log]
            [cat.layout :refer [error-page]]
            [clojure.string :as s]))

(def user-schema
  [[:name st/required st/string]
   [:gender st/string]])

(def relation-schema
  [[:from_id st/required st/integer-str]
   [:to_id st/required st/integer-str]])

(def request_relation-schema
  [[:to_id st/required st/integer-str]])

(defn home-page [params]
  (layout/render "home.html" params))

(defn get-relations []
  (map
    (fn [relation] (select-keys relation [:name :name_2]))
    (db/get-relations)))

(defn get-users []
  (db/get-users))

(defn response-wrong-parameters []
  (error-page {:status  400
               :title   "Wrong request parameters"
               :message "Please contact your system administrator to fix this issue"}))

(defroutes home-routes
           (GET "/" req
             (let [users (get-users)
                   relations (get-relations)
                   user (-> (get-in req [:session :user]))
                   user-relations (when user
                                    (seq (filter (fn [rel]
                                                   (or
                                                     (= (:name rel) (:name user))
                                                     (= (:name_2 rel) (:name user))))
                                                 relations)))
                   other_users (when user
                                 (seq (filter (fn [usr] (not (= (:id usr) (:id user))))
                                              users)))
                   rel-requests-out (seq (db/get-relation-requests-from-user {:from_id (:id user)}))
                   rel-requests-in (seq (db/get-relation-requests-to-user {:to_id (:id user)}))
                   non_requested_users (seq (filter (fn [other-user] (not (some (partial = (:id other-user)) (map :to_id rel-requests-out)))) other_users))]
               (log/info (str "Session: " (:session req)))
               ;(log/info (str "Relation requests: \n OUTGOING: " rel-requests-out "\n INCOMING: " rel-requests-in))
               ;(log/info (str "User relations: " user-relations))
               ;(log/info (str "Other Users: " other_users))
               ;(log/info (str "rel reqs out: " rel-requests-out))
               ;(log/info (str "rel reqs out id: " (seq (map :to_id rel-requests-out))))
               (home-page {:relations        relations
                           :users            users
                           :user             user
                           :user-relations   user-relations
                           :rel-requests-out rel-requests-out
                           :rel-requests-in  rel-requests-in
                           :non_requested_users non_requested_users
                           :flash            (:flash req)})))
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

           ; TODO make next 2 user protected
           (POST "/relation_request/:id/status" [id & body]
             (let [rr_id_map {:id id}
                   success (cond
                             (contains? body :accept) (do
                                                        (let [rr (db/get-relation-request rr_id_map)]
                                                          (db/create-relation! {:from_id (:from_id rr) :to_id (:to_id rr)}))
                                                        (db/update-relation-request-status! (assoc rr_id_map :status "accepted")))
                             (contains? body :decline) (db/update-relation-request-status! (assoc rr_id_map :status "declined"))
                             :else false)]
               (if success
                 (response/found "/")
                 (response-wrong-parameters))))
           ; STATUS ENUM: (open, accepted, rejected)
           (POST "/request_relation" req
             (let [data (:params req)
                   [err result] (st/validate data request_relation-schema)
                   from-id (get-in req [:session :user :id])]
               (if (nil? from-id) (response/found (error-page
                                                    {:status 400
                                                     :title  "No user id found in session"})))
               (log/info "Post to " (:uri req) "\n with data " result)
               (if (nil? err)
                 (do
                   (log/debug "Create relation request")
                   (db/create-relation-request! {:from_id from-id
                                                 :to_id   (:to_id result)
                                                 :status  "open"})
                   (response/found "/"))
                 (do
                   (log/debug "Relation request failed")
                   (log/debug err)
                   (response/unprocessable-entity "Incorrect input")))))

           ; TODO make bottom 2 admin protected
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
                   (response/bad-request "Incorrect input"))))))





