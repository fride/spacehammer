(local {: contains?
        : for-each
        : map
} (require :lib.functional))

(local return {:key :space :title :Back :action :previous})

(fn run-script [script on-ok on-err]
  ;; Runs a script in background.
  (let [script-callback (fn [exit-code standart-out standart-error]
                          (if (= 0 exit-code)
                              (do
                                (hs.notify.show "Execution Complete" ""
                                                (.. "Script " script
                                                    " completed successfully."
                                                    ""))
                                (when on-ok
                                  (on-ok standart-out)))
                              (do
                                (hs.notify.show "Execution FAILED" ""
                                                (.. "Script " script
                                                    " failed.  Check the logs."
                                                    ""))
                                (when on-err
                                  (on-err standart-error)))))
        script-task (hs.task.new :/usr/bin/osascript script-callback
                                 [:-e script])]
    (: script-task :start)))

{: run-script : return}
