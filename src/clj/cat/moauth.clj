(ns cat.moauth
  (:require [cat.config :refer [env]]
            [clj-http.client :as httpclient]
            [slingshot.slingshot :refer [try+]]
            [clojure.tools.logging :as log]
            [cat.layout :refer [error-page]]))

; Inspired by https://leonid.shevtsov.me/post/oauth2-is-easy/

(defn- oauth2-params []
  {:client-id        (env :oauth-consumer-key)
   :client-secret    (env :oauth-consumer-secret)
   :authorize-uri    (env :authorize-uri)
   :redirect-uri     (str (env :app-host) "/oauth/oauth-callback")
   :access-token-uri (env :access-token-uri)
   })

; To authorize, redirect the user to the sign in / grant page

(defn- authorize-uri
  [client-params #_csrf-token]
  (str
    (:authorize-uri client-params)
    "?"
    (httpclient/generate-query-string {:response_type "code"
                                       :client_id     (:client-id client-params)
                                       :redirect_uri  (:redirect-uri client-params)})
    ;"response_type=code"
    ;"&client_id="
    ;(url-encode (:client-id client-params))
    ;"&redirect_uri="
    ;(url-encode (:redirect-uri client-params))
    ;"&scope="
    ;(url-encode (:scope client-params))
    ;"&state="
    ;(url-encode csrf-token)
    ))

(defn authorize-api-uri
  "let the user authorize access by redirecting to the signin / grant page
 of the used oauth api"
  []
;  (log/info "Oauth params: " (oauth2-params))
  (authorize-uri (oauth2-params)))

(defn get-authentication-response
  "Request an access token with the obtained unique code from the grant page"
  [csrf-token {:keys [state code]}]
  (if (or true (= csrf-token state))
    (try
      (do
        (log/debug "Requesting access token with code " code)
        (let [oauth2-params (oauth2-params)
              access-token (httpclient/post (:access-token-uri oauth2-params)
                                            {:form-params {:code          code
                                                           :grant_type    "authorization_code"
                                                           :client_id     (:client-id oauth2-params)
                                                           :client_secret (:client-secret oauth2-params)
                                                           :redirect_uri  (:redirect-uri oauth2-params)}
                                             ;:basic-auth  [(:client-id oauth2-params) (:client-secret oauth2-params)]
                                             :as          :json
                                             :insecure? true
                                             })]
          (println "Access token response:" access-token)
          (:body access-token)))
      (catch Exception e (log/error "Something terrible happened..." e)))
    nil))

(defn get-user-info
  "User info API call"
  [access-token]
  (let [url (str (env :user-api-uri))]
    (-> (httpclient/get url {:oauth-token access-token
                             :as          :json
                             :insecure? true})
        :body)
    ))

; Refresh token when it expires
(defn- refresh-tokens
  "Request a new token pair"
  [refresh-token]
  (try+
    (let [oauth2-params (oauth2-params)
          {{access-token :access_token refresh-token :refresh_token} :body}
          (httpclient/post (:access-token-uri oauth2-params)
                           {:form-params {:grant_type    "refresh_token"
                                          :refresh_token refresh-token}
                            :basic-auth  [(:client-id oauth2-params) (:client-secret oauth2-params)]
                            :as          :json
                            :insecure? true})]
      [access-token refresh-token])
    (catch [:status 401] _ nil)))

(defn get-fresh-tokens
  "Returns current token pair if they have not expired, or a refreshed token pair otherwise"
  [access-token refresh-token]
  (try+
    (and (get-user-info access-token)
         [access-token refresh-token])
    (catch [:status 401] _ (refresh-tokens refresh-token))))

