(require-macros :lib.macros)
(local utils (require :utils))

(local {: contains? : for-each : map : filter : merge : reduce : split : some : concat}
       (require :lib.functional))

;; TODO move to utils
(fn str-split [sep inputstr]
  (icollect [s (string.gmatch inputstr (.. "([^" sep "]+)"))]
    s))

(fn debug [value]
  ((print (fennel.view value))))

(fn list-bunches []
  (match (hs.osascript.applescript "tell application \"Bunch\" to list bunches")
    (ok bunches desc) bunches))

(fn list-open-bunches []
  (match (hs.osascript.applescript "tell application \"Bunch\" to list open bunches")
    (ok bunches desc) bunches))

(fn toggle-selected-bunch [data]
  (if (. data :open)
    (utils.run-script (.. "tell application \"Bunch\" to open bunch \"" (. data :text) "\""))
    (utils.run-script (.. "tell application \"Bunch\" to close bunch \"" (. data :text) "\""))))
  
(fn create-bunch-choice [open] 
  (fn [bunch] {
          :text (match (str-split "/" bunch)
                       [_ t] t
                       [t] t)
          :subText (if (= open true)
              (.. "open " bunch)
              (.. "closed " bunch))
          :icon nil
          :open: open
          :title bunch
        }))

(fn get-bunches []
  (let [all (list-bunches)
        open (list-open-bunches)
        closed (fn [e]
                 (not (contains? e open)))]
    (concat (map (create-bunch-choice false) (filter closed all)) 
            (map (create-bunch-choice true) open))))

(fn show-bunches []
  (let [chooser (hs.chooser.new toggle-selected-bunch)
        bunches (get-bunches)]
    (print (fennel.view bunches))
    (: chooser :choices bunches)
    (: chooser :searchSubText true)
    (: chooser :show)))

{ : show-bunches : list-bunches : str-split}

