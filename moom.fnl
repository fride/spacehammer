(local {: contains?
        : for-each
        : map
} (require :lib.functional))
(local {: run-script} (require :lib.functional))

(fn moom-layout [layout]
  (run-script (.. "tell application \"Moom\" 
arrange windows according to snapshot named \"" layout
                  "\"\n end tell")
              (fn [m]
                (alert m))
              (fn [m]
                (alert m))))

(fn get-moom-snapshots []
  (print "mooooooooomy!\n\n\n\n")
  (match 
    (hs.osascript.applescript "tell application \"Moom\"\n list of snapshots\nend tell")
    (ok snapshosts desc) 
      (do 
        (print (.. "mooooooooomy!>>>" desc "\n\n\n\n"))
        snapshosts)))

(fn moom-create-layout [name]
  (run-script (.. "tell application \"Moom\"\n"
                  "save window layout and replace snapshot \"" name "\"\n"
                  "end tell")))

(fn moom-choice []  
  (let [snapshots (map (fn [choice] {:text choice}) (get-moom-snapshots))
        on-choice (fn [choice] (moom-layout (. choice :text)))
        chooser (hs.chooser.new on-choice)]
        (: chooser :choices snapshots)
        (: chooser :show)))

{: moom-create-layout : moom-layout : moom-choice}

;; https://api.cognitive.microsofttranslator.com/dictionary/lookup?api-version=3.0?from=en&to=de
;; Ocp-Apim-Subscription-Key: 9a32e969a6074dbc863750ff88dd3c07
;; Content-Type: application/json; charset=UTF-8
;; json ->
