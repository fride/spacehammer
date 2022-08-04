

;; TODO snippet service
;; TODO maybe add some categories? 

;; TODO if alt is pressed put into clipboard!
;;  local chooser = hs.chooser.new(function(choice)
;;     if choice ~= nil then
;;       local layout = {}
;;       local focused = hs.window.focusedWindow()
;;       local toRead  = hs.window.find(choice.id)
;;       if hs.eventtap.checkKeyboardModifiers()['alt'] then
;;         hs.layout.apply({
;;           {nil, focused, focused:screen(), hs.layout.left70, 0, 0},
;;           {nil, toRead, focused:screen(), hs.layout.right30, 0, 0}
;;         })
;;       else
;;         hs.layout.apply({
;;           {nil, focused, focused:screen(), hs.layout.left50, 0, 0},
;;           {nil, toRead, focused:screen(), hs.layout.right50, 0, 0}
;;         })
;;       end
;;       toRead:raise()
;;     end
;;   end)
(local snippets [
  {:text :uuid 
   :subText "Generate a uuid" 
   :action :generate-uuid} ;; Hint - we can't add functions directly.
  {:text :Zettel 
   :subText "📘 Zettelkasten Prefix" 
   :action :generate-zettelkasten-prefix} ;; Hint - we can't add functions directly.
  {:text :Now 
   :subText "🕚 US-Time" 
   :action :generate-now} ;; Hint - we can't add functions directly.
   {:text "Wollmilchsau" :replacement "https://www.startpage.com/av/proxy-image?piurl=https%3A%2F%2Fencrypted-tbn0.gstatic.com%2Fimages%3Fq%3Dtbn%3AANd9GcS4cucdsT94RcuID44ku9LrNbfI5MehksYUOgW2MtuaWbST4TU%26s&sp=1656501956T13c6635799404935e10da0bd389048c80c7fd98e3f2bc39d432da941c105a055"}
  {:text "me" :subText "Jan Friderici" :replacement "Jan Friderici"}
  {:text "mail" :subText "jan@friderici" :replacement "jan@friderici.net"}
  {:text "innoq" :subText "jan.friderici@innoq.com" :replacement "jan.friderici@innoq.com"}
  {:text "nuke" :subText "💣 Nuke it" :replacement "https://www.youtube.com/watch?v=aCbfMkh940Q"}
  {:text "bs" :subText "Jan.Friderici@bestsecret.com" :replacement "Jan.Friderici@bestsecret.com"}
  {:text "asap" :subText "🏎 As Fast as Possible" :replacement "https://media.giphy.com/media/VtUrqIbEU2tuo/giphy.gif"}
  {:text "fuckit" :subText "🖕🏻Let's go bowling" :replacement "https://youtu.be/LG09C25LQlU"} 
  {:text "opinion" :subText "Dudes opinion" :replacement "https://www.youtube.com/watch?v=pWdd6_ZxX8c"}
  {:text "dozo" :subText "🇯🇵 Japanisch: gern geschehen, bitte" :replacement "どういたしまして"}
  {:text "ohaio" :subText "🇯🇵 Japanisch: guten Morgen" :replacement "おはようございます"}
  {:text "matte" :subText "🇯🇵 Japanisch: Eine Augenblick" :replacement "ちょっと待って"}
  {:text "domo" :subText "🇯🇵 Japanisch: vielen Dank, danke" :replacement "どうもありがとう"}
  {:text "sparta" :subText "This is SPARTA!" :replacement "https://i2.kym-cdn.com/photos/images/original/000/184/156/this_is_sparta_94.jpg"}
  {:text "sig" :subText "Signature" :replacement "Best Regards\nJan Friderici"}])

(fn get-snippet-replacement [snippet]
(do 
  (print (fennel.view snippet))
  (match (?. snippet :action)
      :generate-uuid (let [(output status _type rc) (hs.execute "uuidgen")] output)
      :generate-zettelkasten-prefix (os.date "%Y%M%d%H%M")
      :generate-now (os.date "%Y/%M/%d %H:%M")
      nil (. snippet :replacement))))
  

(fn snippet-action [snippet]
  (let [action #(hs.eventtap.keyStrokes $1)
     replacement (get-snippet-replacement snippet)]
     (action replacement)
     ))

(fn show-snippets []
 (doto (hs.chooser.new snippet-action)
    (: :choices snippets)
    (: :searchSubText true)
    (: :show)))

{
    : show-snippets
}
