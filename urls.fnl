(local {: contains?
        : for-each
        : map
        : filter
        : merge
        : reduce
        : split
        : some
        : concat} (require :lib.functional))

; TODO make this
(fn appID [app]
  (. (hs.application.infoForBundlePath app) :CFBundleIdentifier))

(local chromeBrowser (appID :/Applications/Chromium.app))
(local vivaldiBrowser (appID :/Applications/Vivaldi.app))
(local edgeBrowser (appID "/Applications/Microsoft Edge.app"))
(local firefoxBrowser (appID :/Applications/Firefox.app))
(local safariBrowser (appID :/Applications/Safari.app))

(local DefaultBrowser safariBrowser)
(local WorkBrowser safariBrowser)
(local BestsecretBrowser edgeBrowser)

;; see https://www.lua.org/pil/20.2.html for the pattern format
(local best-secret [
  ["mailto:.*" "com.apple.mail"]
  ["https?://jira%.bestsecret%.com/.*" BestsecretBrowser] 
  ["https?://.*azure%.elastic%-cloud%.com.*" BestsecretBrowser] 
  ["https?://confluence%.bestsecret%.com/.*" BestsecretBrowser]
  ["https://gitlab.com/bestsecret.*" BestsecretBrowser]
  ["https://confluence.bestsecret.com/" BestsecretBrowser]
  ["https://eur02.safelinks.protection.outlook.com/.*" BestsecretBrowser]
  ["https?://miro.com/app/board/uXjVOVejE5E=/" BestsecretBrowser]])

(local innoq [
  ["https?://.*%.microsoft.com/.*" WorkBrowser]
  ["https?://.*%.innoq.com" WorkBrowser]])


; https://eur02.safelinks.protection.outlook.com/?url=https%3A%2F%2Fconfluence.bestsecret.com%2Fpages%2Fviewpage.action%3FpageId%3D120165953%26src%3Dmail%26src.mail.product%3Dconfluence-server%26src.mail.timestamp%3D1644225610173%26src.mail.notification%3Dcom.atlassian.confluence.plugins.confluence-notifications-batch-plugin%253Abatching-notification%26src.mail.recipient%3D8ab4b41b7daf863d017e67a53b0b0037%26src.mail.action%3Dview&data=04%7C01%7Cjan.friderici.ext%40bestsecret.com%7Ca085e1ea91524d36eb4308d9ea1b0a36%7Ca1fb958752bd474798f6fe75d79c584f%7C0%7C0%7C637798224125808618%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&sdata=N%2BJbbf1Eq2wsBNiykaRA0tHQdpNeHoFqon5JKGzxT4k%3D&reserved=0
(spoon.SpoonInstall:andUse :URLDispatcher
                                   {:config {:url_patterns  (concat best-secret innoq)
                                             :url_redir_decoders [;; Send MS Teams URLs directly to the app
                                                                  ;;[ "MS Teams URLs" "(https://teams.microsoft.com.*)" "msteams:%1" true ]
                                                                  ;; Preview incorrectly encodes the anchor
                                                                  ;; character in URLs as %23, we fix it
                                                                  ["Fix broken Preview anchor URLs"
                                                                   "%%23"
                                                                   "#"
                                                                   false
                                                                   :Preview]]
                                             :default_handler DefaultBrowser}
                                    :start true})
