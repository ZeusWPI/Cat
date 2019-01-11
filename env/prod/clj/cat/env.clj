(ns cat.env
  (:require [clojure.tools.logging :as log]))

(def defaults
  {:init
   (fn []
     (log/info "\n-=[cat started successfully]=-"))
   :stop
   (fn []
     (log/info "\n-=[cat has shut down successfully]=-"))
   :middleware identity})
