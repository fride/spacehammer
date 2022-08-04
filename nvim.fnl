(local windows (require :windows))


(defn open-in-vim scropt [paths]
    (..
    "set paths to \"\"\n"
	"repeat with i from 1 to length of input\n"
	"	set cur to item i of input\n"
	"	set paths to " paths " & \" \" & quote & POSIX path of cur & quote\n"
	"end repeat\n"
	"set cmd to \"nvim -p\" & paths\n"
	"tell application \"iTerm\""
	"	set created to false\n"
	"	if not (exists current window) then\n"
	"		create window with profile \"Default\"\n"
	"		set created to true\n"
	"	end if\n"
	"	tell current window\n"
	"		if not created then\n"
	"			create tab with profile \"Default\"\n"
	"		end if\n"
	"		tell current session\n"
	"			activate\n"
	"			write text cmd\n"
	"		end tell\n"
	"	end tell\n"
	"end tell\n"))