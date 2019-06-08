(ns cat.handler
  (:require [cat.middleware :as middleware]
            [cat.layout :refer [error-page]]
            [cat.routes.home :refer [home-routes]]
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
  (-> home-routes
      middleware/wrap-csrf
      middleware/wrap-formats)
  (-> oauth-routes)
  (-> admin-routes
      middleware/wrap-restricted)
  (route/not-found
   (:body
    (error-page {:status 404
                 :title  "page not found"}))))

(mount/defstate app
  :start
  (-> app-routes
      middleware/wrap-base))

