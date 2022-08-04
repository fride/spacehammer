
(local u (require "utils"))

(fn connect [name] 
    (-> (.. "tell application \"Viscosity\" to connect \"" name "\"")
    (u.run-script)))

(fn disconnect [name] 
    (-> (.. "tell application \"Viscosityi\" to disconnect \"" name "\"")
    (u.run-script)))
    
(local vpn-menu [
    u.return
    {:key :c :title "Connect VPM" :action #(connect "Jan.Friderici@vpn.bestsecrettec.com")}
    {:key :d :title "Disconnect VPM" :action #(disconnect "Jan.Friderici@vpn.bestsecrettec.com")}
])


{
    : vpn-menu
}