;; see https://evantravers.com/articles/2020/06/12/hammerspoon-handling-windows-and-layouts/
;; https://fennel-lang.org/reference#lambda%CE%BB-nil-checked-function
(require-macros :lib.macros)
    
(local wf (hs.window.filter.new))

(fn app-name [win] 
     (-> win 
        (: :application)
        (: :title)))

(fn get-windows []
    (let [focused (hs.window.focusedWindow)]
        (icollect  [_ window (ipairs (: wf :getWindows))] 
            (when (not= window focused) 
                {:text (app-name window) 
                 :id (: window :id)
                 :window window
                 :focused focused
                 :image (hs.image.imageFromAppBundle (: (: window :application) :bundleID))
                 :subText (: window :title)}))))


(fn split-view [choice] 
(print (fennel.view choice))
    (let [id (. choice :id)
          to-raise (. choice :window)
          focused (. choice :focused)
          layout [
            [nil focused (: focused :screen) hs.layout.left50 0 0] 
            [nil to-raise (: focused :screen) hs.layout.right50 0 0]]]
          (hs.layout.apply layout)
          (: to-raise :raise)))


(fn split-view-choices [] 
    (let [windows (get-windows)]
          (doto (hs.chooser.new split-view)
            (: :choices windows)
            (:  :show ))))

{
    : split-view-choices 
}