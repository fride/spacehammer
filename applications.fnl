(local {: contains?
        : for-each
        : map
        : filter
        : merge
        : reduce
        : split
        : some
        : concat} (require :lib.functional))

(local apps {:Alfred {:bundleID :com.runningwithcrayons.Alfred}
             :Kitty {:bundleID :net.kovidgoyal.kitty
                     :preferred_display 1
                     :tags [:coding]}
             :iTerm {:bundleID :com.googlecode.iterm2
                     :preferred_display 1
                     :tags [:coding]}
             :VSCode {:bundleID :com.microsoft.VSCode
                      :bundle-name "Code"
                      :preferred_display 1
                      :tags [:coding]}
             :IntelliJ {:name :IntelliJ
                        :bundleID :com.jetbrains.intellij
                        :preferred_display 1
                        :preferred-space 1
                        :tags [:coding]}
             :NotePlan {:bundleID :co.noteplan.NotePlan3
                        :preferred_display 1
                        :preferred-space 2
                        :tags [:planning :review :tasks :notes :research]}
             :Brave {:bundleID :com.brave.Browser
                     :preferred_display 1
                     :preferred-space 1}
             :Firefox {:bundleID :org.mozilla.firefox :preferred_display 1}
             :Dashdoc {:bundleID :com.kapeli.dashdoc :tags [:coding]}
             :Slack {:bundleID :com.tinyspeck.slackmacgap
                     :preferred_display 2
                     :tags [:communication]}
             :Fantastical2 {:bundleID :com.flexibits.fantastical2.mac
                            :tags [:planning :review :calendar]
                            :whitelisted true
                            :preferred_display 2}
             :Finder {:bundleID :com.apple.finder}
             :Discord {:bundleID :com.hnc.Discord
                       :preferred_display 2
                       :tags [:distraction]}
             :Things {:bundleID :com.culturedcode.ThingsMac
                      :hyper_key :t
                      :preferred_display 1
                      :tags [:planning :review :tasks]
                      :whitelisted true}
             :TogglDesktop {:bundleID :com.toggl.toggldesktop.TogglDesktop}
             :iChat {:bundleID :com.apple.iChat
                     :hyper_key :q
                     :tags [:communication :distraction]}
             :Steam {:bundleID :com.valvesoftware.steam :tags [:distraction]}
             :Spotify {:bundleID :com.spotify.client}
             :Obsidian {:bundleID :md.obsidian
                        :tags [:research :notes]
                        :preferred_display 1}})

(fn hide-all-but []
  (hs.eventtap.keyStroke [:cmd :alt] :h))

(fn web-view []
  (let [init_w 710
        init_h 1200
        screen (hs.mouse.getCurrentScreen)
        ;init_x  (screen:fullFrame().w/2) - (init_w/2)
        ;init_y  (screen:fullFrame().h/3) - (init_h/3)
        rect (hs.geometry [0 0 init_h init_w])]
    (hs.webview.new rect
                    {:javaScriptEnable false
                     :javaScriptCanOpenWindowsAutomaticall false
                     :developerExtrasEnabled false})))

(fn show-app-infos [app]
  (let [app (hs.application.frontmostApplication)
        ;; (hs.application.infoForBundleID)
        bundleID (: app :bundleID)
        infos (hs.application.infoForBundleID bundleID)]
    (do
        (hs.pasteboard.setContents (hs.json.encode infos true))
      (print (fennel.view infos)))
    (-> (web-view)
        (: :closeOnEscape true)
        (: :html
           (.. :<html><head></head><body><pre> (hs.json.encode infos true)
               :</pre></body></html>))
        (: :windowStyle (bor 1 2 4 8 16))
        (: :show)
        (: :bringToFront))))


(fn activate-apps [a]
  ;; starts applications or activates them. The parameter 'a' can be a symbol/string or table.
  (let [launch #(-?>> (?. apps $1 :bundleID)
                      (hs.application.launchOrFocusByBundleID))]
    (when (type a)
      :string (launch a)
      :table (map launch a))))

{: show-app-infos : apps : activate-apps}

