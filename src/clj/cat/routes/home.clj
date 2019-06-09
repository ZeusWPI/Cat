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

(def request_relation-schema
  [[:to_id st/required st/integer-str]])

(defn- home-page [params]
  (layout/render "home.html" params))

(defn- get-users []
  (db/get-users))

(defn- response-wrong-parameters []
  (error-page {:status  400
               :title   "Wrong request parameters"
               :message "Please contact your system administrator to fix this issue"}))

(defn show-home [req]
  (let [users (get-users)
        relations (db/get-relations)
        user (get-in req [:session :user])
        user-relations (when user
                         ;; This can probably be compacted to one reduce operation
                         ;; -> filter for only our relations, remove our name
                         (->> relations
                              (filter (fn [rel]
                                        (or
                                         (= (:from_name rel) (:name user))
                                         (= (:to_name rel) (:name user)))))
                              (map (fn [rel] (if (= (:from_name rel) (:name user))
                                               (-> rel
                                                   (assoc :other_name (:to_name rel))
                                                   (assoc :other_id (:to_id rel)))
                                               (-> rel
                                                   (assoc :other_name (:from_name rel))
                                                   (assoc :other_id (:from_id rel))))))))
        other_users (when user
                      (filter (fn [usr] (not (= (:id usr) (:id user))))
                              users))
        rel-requests-out (db/get-relation-requests-from-user {:from_id (:id user)})
        rel-requests-in (db/get-relation-requests-to-user {:to_id (:id user)})
        ;; This can be done in one SQL query but since we already have the data for the other operations...
        non_connected_users (filter (fn [other_user] (not (some (partial = (:id other_user))
                                                                (concat
                                                                 (map :from_id rel-requests-in)
                                                                 (map :to_id rel-requests-out)
                                                                 (map :other_id user-relations)))))
                                    other_users)]
    (log/debug (str "Session: " (:session req)))
    (home-page {:relations        relations
                :users            users
                :user             user
                :user-relations   user-relations
                :rel-requests-out rel-requests-out
                :rel-requests-in  rel-requests-in
                :non_connected_users non_connected_users
                :flash            (:flash req)})))

(defn show-relations
  []
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

(defn update-relationrequest-status
  "Updates the status of a relationship request"
  [id body {:keys [:session]}]
  (let [rr (db/get-relation-request {:id id})]
      ; Check that you are authorized to change this request
    (if-not (= (:to_id rr) (get-in session [:user :id]))
      (response/unauthorized "You can only update requests send to you")
      (if-not (= "open" (:status rr))
        (response/gone "Request is not open anymore")
        (let [correct-params?
              (cond
                (contains? body :accept)
                (do
                  (db/create-relation! (select-keys rr [:from_id :to_id]))
                  (db/update-relation-request-status! {:id id :status "accepted"}))
                (contains? body :decline)
                (db/update-relation-request-status! {:id id :status "declined"})
                :else false)]
          (if correct-params?
            (response/found "/")
            (response-wrong-parameters)))))))

(defn create-relation-request
  "Creates a new request, as requests are unidirectional,
  this gets denied if there is a request pending or a relation already established"
  [{:keys [:params :session :uri]}]
  (let [[err result] (st/validate params request_relation-schema)
        from_id (get-in session [:user :id])
        to_id (:to_id result)]
    (if (= from_id to_id)
      (response/unprocessable-entity "Sadly enough, you can't hug yourself :'(")
      (if-not (nil? err)
        (response/unprocessable-entity "Incorrect input")
        (let [count (db/get-connection-existence {:user_id from_id :other_id to_id})]
          (if-not (= 0 (:count count))
            (do
              (log/info "Existing connections found, aborting.")
              (response/conflict "There is already a request or relation between you and the other user"))
            (do
              (log/debug "Create relation request")
              (db/create-relation-request! {:from_id from_id
                                            :to_id   to_id
                                            :status  "open"})
              (response/found "/"))))))))
