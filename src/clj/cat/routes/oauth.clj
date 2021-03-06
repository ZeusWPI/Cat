(ns cat.routes.oauth
  (:require [ring.util.http-response :refer [ok found]]
            [compojure.core :refer [defroutes GET]]
            [clojure.tools.logging :as log]
            [cat.moauth :as mo]
            [cat.db.core :refer [*db*] :as db]))

; This list contains application admins, they can add non-zeus people and can add relations
; More functionality is planned
(def admins [{:name "flynn" :zeusid 117}])

(defn set-user! [user session redirect-url]
  (log/debug "Set user in session: " user)
  (let [new-session (-> session
                        (assoc :user user)
                        (cond-> (some (partial = (select-keys user [:zeusid :name])) admins)
                          (->
                           (assoc-in [:user :admin] {:enabled false})
                           (assoc-in [:user :roles] #{:admin}))))]
    (-> (found redirect-url)
        (assoc :session new-session))))

(defn remove-user! [session redirect-url]
  (-> (found redirect-url)
      (assoc :session (dissoc session :user))))

(defn clear-session! [redirect-url]
  (-> (found redirect-url)
      (assoc :session nil)))

(defn oauth-init
  "Initiates the OAuth"
  [request]
  (let [reee (mo/authorize-api-uri)]
    (log/debug "authorize uri: " reee)
    (-> reee
        found)))

(defn oauth-callback
  "Handles the callback from adams with the access_token
   Fetches the user from the database, creating a new one if not found
   Sets the user in the session and redirects back to origin \"/\" "

  [{:keys [params session]}]
  ; oauth request was denied by user
  (if (:denied params)
    (-> (found "/")
        (assoc :flash {:denied true}))
    ; fetch the request token and do anything else you wanna do if not denied.
    (let [{:keys [access_token refresh_token]} (mo/get-authentication-response nil params)
          fetched-user (mo/get-user-info access_token)
          local-user (db/get-zeus-user {:zeusid (:id fetched-user)})]
      (if local-user
        (set-user! local-user session "/")
        (try
          (let [user-template {:name   (:username fetched-user)
                               :gender nil
                               :zeusid (:id fetched-user)}
                generated-key (-> user-template
                                  (db/create-user!))]
            (set-user! (assoc user-template :id (:generated_key generated-key)) session "/"))
          (catch Exception e
            (do
              (log/warn "fetched user" fetched-user "already exists, but was not found")
              (log/warn (:cause (Throwable->map e)))
              (-> (found "/")
                  (assoc :flash {:error "An error occurred, please try again."})))))))))
