(ns cat.handler
  (:require [cat.middleware :as middleware]
            [cat.layout :refer [error-page]]
            [cat.routes.home :refer [show-home show-relations update-relationrequest-status create-relation-request]]
            [cat.routes.oauth :refer [oauth-init oauth-callback clear-session!]]
            [cat.routes.admin :refer [set-admin! create-new-relation! create-user!]]
            [compojure.core :refer [routes defroutes GET POST wrap-routes]]
            [ring.util.http-response :as response]
            [compojure.route :as route]
            [cat.env :refer [defaults]]
            [clojure.tools.logging :as log]
            [mount.core :as mount]))

(mount/defstate init-app
  :start ((or (:init defaults) identity))
  :stop ((or (:stop defaults) identity)))

(defroutes public-routes
  (GET "/" req (show-home req))
  (GET "/relations_zeroed" [] (show-relations)))

(defroutes user-routes ;; These are protect inside their respective functions
  (POST "/relation_request/:id/status" [id & body :as req] (update-relationrequest-status id body req)) ; STATUS ENUM: (open, accepted, rejected)
  (POST "/request_relation" req (create-relation-request req)))

(defroutes oauth-routes
  (GET "/oauth/oauth-init" req (oauth-init req))
  (GET "/oauth/oauth-callback" req (oauth-callback req))
  (GET "/logout" req (clear-session! "/")))

(defroutes admin-routes
  (GET "/admin/enable" req (set-admin! req true))
  (GET "/admin/disable" req (set-admin! req false))
  (POST "/relations" req (create-new-relation! req))
  (POST "/users" req (create-user! req)))

(defroutes app-routes
  (-> public-routes
      middleware/wrap-csrf
      middleware/wrap-formats)
  user-routes
  oauth-routes
  (-> admin-routes
      middleware/wrap-restricted-admin)
  (route/not-found
   (:body
    (error-page {:status 404
                 :title  "page not found"}))))

(mount/defstate app
  :start
  (-> app-routes
      middleware/wrap-base))
