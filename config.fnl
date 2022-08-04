(require-macros :lib.macros)
(require-macros :lib.advice.macros)
(local spaces (require "hs._asm.undocumented.spaces"))

(local {: contains?
        : for-each
        : map
        : filter
        : merge
        : reduce
        : split
        : some
        : concat} (require :lib.functional))

(local windows (require :windows))
(local emacs (require :emacs))
(local slack (require :slack))
(local vim (require :vim))

(local s (require :split-view))
(local b (require :bunches))
(local o (require :org))
(local sound (require :sound))
(local g (require :gritz))
(local trans (require :translation))
(local v (require :vpn))
(local repl (require :repl))
(hs.spoons.use :SpoonInstall)

(local Install spoon.SpoonInstall)

(local {: concat : logf} (require :lib.functional))
(local secrets (hs.json.read "~/.secrets/spacehammer.json"))

(local a (require :applications))
(local spaces (require :spaces))
(local tiles (require :tiles))
(local snippets (require :snippets))
(local utils (require :utils))
(local w (require "win"))

;;;;;;;; Jan made start

;;;;;;;; 
;;; TODO add tiling wm to the setup.

; hs.window.tiling.tileWindows(windows,rect[,desiredAspect[,processInOrder[,preserveRelativeArea[,animationDuration]]]])
(global tiling (require "hs.tiling"))
; local hotkey = require "hs.hotkey"
; local mash = {"ctrl", "cmd"}

; hotkey.bind(mash, "c", function() tiling.cycleLayout() end)
; hotkey.bind(mash, "j", function() tiling.cycle(1) end)
; hotkey.bind(mash, "k", function() tiling.cycle(-1) end)
; hotkey.bind(mash, "space", function() tiling.promote() end)
; hotkey.bind(mash, "f", function() tiling.goToLayout("fullscreen") end)

;; If you want to set the layouts that are enabled
(tiling.set "layouts" ["fullscreen" "main-vertical" "gp-vertical"])

(fn show-hints []
  (hs.hints.windowHints 
    (hs.window.visibleWindows) 
    #(let [frame (: $1 :frame)
           pos (. frame :center )]
     (hs.mouse.absolutePosition pos)
    )))
  ;;;;;


;; Start with a delay!
(fn start-some-stuff [] 
        (do (print "Timer started")
        ;; hide all app
        (hs.eventtap.keyStroke [:cmd :alt] :h)
        (hs.eventtap.keyStroke [:cmd ] :h)  
                ;;(map #(: $1 :hide) (hs.application.runningApplications))
                (print "starting windows")
                (a.activate-apps [:VSCode :Brave :Obsidian])))


(fn applescript [script]

  (let [(_ res _) (hs.osascript.applescript script)] res))

(fn current-app-bundle-id []
  (-?> (hs.application.frontmostApplication)
  (: :bundleID)))

(fn get-url-of-current-broser []
  ;; only chrome based. Firefox can't do!
  ;; inspired by https://gist.github.com/vitorgalvao/5392178
  (let [url (match (current-app-bundle-id)
              :com.brave.Browser   (applescript "tell application \"Brave Browser\" to get the URL of the active tab in the first window")
              :com.vivaldi.Vivaldi (applescript "tell application \"Vivaldi\" to get the URL of active tab of front window")
              _ "no url here")]
    url))


(fn list-snapshots []
  (match (hs.osascript.applescript "tell application \"Moom\" to list of snapshots")
    ;; todo use map for this collect!
    (ok snapshots desc)
    (collect [i bunch (ipairs snapshots)]
      (values i {:text bunch :subText bunch}))))

(fn toggle-snapshot [name]
  (hs.osascript.applescript (.. "tell application \"Moom\" to arrange windows according to snapshot named\""
                                (. name :text) "\"")))

(fn show-moom-snapshots []
  (doto (hs.chooser.new toggle-snapshot)
    (: :choices (list-snapshots))
    (: :show)))

;;;; 

(local main-screen "  LG ULTRAWIDE")

(fn create-split-layout [app1 app2]
  [[app1 nil main-screen hs.layout.left50 nil nil]
   [app2 nil main-screen hs.layout.right50 nil nil]])

((. hs.urlevent.bind) :splitView
                      (fn [eventName params]
                        (let [fst-app (. params :app1)
                              snd-app (. params :app2)
                              layout (create-split-layout fst-app snd-app)]
                          (hs.layout.apply layout))))

;;;;;;; Jan Made end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;w
;; Table of Contents
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; [x] w - windows
;; [x] |-- w - Last window
;; [x] |-- cmd + hjkl - jumping
;; [x] |-- hjkl - halves
;; [x] |-- alt + hjkl - increments
;; [x] |-- shift + hjkl - resize
;; [x] |-- n p - next, previous screen
;; [x] |-- shift + n, p - up, down screen
;; [x] |-- g - grid
;; [x] |-- m - maximize
;; [x] |-- c - center
;; [x] |-- u - undo
;;
;; [x] a - apps
;; [x] |-- e - emacs
;; [x] |-- g - chrome
;; [x] |-- f - firefox
;; [x] |-- i - iTerm
;; [x] |-- s - Slack
;; [x] |-- b - Brave
;;
;; [x] j - jump
;;
;; [x] m - media
;; [x] |-- h - previous track
;; [x] |-- l - next track
;; [x] |-- k - volume up
;; [x] |-- j - volume down
;; [x] |-- s - play\pause
;; [x] |-- a - launch player
;;
;; [x] x - emacs
;; [x] |-- c - capture
;; [x] |-- z - note
;; [x] |-- f - fullscreen
;; [x] |-- v - split
;;
;; [x] alt-n - next-appg
;; [x] alt-p - prev-app

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Actions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(fn activator [app-name]
  "
  A higher order function to activate a target app. It's useful for quickly
  binding a modal menu action or hotkey action to launch or focus on an app.
  Takes a string application name
  Returns a function to activate that app.

  Example:
  (local launch-emacs (activator \"Emacs\"))
  (launch-emacs)
  "
  (fn activate []
    (windows.activate-app app-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; If you would like to customize this we recommend copying this file to
;; ~/.spacehammer/config.fnl. That will be used in place of the default
;; and will not be overwritten by upstream changes when spacehammer is updated.
(local music-app :Spotify)

(local return {:key :space :title :Back :action :previous})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Audio Menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local audio-menu (concat [return
                           {:title "Select output device"
                            :action sound.select-output-device
                            :key :o}]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(local window-move-screens [{:key "n, p" :title "Move next\\previous screen"}
                            {:mods [:shift]
                             :key "n, p"
                             :title "Move up\\down screens"}
                            {:key :n
                             :action "windows:move-south"
                             :repeatable true}
                            {:key :p
                             :action "windows:move-north"
                             :repeatable true} 
                            {:mods [:shift]
                             :key :n
                             :action "windows:move-west"
                             :repeatable true}
                            {:mods [:shift]
                             :key :p
                             :action "windows:move-east"
                             :repeatable true}])
(local window-jumps
       [{:mods [:cmd]
         :key "aeih"
         :title "Jump"}
        {:mods [:cmd]
         :key :a
         :action "windows:jump-window-left"
         :repeatable true}
        {:mods [:cmd]
         :key :i
         :action "windows:jump-window-above"
         :repeatable true}
        {:mods [:cmd]
         :key :e
         :action "windows:jump-window-below"
         :repeatable true}
        {:mods [:cmd]
         :key :h
         :action "windows:jump-window-right"
         :repeatable true}])

(local expose (hs.expose.new nil {:showThumbnails true :includeOtherSpaces true}))

(local window-bindings
       (concat [return                
                {:key :e :title "Expose" :repeatable false :action #(: expose :toggleShow)}
                {:key :l :title "Expose" :repeatable false :action #(w.select-window)}
                {:key 24 :title "bigger" :repeatable true :action #(hs.eventtap.keyStroke [:cmd :ctrl :alt] :=)}
                {:key :y :title "Cycle" :repeatable true :action #(tiling.cycleLayout)}
                {:key 27 :title "smaller" :repeatable true :action #(hs.eventtap.keyStroke [:cmd :ctrl :alt] :-)}
                 
                ; {:key :left :title "clock" :action #(hs.eventtap.keyStroke :j [:cmd :ctrl :alt])}
                {:key :w
                 :title "Last Window"
                 :action "windows:jump-to-last-window"}
               ; {:key :h :title "Hints" :action #(hs.hints.windowHints (: hs.window.filter.defaultCurrentSpace :getWindows))}
                {:key :x :title "Select and swap with main" :action 
                  #(hs.hints.windowHints
                     (: hs.window.filter.defaultCurrentSpace  :getWindows)
                     #(hs.eventtap.keyStroke [:alt :ctrl :cmd] :s)
                     false)}
              ;  {:key :o :title "Moom Snapshots" :action show-moom-snapshots}
                {:key :s :title :Split :action s.split-view-choices}]
               window-move-screens
                window-jumps
               [{:key :m
                 :title :Maximize
                 :action "windows:maximize-window-frame"}
                {:key :c :title :Center :action "windows:center-window-frame"}
                {:key :g :title :Grid :action g.gritz}
                {:key :u :title :Undo :action "windows:undo"}]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Apps Menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local app-bindings
       [return
        {:key "1" :title :Emacs :action #(hs.timer.doAfter 2 start-some-stuff )}
        {:key "d" :title :Drafts :action (activator "Drafts")}        
        {:key :b :title :Brave :action (activator "brave browser")}
        {:key "/" :title "App Infos" :action a.show-app-infos}
        {:key :j :title "IntelliJ" :action (activator "IntelliJ IDEA")}
        {:key :g :title :Chrome :action (activator "Google Chrome")}
        {:key :f :title :Firefox :action (activator :Firefox)}
        {:key :t :title :iTerm :action (activator :iterm)}        
        {:key :s :title :Slack :action (activator "Safari")}      
        {:key :l :title :Slack :action (activator "Logseq")}      
        {:key :n :title :NotePlan :action #(a.activate-apps :NotePlan)}
        ;; this must go to some other place
        {:key :r :title :Research :action 
            (fn [] 
              (do 
                  (windows.activate-app "Logseq")                  
                  (windows.activate-app "Safari")
                  (utils.moom-layout "Journaling")))}
        {:key :z :title "Show Bundle ID" 
         :action (fn [] 
          (let [id (: (: (hs.window.focusedWindow) :application) :bundleID )] 
          (alert id)))}
        {:key :m :title music-app :action (activator music-app)}])

(local media-bindings [return
                       {:key :s
                        :title "Play or Pause"
                        :action "multimedia:play-or-pause"}
                       {:key :h
                        :title "Prev Track"
                        :action "multimedia:prev-track"}
                       {:key :l
                        :title "Next Track"
                        :action "multimedia:next-track"}
                       {:key :j
                        :title "Volume Down"
                        :action "multimedia:volume-down"
                        :repeatable true}
                       {:key :k
                        :title "Volume Up"
                        :action "multimedia:volume-up"
                        :repeatable true}
                       {:key :a
                        :title (.. "Launch " music-app)
                        :action (activator music-app)}])


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main Menu & Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local menu-items
       [{:key :space :title :Alfred :action (activator "Alfred 4")}
        {:key :u :title :Url :action get-url-of-current-broser}        
        {:key :b
         :title :Bunches
         :action (fn []
                   (b.show-bunches))}
        {:items audio-menu :key :s :title "Sound and Audio"}
        {:key :w
         :title :Window
         :enter "windows:enter-window-menu"
         :exit "windows:exit-window-menu"
         :items window-bindings}
        {:key :a :title :Apps :items app-bindings}
        {:key :s :title :Snippets :action #(snippets.show-snippets)}
        {:key :v :title :VPN :items v.vpn-menu}
;;        {:key :j :title :Jump :action "windows:jump"}
        {:key :m :title :Media :items media-bindings}
        {:key :o :title :Orga :items (concat [return] o.org-menu-items)}])

;; https://github.com/agzam/spacehammer/discussions/128
;; Todo this simply does nothing.
(local repl-keys
       [{:mods [:alt :cmd]
         :key :r
         :action (fn []
                   (alert "creating repl server")
                   (global repl-server (repl.start {:port 7888 :host "127.0.0.1"})))}
        {:mods [:alt :cmd]
         :key :s
         :action (fn []
                   (alert "running repl server")
                   (repl.run repl-server))}
        {:mods [:alt :cmd]
         :key :t
         :action (fn []
                   (alert "stopping repl server")
                   (repl.stop repl-server))}])


(local ametyst-keys [
  {:mods   [:hyper] :key :1 :action #(do
                                        (hs.eventtap.keyStroke [:alt :ctrl] :1)
                                        (hs.eventtap.keyStroke [:alt :command :ctrl] :e)
                                        (hs.eventtap.keyStroke [:alt :command :ctrl] :t)
                                        (hs.eventtap.keyStroke [:alt :command :ctrl] :a))}
  {:mods   [:hyper] :key :2 :action #(hs.eventtap.keyStroke [:alt :ctrl] :2)}
  {:mods   [:hyper] :key :3 :action #(hs.eventtap.keyStroke [:alt :ctrl] :3)}
  {:mods   [:hyper] :key :4 :action #(hs.eventtap.keyStroke [:alt :ctrl] :4)}
  {:mods   [:hyper] :key :5 :action #(hs.eventtap.keyStroke [:alt :ctrl] :5)}
  {:mods   [:hyper] :key :6 :action #(hs.eventtap.keyStroke [:alt :ctrl] :6)}

  ;
  ; eithar hammerpace or amethyst.
  {:mods   [:hyper] :key :u :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :a)}
  {:mods   [:hyper] :key :o :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :e)}
  ; cycle layout
  {:mods   [:hyper] :key :return :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :return)}
  {:mods   [:hyper] :key :f :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :f)}
  {:mods   [:hyper] :key :a :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :a)}
  {:mods   [:hyper] :key :e :action #(hs.eventtap.keyStroke [:alt :ctrl :command] :e)}
  {:mods   [:hyper] :key :s :action (fn [] (hs.eventtap.keyStroke [:cmd :ctrl :alt] :s))}
  {:mods   [:hyper] :key :t :action (fn [] (hs.eventtap.keyStroke [:cmd :ctrl :alt] :t))}
])

(local common-keys (concat 
                    ametyst-keys ; tiling.tiling-keys 
                    repl-keys 
                    [{:mods [:hyper] :key :space :action "lib.modal:activate-modal"}
                     {:mods [:hyper] :key :l :action "lib.modal:activate-modal"}
                    {:mods [:hyper] :key :h :action #(show-hints)}                
                    {:mods [:cmd :ctrl] :key "`" :action hs.toggleConsole}
                    {:mods ["hyper"] :key :h :action (fn [] (w.hints))}
                     {  :key :g 
                        :title :Grid 
                        :mods   [:hyper]
                        :action g.gritz}
                     {  :key :q 
                        :title "GriList Windowsd "
                        :mods   [:hyper]
                        :action (fn [] (w.select-window))}
                     {:mods   [:hyper]
                        :key    :d 
                        :action #(do
                          (hs.eventtap.keyStroke [:cmd ] :left)
                          (hs.eventtap.keyStroke [:cmd :shift] :right)
                          (hs.eventtap.keyStroke [:cmd] :c)
                          (hs.eventtap.keyStroke [:cmd] :right)
                          (hs.timer.usleep 1000)
                          (hs.eventtap.keyStroke [] "t")
                          (hs.eventtap.keyStroke [] :return)
                          (hs.eventtap.keyStroke [:cmd] :v)
                          )}
                     
                     {:mods   [:hyper]
                        :key    :n
                        :action (fn [] (hs.eventtap.keyStroke [:cmd :ctrl :alt] :n))}
                    
                     ;; start idea
                     {:mods   [:hyper]
                        :key    :i
                        :action (activator "com.jetbrains.intellij")}
                     ;; TODO create a vim instance here!?
                     {:mods   [:hyper]
                        :key    :t
                        :action (activator "iTerm")}

                     {:mods   [:hyper]
                        :key    :=
                        :action (fn [] (hs.eventtap.keyStroke [:cmd :ctrl :alt] :=))}
                    ;  {:mods   [:hyper]
                    ;     :key   :return
                    ;     :action (fn [] (hs.eventtap.keyStroke [:cmd :ctrl :alt] :return))}
                    {:mods [:cmd :ctrl]
                     :key :o
                     :action "emacs:edit-with-emacs"}]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; App Specific Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local browser-keys [{:mods [:cmd :shift]
                      :key :l
                      :action "chrome:open-location"}
                     {:mods [:alt]
                      :key :k
                      :action "chrome:next-tab"
                      :repeat true}
                     {:mods [:alt]
                      :key :j
                      :action "chrome:prev-tab"
                      :repeat true}])

(local browser-items
       (concat menu-items
               [{:key "'"
                 :title "Edit with Emacs"
                 :action "emacs:edit-with-emacs"}]))

(local brave-config {:key "Brave Browser"
                     :keys browser-keys
                     :items browser-items})

(local chrome-config {:key "Google Chrome"
                      :keys browser-keys
                      :items browser-items})

;; this seams to be nil
(local teams-config {:key "Microsoft Teams"
                      :keys [
                          {:mods [:hyper :shift :command]
                            :key :m
                            :action #(hs.eventtap.keyStroke [:cmd :shift] :m)
                            :repeat true}
                      ]
                      :items browser-items})

(local firefox-config {:key :Firefox :keys browser-keys :items browser-items})

(local grammarly-config {:key :Grammarly
                         :items (concat menu-items
                                        [{:mods [:ctrl]
                                          :key :c
                                          :title "Return to Emacs"
                                          :action "grammarly:back-to-emacs"}])
                         :keys ""})

(local hammerspoon-config {:key :Hammerspoon
                           :items (concat menu-items
                                          [{:key :r
                                            :title "Reload Console"
                                            :action hs.reload}
                                           {:key :c
                                            :title "Clear Console"
                                            :action hs.console.clearConsole}])
                           :keys []})

(local slack-config {:key :Slack
                     :keys [{:mods [:cmd]
                             :key :g
                             :action "slack:scroll-to-bottom"}
                            {:mods [:ctrl]
                             :key :r
                             :action "slack:add-reaction"}
                            {:mods [:ctrl]
                             :key :h
                             :action "slack:prev-element"}
                            {:mods [:ctrl]
                             :key :l
                             :action "slack:next-element"}
                            {:mods [:ctrl] :key :t :action "slack:thread"}
                            {:mods [:ctrl] :key :p :action "slack:prev-day"}
                            {:mods [:ctrl] :key :n :action "slack:next-day"}
                            {:mods [:ctrl]
                             :key :e
                             :action "slack:scroll-up"
                             :repeat true}
                            {:mods [:ctrl]
                             :key :y
                             :action "slack:scroll-down"
                             :repeat true}
                            {:mods [:ctrl]
                             :key :i
                             :action "slack:next-history"
                             :repeat true}
                            {:mods [:ctrl]
                             :key :o
                             :action "slack:prev-history"
                             :repeat true}
                            {:mods [:ctrl]
                             :key :j
                             :action "slack:down"
                             :repeat true}
                            {:mods [:ctrl]
                             :key :k
                             :action "slack:up"
                             :repeat true}]})

(local apps [brave-config
             chrome-config
             teams-config
             firefox-config
             grammarly-config
             hammerspoon-config
             slack-config])

(local config {:title "Main Menu"
               :items menu-items
               :keys common-keys
               :enter (fn []
                        (windows.hide-display-numbers))
               :exit (fn []
                       (windows.hide-display-numbers))
               : apps
               :hyper {:key :F19}
               :modules {:windows {:center-ratio "80:50"}}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Exports
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     


; (hs.window.layout.applyLayout ["tile all"])
;; hide dock item so the menu is visible in fullscreen apps.
(set hs.window.animationDuration 0)

;(print (fennel.view (hs.canvas.elementSpec) ))
;(hs.dockIcon false)
(local u (require :urls))

;; TODO add this with app starts and we have headspaces!
(local moom (require :moom))
(moom.moom-choice)

config

