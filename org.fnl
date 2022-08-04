(local windows (require :windows))

(fn noteplan [cmd]
  ;;
  (windows.activate-app "NotePlan 3")
  (hs.urlevent.openURL (.. "noteplan://x-callback-url/" cmd)))

;; create a simple timestamp
(fn zettel-prefix []
  (os.date "%Y%M%d%H%S"))

(fn download-html []
  (hs.task.new "Users/janfriderici/.nix-profile/bin/monolith" )
  )
  
(local org-menu-items
       [{:key :j :title :Journal :action #(noteplan :openNote?noteDate=today)}
        ;; a https://fennel-lang.org/reference#lambda%CE%BB-nil-checked-function hash funciton
        {:key :t
         :title :Task
         :action (fn []
                   (noteplan "addText?noteDate=today&mode=append&text=%2A%20"))}
	{:key :t :title "Odoo buchen" :action #(hs.urlevent.openURL"https://odoo.innoq.io/innoq/users/janf/tim%esheets/202204")}
        {:key :n
         :title :Task
         :action #(hs.eventtap.keyStroke [:ctrl :shift ] :q)}
        {:key :m
         :title "Meeting Note"
         :action #(noteplan (hs.focus)
                            (let [(_ project) (hs.dialog.textPrompt :Project
                                                                    :informativeText)]
                              (.. :addNote?noteTitle= (zettel-prefix) "%20"
                                  project
                                  "&openNote=yes&folder=20%20-%20Slip-Box")))}
        {:key :z
         :title :Zettel
         :action #(noteplan (.. :addNote?noteTitle= (zettel-prefix)
                                "&openNote=yes&folder=20%20-%20Slip-Box"))}])

((. hs.urlevent.bind) :meeting-note
                      (fn [eventName params]
                        (noteplan (.. :addNote?noteTitle= (zettel-prefix)
                                      :&openNote=yes&subWindow=yes&folder=
                                      (hs.http.encodeForQuery (. params :folder))))))

{: org-menu-items}

