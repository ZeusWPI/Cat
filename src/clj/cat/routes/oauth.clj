(ns cat.routes.oauth
  (:require [ring.util.http-response :refer [ok found]]
            [compojure.core :refer [defroutes GET]]
            [clojure.java.io :as io]
            [cat.oauth :as oauth]
            [clojure.tools.logging :as log]
            [cat.moauth :as mo]))

(defn set-user! [user session redirect-url]
  (-> (found redirect-url)
      (assoc :session (assoc session :user user))))

(defn remove-user! [session redirect-url]
  (-> (found redirect-url)
      (assoc :session (dissoc session :user))))

(defn clear-session! [redirect-url]
  (-> (found redirect-url)
      (dissoc :session)))

(defn oauth-init
  "Initiates the Twitter OAuth"
  [request]
  (-> (mo/authorize-api-uri)
      found))

(defn oauth-callback
  "Handles the callback from adams."
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
        (set-user! user session "/")))))

;(catch [:status 401] _
;             (error-page {:status 401
;                          :title "Error authenticating"
;                          :message "Please contact your system administrator to fix this issue"}))


(defroutes oauth-routes
           (GET "/oauth/oauth-init" req (oauth-init req))
           (GET "/oauth/oauth-callback" [& req_token :as req] (oauth-callback req_token req))
           (GET "/logout" req (remove-user! (:session req) "/")))