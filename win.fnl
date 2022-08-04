(require-macros :lib.macros)

;; https://github.com/Hammerspoon/hammerspoon/issues/175
;; Dome windows are very slow to respond and don't interest at all. This
;; removes them. The window filter should be used in all other parts of the system.

; ;;> hs.window._timed_allWindows()
; 2022-07-23 12:12:45: took 0.28s for com.apple.appkit.xpc.openAndSavePanelService
; 2022-07-23 12:12:45: took 0.09s for org.languagetool.safari.extension
; 2022-07-23 12:12:45: took 1.20s for org.pqrs.Karabiner-EventViewer
; 2022-07-23 12:12:45: took 0.14s for com.hegenberg.BetterTouchToolAppleScriptRunner
; 2022-07-23 12:12:45: took 0.15s for com.apple.Safari.SandboxBroker
; 2022-07-23 12:12:45: took 0.10s for com.apple.AccountProfileRemoteViewService
; 2022-07-23 12:12:45: took 0.20s for com.apple.SafariPlatformSupport.Helper
; 2022-07-23 12:12:45: took 1.35s for com.apple.WebKit.WebContent
; 2022-07-23 12:12:45: took 0.06s for com.devon-technologies.think3.clipper
; 2022-07-23 12:12:45: took 0.10s for com.agilebits.onepassword7.1PasswordSafariAppExtension
; 2022-07-23 12:12:45: took 0.49s for com.apple.quicklook.QuickLookUIService
; 2022-07-23 12:12:45: took 0.16s for com.apple.ViewBridgeAuxiliary
; 2022-07-23 12:12:45: took 6.00s for com.surteesstudios.Bartender
; 2022-07-23 12:12:45: took 6.00s for com.grammarly.ProjectLlama
; 2022-07-23 12:12:45: took 0.16s for com.apple.inputmethod.EmojiFunctionRowItem
; 2022-07-23 12:12:45: took 0.05s for com.apple.preferences.internetaccounts.remoteservice
; 2022-07-23 12:12:45: took 0.40s for com.apple.AvatarUI.AvatarPickerMemojiPicker
; 2022-07-23 12:12:45: took 0.14s for com.apple.PressAndHold

; 2nd time
; 2022-07-23 12:14:03: took 1.61s for org.pqrs.Karabiner-EventViewer
; 2022-07-23 12:14:03: took 5.45s for info.eurocomp.Timing-setapp.TimingHelper
; 2022-07-23 12:14:03: took 0.13s for com.apple.WebKit.WebContent
; 2022-07-23 12:14:03: took 2.67s for dexterleng.vimac
; 2022-07-23 12:14:03: took 6.00s for com.grammarly.ProjectLlama
;;
(local candidates [:AppSSOAgent
                   :talagent
                  ; :Safari
                   :BetterTouchTool
                   :CoreLocationAgent
                   ;:Notes
                   "Control Centre"
                   "Location Menu"
                   :NowPlayingTouchUI
                   "dexterleng.vimac"
                   "org.pqrs.Karabiner-EventViewer"
                   "Safari Web Content (Prewarmed)"
                   "info.eurocomp.Timing-setapp.TimingHelper"
                   "Dock Extra"
                   "Mail Networking"
                   "Fantastical Helper"
                   "1Password 7"
                   "1Password Extension Helper"
                   "Keyboard Maestro Engine"
                   :Menuwhere
                   "Script Menu"
                   :TextInputMenuAgent
                   :TextInputSwitcher
                   "Default Folder X"
                   :Bunch
                   :witchdaemon
                   :HazelHelper
                   :Alfred
                   "Shortcuts Events"
                   "Logi Options Daemon"
                   "NTFS for Mac"
                   :Karabiner-NotificationWindow
                   :Karabiner-Menu
                   :SoftwareUpdateNotificationManager
                   "Mail Graphics and Media"
                   "Microsoft Teams Helper (Renderer)"
                   :universalAccessAuthWarn
                   :DockHelper
                   "Dash Networking"
                   "Dash Web Content"
                   "Notification Centre"
                   :coreautha
                   :MirrorDisplays
                   "com.surteesstudios.Bartender"
                   "com.grammarly.ProjectLlama"
                   "FirefoxCP Privileged Content"
                   "FirefoxCP WebExtensions"
                   "FirefoxCP Isolated Web Content"
                   "FirefoxCP Web Content"])

(each [_ name (pairs candidates)]
  (tset hs.window.filter.ignoreAlways name true))

(tset hs.window.filter.ignoreAlways :com.apple.WebKit.WebContent true)
(tset hs.window.filter.ignoreAlways :com.paragon-software.ntfs.fsapp true)
(tset hs.window.filter.ignoreAlways :com.runningwithcrayons.Alfred true)
(tset hs.window.filter.ignoreAlways :com.apple.WebKit.WebContent true)
(tset hs.window.filter.ignoreAlways "PaymentAuthorizationUIExtension (Safari)"
      true)

(tset hs.window :animationDuration  0.0)

(tset hs.window.filter.ignoreAlways
      :com.apple.appkit.xpc.openAndSavePanelService true)

(tset hs.window.filter.ignoreAlways
      :com.apple.PassKit.PaymentAuthorizationUIExtension true)

(local wf (hs.window.filter.copy hs.window.filter.defaultCurrentSpace )); {:override {:currentSpace false}}

(fn all-windows []
  (: wf :getWindows))


(fn app-name [win]
  (-> win
      (: :application)
      (: :title)))

(fn get-windows []
    "fetch a list of all windows and make them nice for a chooser"
  (let [focused (hs.window.focusedWindow)]
    (icollect [_ window (ipairs (all-windows))]
      (when (not= window focused)
        {:text (app-name window)
         :id (: window :id)
         : window
         : focused
         :image (hs.image.imageFromAppBundle (: (: window :application)
                                                :bundleID))
         :subText (: window :title)}))))

(fn toggle-window [window]
    (print (fennel.view window))
    (: (. window :window) :focus))

(fn select-window []
    (let [windows get-windows
          chooser (hs.chooser.new toggle-window)]
        (: chooser :choices windows)
        (: chooser :searchSubText true)
        (: chooser :show)))
{
    : all-windows
    : wf
    : get-windows
    : select-window
    :hints (fn [] (hs.hints.windowHints (all-windows)))
}