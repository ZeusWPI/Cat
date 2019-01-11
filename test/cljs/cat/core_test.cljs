(ns cat.core-test
  (:require [cljs.test :refer-macros [is are deftest testing use-fixtures]]
            [pjstadig.humane-test-output]
            [cat.core :as rc]))

(deftest test-home
  (is (= true true)))

