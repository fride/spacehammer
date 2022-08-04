;; see https://evantravers.com/articles/2020/06/12/hammerspoon-handling-windows-and-layouts/
;; https://fennel-lang.org/reference#lambda%CE%BB-nil-checked-function
(local w (require "win"))

;; TODO This is to slow, it can takemore then 10 seconds

(fn split-view [choice]
  (let [to-raise (. choice :window)
        focused (. choice :focused)
        layout [[nil focused (: focused :screen) hs.layout.left50 0 0]
                [nil to-raise (: focused :screen) hs.layout.right50 0 0]]]
    (hs.eventtap.keyStroke [:cmd :alt] :h)
    (hs.layout.apply layout)     
    (: to-raise :raise)))

(fn split-view-choices []
  (let [windows (w.get-windows)]
    (doto (hs.chooser.new split-view)
      (: :placeholderText "Choose window for 50/50 split. Hold ⎇ for 70/30.")
      (: :choices windows)
      (: :show))))

      

;; may be slow
(: hs.window.filter.defaultCurrentSpace :subscribe 
  [hs.window.filter.windowCreated
;  hs.window.filter.windowInCurrentSpace
  hs.window.filter.windowFocused
 ; hs.window.filter.windowNotInCurrentSpace
  hs.window.filter.windowMinimized
  hs.window.filter.indowDestroyed]
  #( print (.. "window: " (fennel.view $1) ", " $2 ", " $3 ))
)

{: split-view-choices}
