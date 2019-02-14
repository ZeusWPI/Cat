(ns cat.routes.oauth
  (:require [ring.util.http-response :refer [ok found]]
            [compojure.core :refer [defroutes GET]]
            [clojure.tools.logging :as log]
            [cat.moauth :as mo]
            [cat.db.core :refer [*db*] :as db]))

(def admins #{10                                             ;flynn
              })

(defn set-user! [user session redirect-url]
  (log/info "Set user in session: " user)
  (let [new-session (-> session
                        (assoc :user user)
                        (cond-> (contains? admins (:id user))
                                (->
                                  (assoc-in [:user :admin] {:enabled false})
                                  (assoc :identity "foo"))))]
    (-> (found redirect-url)
        (assoc :session new-session))))

(defn remove-user! [session redirect-url]
  (-> (found redirect-url)
      (assoc :session (dissoc session :user))))

(defn clear-session! [redirect-url]
  (-> (found redirect-url)
      (assoc :session nil)))

(defn oauth-init
  "Initiates the Twitter OAuth"
  [request]
  (let [reee (mo/authorize-api-uri)]
    (log/info "authorize uri: " reee)
    (-> reee
        found)))

(defn oauth-callback
  "Handles the callback from adams with the access_token
   Fetches the user from the database, creating a new one if not found
   Sets the user in the session and redirects back to origin \"/\" "
  [req_token {:keys [params session]}]
  ; oauth request was denied by user
  (if (:denied params)
    (-> (found "/")
        (assoc :flash {:denied true}))
    ; fetch the request token and do anything else you wanna do if not denied.
    (let [{:keys [access_token refresh_token]} (mo/get-authentication-response nil req_token)]
      (log/info "Successfully fetched access-id: " access_token)
      (log/info "Fetching user info")
      (let [user (mo/get-user-info access_token)]
        (log/info "User info: " user)
        (let [zeususer (db/get-zeus-user {:zeusid (:id user)})]
          (log/info "Zeus user from db: " zeususer)
          (if zeususer
            (set-user! zeususer session "/")
            (let [user-template {:name   (:username user)
                                 :gender nil
                                 :zeusid (:id user)}
                  generated-key (-> user-template
                                    (db/create-user!,,,))]
              (log/info "Created user: " generated-key)
              (set-user! (assoc user-template :id (:generated_key generated-key)) session "/"))))))))

;(catch [:status 401] _
;             (error-page {:status 401
;                          :title "Error authenticating"
;                          :message "Please contact your system administrator to fix this issue"}))


(defroutes oauth-routes
           (GET "/oauth/oauth-init" req (oauth-init req))
           (GET "/oauth/oauth-callback" [& req_token :as req] (oauth-callback req_token req))
           (GET "/logout" req (clear-session! "/")))

(defroutes admin-routes
           (GET "/admin/enable" req (-> (found "/")
                                        (assoc :session (assoc-in (:session req) [:user :admin :enabled] true))))
           (GET "/admin/disable" req (-> (found "/")
                                         (assoc :session (assoc-in (:session req) [:user :admin :enabled] false)))))