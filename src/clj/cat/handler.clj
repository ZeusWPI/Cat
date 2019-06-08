(ns cat.handler
  (:require [cat.middleware :as middleware]
            [cat.layout :refer [error-page]]
            [cat.routes.home :refer [home-routes]]
            [cat.routes.oauth :refer [oauth-routes]]
            [cat.routes.admin :refer [admin-routes]]
            [compojure.core :refer [routes wrap-routes]]
            [ring.util.http-response :as response]
            [compojure.route :as route]
            [cat.env :refer [defaults]]
            [mount.core :as mount]))

(mount/defstate init-app
                :start ((or (:init defaults) identity))
                :stop ((or (:stop defaults) identity)))

(mount/defstate app
                :start
                (middleware/wrap-base
                  (routes
                    (-> #'home-routes
                        (wrap-routes middleware/wrap-csrf)
                        (wrap-routes middleware/wrap-formats))
                    #'oauth-routes
                    (-> #'admin-routes
                        (wrap-routes middleware/wrap-restricted))
                    (route/not-found
                      (:body
                        (error-page {:status 404
                                     :title  "page not found"}))))))

