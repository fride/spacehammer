(require-macros :lib.macros)
; (local {:contains? contains?
;         :for-each  for-each
;         :map       map
;         :merge     merge
;         :reduce    reduce
;         :split     split
;         :some      some} 
;     (require :lib.functional))

(fn str-split [sep inputstr] (icollect [s (string.gmatch inputstr (.. "([^" sep "]+)") )] s))

(fn debug [value] ((print (fennel.view value))))

(fn list-bunches [] (match (hs.osascript.applescript "tell application \"Bunch\" to list bunches")
    (ok bunches desc) bunches))

(fn launch-bunch [name] 
    (alert name)    
     (hs.osascript.applescript (.. "tell application \"Bunch\" to open bunch \"" name "\"")))

(fn create-bunch-menu [] 
    (collect [i bunch (ipairs (list-bunches))] (values i {
        :text bunch
        :index i
        :action (fn [] (launch-bunch bunch))
        :key (.. i "") })))

(fn create-bunch-choices [] 
    (collect [i bunch (ipairs (list-bunches))] (values i {
        :text (match (str-split "/" bunch)
                [_ t]  t
                [t] t)
        :subText bunch
        :key (.. i "") })))

(fn toggle-selected-bunch [data]
    (launch-bunch (. data :text)))

(fn show-bunches [] (let [chooser (hs.chooser.new toggle-selected-bunch)
      bunches (create-bunch-choices)]
    (print (fennel.view bunches))
    (: chooser :choices bunches)
    (: chooser :show )))

{
    : create-bunch-menu
    : launch-bunch
    : show-bunches
    : list-bunches
}