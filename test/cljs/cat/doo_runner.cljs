(ns cat.doo-runner
  (:require [doo.runner :refer-macros [doo-tests]]
            [cat.core-test]))

(doo-tests 'cat.core-test)

