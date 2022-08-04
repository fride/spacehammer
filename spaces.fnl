(local {: contains?
        : for-each
        : map
        : filter
        : merge
        : reduce
        : split
        : some
        : concat} (require :lib.functional))

(local spaces
       [{:text "Coding with IntelliJ"
         :subText "Write some Java/Scala/Kotlin in IntelliJ"
         :image (hs.image.imageFromAppBundle :com.jetbrains.intellij)
         :launch [:IntelliJ]
         :on-activation :say-hello}
        {:text "Zoom Meeting"
         :subText "Meet in Zoom"
         :image (hs.image.imageFromAppBundle :com.flexibits.fantastical2.mac)}])

;; can't attatch functions to the choices. So .... I should write a macro ;)
(local space-listeners
       {:say-hello (fn [space]
                     (print (fennel.view space)))})

(fn printit [title it]
  (print (.. title (fennel.view it)))
  it)

; (fn launch-required-applicatons [space app-launcher]
;   (print (.. "starting apps....\n\n\n" (fennel.view space)))
;   (let [get-app-bundle (fn [name]
;                          (print (.. "looking for app " name))
;                          (?. applications name :bundleID))]
;     (-?>> (. space :launch)
;           (map get-app-bundle)
;           (for-each (fn launch [appid]
;                       (hs.application.launchOrFocusByBundleID (printit "launching "
;                                                                        appid)))))))

(fn find-listener [space]
  (-?>> (?. space :on-activation)
        (. space-listeners)))

(fn toggle-space [app-launcher]
  (fn [space]
    (let [on-activation (find-listener space)
          _ (print (.. "Acticator? " (fennel.view on-activation)))]
      (do
        (match (?. space :launch)
          nil nil
          apps (app-launcher apps))
        (when on-activation
          (on-activation space))
        (alert (.. "toggle space " (fennel.view space)))))))

;;
(fn configure-spaces [config]
  (let [app-launcher (. config :app-launcher)]
    #(let [chooser (hs.chooser.new (toggle-space app-launcher))]
       (: chooser :choices spaces)
       (: chooser :searchSubText true)
       (: chooser :show))))

; (fn launch-space [space]
;   (do
;     (alert (.. "starting Space " (. space :text)))
;     (let [on-start (: space :on-start)]
;       (on-start))))

; (if (hs.application.launchOrFocus :zoom.us)
;     (do
;       (print "entering Zoom Meeting Space")      
;       (let [zoom (hs.application.find "zoom.us")]
;         (alert "found zoom")

;       ))      
;       (alert "No Zoom found"))

{: configure-spaces}

;; hs.application.applicationsForBundleID("us.zoom.xos")

