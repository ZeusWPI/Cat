(ns cat.oauth
  (:require [cat.config :refer [env]]
            [oauth.client :as oauth]
            [mount.core :refer [defstate]]
            [clojure.tools.logging :as log]))

(defstate consumer
          :start (oauth/make-consumer
                   (env :oauth-consumer-key)
                   (env :oauth-consumer-secret)
                   (env :request-token-uri)
                   (env :access-token-uri)
                   (env :authorize-uri)
                   :hmac-sha1))

(defn oauth-callback-uri
  "Generates the oauth request callback URI"
  [{:keys [headers]}]
  (let [callback-url (str "http://" (headers "host") "/oauth/oauth-callback")]
    (println "Generated callback url:" callback-url)
    callback-url))

(defn fetch-request-token
  "Fetches a request token."
  [request]
  (let [callback-uri (oauth-callback-uri request)]
    (log/info "Fetching request token using callback-uri" callback-uri)
    (log/info "Oauth consumer: " consumer)
    (oauth/request-token consumer callback-uri {:grant_type "authorization_code"})))

(defn fetch-access-token
  [request_token]
  (oauth/access-token consumer request_token (:oauth_verifier request_token)))

(defn auth-redirect-uri
  "Gets the URI the user should be redirected to when authenticating."
  ([request]
   (auth-redirect-uri request ""))
  ([request request-token]
   (str (oauth/user-approval-uri consumer request-token {:response_type "code"
                                                         :client_id     (env :oauth-consumer-key)
                                                         :redirect_uri (oauth-callback-uri request)}))))