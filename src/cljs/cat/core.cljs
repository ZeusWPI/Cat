(ns cat.core
  (:require [vega-tools.core :refer [validate-and-parse]]
            [promesa.core :as p]))


;(defn ^:export main []
;  (println "This is the main function.")
;  (let [spec {:width 200 :height 200
;              :marks [{:type "symbol"
;                       :properties {:enter {:size {:value 1000}
;                                            :x {:value 100}
;                                            :y {:value 100}
;                                            :shape {:value "circle"}
;                                            :stroke {:value "red"}}}}]}]
;    (-> (validate-and-parse spec)
;        (p/catch #(js/alert (str "Unable to parse spec:\n\n" %)))
;        (p/then #(-> (% {:el (js/document.getElementById "#chart")})
;                     (.update))))))


;(defn on-js-reload []
;  (println "This is the on-js-reload function.")
;  (main))

(defn mount-components []
  (let [spec {:width   700 :height 500
              :signals [{:name "cx"}]
              :marks   [{:name       "nodes"
                         :type       "symbol"
                         :properties {:enter {:size   {:value 1000}
                                              :x      {:value 100}
                                              :y      {:value 100}
                                              :shape  {:value "circle"}
                                              :stroke {:value "red"}}}}]}
        nodespec {;:$schema "https://vega.github.io/schema/vega/v4.json",
                  :width    700,
                  :height   500,
                  :padding  0,
                  :autosize "none",
                  :signals  [{:name "cx", :update "width / 2"}
                             {:name "cy", :update "height / 2"}
                             {:name "nodeRadius", :value 8,
                              :bind {:input "range",
                                     :min   1,
                                     :max   50,
                                     :step  1}}
                             {:name "nodeCharge", :value -30,
                              :bind {:input "range",
                                     :min   -100,
                                     :max   10,
                                     :step  1}}
                             {:name "linkDistance", :value 30,
                              :bind {:input "range",
                                     :min   5,
                                     :max   100,
                                     :step  1}}
                             {:name "static", :value true,
                              :bind {:input "checkbox"}}
                             ;{:description
                             ;       "State variable for active node fix status.",
                             ; :name "fix", :value false,
                             ; :on   [{:events "symbol:mouseout[!event.buttons], window:mouseup",
                             ;         :update "false"}
                             ;        {:events "symbol:mouseover",
                             ;         :update "fix || true"}
                             ;        {:events "[symbol:mousedown, window:mouseup] > window:mousemove!",
                             ;         :update "xy()",
                             ;         :force  true}]}
                             ;{:description "Graph node most recently interacted with.",
                             ; :name        "node", :value nil,
                             ; :on          [{:events "symbol:mouseover",
                             ;                :update "fix === true ? item() : node"}]}
                             {:description "Flag to restart Force simulation upon data changes.",
                              :name        "restart",
                              :value       false,
                              :on          [{:events {:signal "fix"},
                                             :update "fix && fix.length"}]}],
                  :data     [{:name   "node-data"
                              :url    "/relations"
                              :format {:type "json", :property "nodes"}
                              }
                             {:name      "link-data"
                              :url       "/relations"
                              :format    {:type "json", :property "links"}
                              :transform [{:type   "lookup"
                                           :fields ["name" "name_2"]
                                           :as     ["source" "target"]}]
                              }],
                  ;:scales
                  ;          [{:name   "color",
                  ;            :type   "ordinal",
                  ;            :domain {:data "node-data", :field "name"},
                  ;            :range  {:scheme "category20c"}}],

                  :marks
                            [{:name   "nodes",
                              :type   "symbol",
                              :zindex 1,
                              :from   {:data "node-data"},
                              :on
                                      [{:trigger "fix",
                                        :modify  "node",
                                        :values
                                                 "fix === true ? {fx: node.x, fy: node.y} : {fx: fix[0], fy: fix[1]}"}
                                       {:trigger "!fix",
                                        :modify  "node",
                                        :values  "{fx: null, fy: null}"}],
                              ;:encode
                              ;        {:enter
                              ;         {:fill   {:scale "color", :field "group"},
                              ;          :stroke {:value "white"}},
                              ;         :update
                              ;         {:size
                              ;                  {:signal "2 * nodeRadius * nodeRadius"},
                              ;          :cursor {:value "pointer"}}},
                              :transform
                                      [{:type       "force",
                                        :iterations 300,
                                        :restart    {:signal "restart"},
                                        :static     {:signal "static"},
                                        :signal     "force",
                                        :forces     [{:force "center",
                                                      :x     {:signal "cx"},
                                                      :y     {:signal "cy"}}
                                                     {:force  "collide",
                                                      :radius {:signal "nodeRadius"}}
                                                     {:force    "nbody",
                                                      :strength {:signal "nodeCharge"}}
                                                     {:force    "link",
                                                      :links    "link-data",
                                                      :distance {:signal "linkDistance"}}]}]}
                             {:type        "path",
                              :interactive false,
                              :from        {:data "link-data"},
                              :encode      {:update
                                            {:stroke      {:value "#ccc"},
                                             :strokeWidth {:value 0.5}}},
                              :transform
                                           [{:type    "linkpath",
                                             :require {:signal "force"},
                                             :shape   "line",
                                             :sourceX "datum.source.x", :sourceY "datum.source.y",
                                             :targetX "datum.target.x", :targetY "datum.target.y"}]}]}]

    ;(-> (validate-and-parse nodespec)
    ;    (p/catch #(js/alert (str "Unable to parse spec:\n\n" %)))
    ;    (p/then #(-> (% {:el (js/document.getElementById "chart")})
    ;                 (.update))))

    (let [content (js/document.getElementById "app")]
      (while (.hasChildNodes content)
        (.removeChild content (.-lastChild content)))
      ;(.appendChild content (js/document.createTextNode "Welcome to cat"))
      )))

(defn init! []
  (mount-components))
;(main))


