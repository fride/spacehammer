(print (fennel.view hs.grid.HINTS))
;;;
;
; This assumes That I want 6 colums and 3 rows as it can be devided by 2 and 3 and be split to the home blocks on
;; the left and right hands.
;
(local qwerty-hints hs.grid.HINTS)

(set hs.hotkey.setLogLevel 5)
;; setup the grid
(let [my-grid-hints [[:f1 :f2 :f3 :f4 :f5 :f6]
                     [:1 :2 :3 :4 :5 :6]
                     [:g :h :p "." "(" ")"]
                     [:n :t :s :a :e :i]
                     [:b :m :g "," "." "/"]] ;; "," does not work - no idea whay!?
      main-screen (hs.screen.find "LG ULTRAWIDE")]
  (tset hs.grid :HINTS my-grid-hints)
  (hs.grid.setGrid {:h 3 :w 6} main-screen))

(fn gritz []
  (let [main-screen (hs.screen.find "LG ULTRAWIDE")]
    (hs.grid.show)))

(local win-sets {:VSCode [{:name :Code :position "0,0 3x3"}
                          {:name :Dash :position "3,0 3x2"}
                          {:name :iTerm :position "3,3 3x1"}]
                 :IntelliJ [{:name "IntelliJ IDEA" :position "0,0 3x3"}]})

(fn get-or-launch-app [name] (do
      (hs.application.launchOrFocus name)
      (hs.application.find name)))

;; todo add the screen!
(fn position-app-windows [application]
  (let [name (. application :name)
        position (. application :position)
        _ (print (.. "setting " name " to " position))
        ;; TODO works only if app os stared.
        app (get-or-launch-app name)
        windows (: app :allWindows)
        _ (print (.. "windows " (fennel.view windows)))]
    (: app :activate)
    (each [_ window (pairs windows)]
      (: window :unminimize)
      (hs.grid.set window position "LG ULTRAWIDE"))))

(fn toggle-win-set [win-set]
  (each [_ app (pairs win-set)]
    (position-app-windows app)))


{: gritz}
