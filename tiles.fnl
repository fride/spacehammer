;;;
;
; tiling with hammerspoon
;
(require-macros :lib.macros)
(local {: contains?
        : for-each
        : map
        : filter
        : merge
        : reduce
        : split
        : some
        : concat} (require :lib.functional))

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


{
    :tiling-keys ametyst-keys
}