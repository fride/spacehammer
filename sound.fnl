(require-macros :lib.macros)
(require-macros :lib.advice.macros)

(fn select-output-device []
  (let [devices (collect [i out (ipairs (hs.audiodevice.allOutputDevices))]
                  (values i {:text (: out :name)
                             :subText :out
                             :uid (: out :uid)}))
        action (fn [s]
                 (-> (hs.audiodevice.findDeviceByUID (. s :uid))
                     (: :setDefaultOutputDevice)))
        chooser (hs.chooser.new action)]
    (: chooser :choices devices)
    (: chooser :show)))

{
    : select-output-device
}