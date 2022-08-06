(print (fennel.view hs.grid.HINTS))
;;;
;
; This assumes That I want 6 colums and 3 rows as it can be devided by 2 and 3 and be split to the home blocks on
;; the left and right hands.
;
(local qwerty-hints hs.grid.HINTS)

(set hs.hotkey.setLogLevel 5)
(print (fennel.view hs.grid.HINTS))
(print (fennel.view hs.keycodes.map))

;; setup the grid -- TODO this won't work with my current Setup because () are unmapped.
(let [my-grid-hints [[:f1 :f2 :f3 :f4 :f5 :f6]
                     [:1 :2 :3 :4 :5 :6]
                     [:g :h :p "p" "(" ")"]
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

;; Keymap!
; {0 "a"
;  1 "s"
;  2 "d"
;  3 "f"
;  4 "h"
;  5 "g"
;  6 "z"
;  7 "x"
;  8 "c"
;  9 "v"
;  10 "§"
;  11 "b"
;  12 "q"
;  13 "w"
;  14 "e"
;  15 "r"
;  16 "y"
;  17 "t"
;  18 "1"
;  19 "2"
;  20 "3"
;  21 "4"
;  22 "6"
;  23 "5"
;  24 "="
;  25 "9"
;  26 "7"
;  27 "-"
;  28 "8"
;  29 "0"
;  30 "]"
;  31 "o"
;  32 "u"
;  33 "["
;  34 "i"
;  35 "p"
;  36 "return"
;  37 "l"
;  38 "j"
;  39 "'"
;  40 "k"
;  41 ";"
;  42 "\\"
;  43 ","
;  44 "/"
;  45 "n"
;  46 "m"
;  47 "."
;  48 "tab"
;  49 "space"
;  50 "`"
;  51 "delete"
;  53 "escape"
;  54 "rightcmd"
;  55 "cmd"
;  56 "shift"
;  57 "capslock"
;  58 "alt"
;  59 "ctrl"
;  60 "rightshift"
;  61 "rightalt"
;  62 "rightctrl"
;  63 "fn"
;  64 "f17"
;  65 "pad."
;  67 "pad*"
;  69 "pad+"
;  71 "padclear"
;  75 "pad/"
;  76 "padenter"
;  78 "pad-"
;  79 "f18"
;  80 "f19"
;  81 "pad="
;  82 "pad0"
;  83 "pad1"
;  84 "pad2"
;  85 "pad3"
;  86 "pad4"
;  87 "pad5"
;  88 "pad6"
;  89 "pad7"
;  90 "f20"
;  91 "pad8"
;  92 "pad9"
;  93 "yen"
;  94 "underscore"
;  95 "pad,"
;  96 "f5"
;  97 "f6"
;  98 "f7"
;  99 "f3"
;  100 "f8"
;  101 "f9"
;  102 "eisu"
;  103 "f11"
;  104 "kana"
;  105 "f13"
;  106 "f16"
;  107 "f14"
;  109 "f10"
;  111 "f12"
;  113 "f15"
;  114 "help"
;  115 "home"
;  116 "pageup"
;  117 "forwarddelete"
;  118 "f4"
;  119 "end"
;  120 "f2"
;  121 "pagedown"
;  122 "f1"
;  123 "left"
;  124 "right"
;  125 "down"
;  126 "up"
;  " " 104
;  "'" 39
;  "," 95
;  :- 27
;  :. 47
;  :/ 44
;  :0 29
;  :1 18
;  :2 19
;  :3 20
;  :4 21
;  :5 23
;  :6 22
;  :7 26
;  :8 28
;  :9 25
;  ";" 41
;  := 24
;  "[" 33
;  "\\" 42
;  "]" 30
;  "`" 50
;  :a 0
;  :alt 58
;  :b 11
;  :c 8
;  :capslock 57
;  :cmd 55
;  :ctrl 59
;  :d 2
;  :delete 51
;  :down 125
;  :e 14
;  :eisu 102
;  :end 119
;  :escape 53
;  :f 3
;  :f1 122
;  :f10 109
;  :f11 103
;  :f12 111
;  :f13 105
;  :f14 107
;  :f15 113
;  :f16 106
;  :f17 64
;  :f18 79
;  :f19 80
;  :f2 120
;  :f20 90
;  :f3 99
;  :f4 118
;  :f5 96
;  :f6 97
;  :f7 98
;  :f8 100
;  :f9 101
;  :fn 63
;  :forwarddelete 117
;  :g 5
;  :h 4
;  :help 114
;  :home 115
;  :i 34
;  :j 38
;  :k 40
;  :kana 104
;  :l 37
;  :left 123
;  :m 46
;  :n 45
;  :o 31
;  :p 35
;  :pad* 67
;  :pad+ 69
;  "pad," 95
;  :pad- 78
;  :pad. 65
;  :pad/ 75
;  :pad0 82
;  :pad1 83
;  :pad2 84
;  :pad3 85
;  :pad4 86
;  :pad5 87
;  :pad6 88
;  :pad7 89
;  :pad8 91
;  :pad9 92
;  :pad= 81
;  :padclear 71
;  :padenter 76
;  :pagedown 121
;  :pageup 116
;  :q 12
;  :r 15
;  :return 36
;  :right 124
;  :rightalt 61
;  :rightcmd 54
;  :rightctrl 62
;  :rightshift 60
;  :s 1
;  :shift 56
;  :space 49
;  :t 17
;  :tab 48
;  :u 32
;  :underscore 94
;  :up 126
;  :v 9
;  :w 13
;  :x 7
;  :y 16
;  :yen 93
;  :z 6
;  "§" 10}
