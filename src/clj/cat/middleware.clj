(ns cat.middleware
  (:require [cat.env :refer [defaults]]
            [cheshire.generate :as cheshire]
            [cognitect.transit :as transit]
            [clojure.tools.logging :as log]
            [cat.layout :refer [error-page]]
            [ring.middleware.anti-forgery :refer [wrap-anti-forgery]]
            [ring.middleware.webjars :refer [wrap-webjars]]
            [cat.middleware.formats :as formats]
            [muuntaja.middleware :refer [wrap-format wrap-params]]
            [cat.config :refer [env]]
            [ring.middleware.flash :refer [wrap-flash]]
            [immutant.web.middleware :refer [wrap-session]]
            [ring.middleware.defaults :refer [site-defaults wrap-defaults]]
            [buddy.auth.middleware :refer [wrap-authentication wrap-authorization]]
            [buddy.auth.accessrules :refer [restrict wrap-access-rules]]
            [buddy.auth :refer [authenticated?]]
            [buddy.auth.backends.session :refer [session-backend]])
  (:import))

(defn wrap-internal-error [handler]
  (fn [req]
    (try
      (handler req)
      (catch Throwable t
        (log/error t (.getMessage t))
        (error-page {:status  500
                     :title   "Something very bad has happened!"
                     :message "We've dispatched a team of highly trained gnomes to take care of the problem."})))))

(defn wrap-csrf [handler]
  (wrap-anti-forgery
   handler
   {:error-response
    (error-page
     {:status 403
      :title  "Invalid anti-forgery token"})}))

(defn wrap-formats [handler]
  (let [wrapped (-> handler wrap-params (wrap-format formats/instance))]
    (fn [request]
      ;; disable wrap-formats for websockets
      ;; since they're not compatible with this middleware
      ((if (:websocket? request) handler wrapped) request))))

;; Authentication

(defn admin-access [req]
  (contains? (get-in req [:session :user :roles]) :admin))

(def rules
  "The authentication rules"
  [{:pattern #"^/admin/.*"
             :handler admin-access}
            ; TODO add other auth schemes
            ;{:pattern [#"^/$" #"^/oauth/.*"]
            ; :handler any-access}
            ;{:pattern #"^/.*"
            ; :handler user-access}
            ])

(defn on-auth-error
  [request response]
  (error-page
   {:status 403
    :title  (str "Access to " (:uri request) " is not authorised")}))

(defn wrap-restricted
  "Example of how to wrap a route or handling in an authentication scheme"
  [handler]
  (restrict handler {:handler  authenticated?
                     :on-error on-auth-error}))

(defn wrap-auth
  "Installs the session backend on ring"
  [handler]
  (let [backend (session-backend)]
    (-> handler
        (wrap-authentication backend)
        (wrap-authorization backend))))

(defn wrap-base
  "The all default middleware functions. These get applied to every route."
  [handler]
  (-> ((:middleware defaults) handler)
      wrap-auth
      (wrap-access-rules {:rules rules
                          :on-error on-auth-error})
      wrap-webjars
      wrap-flash
      (wrap-session {:cookie-attrs {:http-only true}})
      (wrap-defaults
       (-> site-defaults
           (assoc-in [:security :anti-forgery] false)
           (dissoc :session)))
      wrap-internal-error))
