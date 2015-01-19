BROWSER="Google Chrome"
#BROWSER="Firefox"

function chrome() {
osascript << EOF
		  tell application "Google Chrome"
		  reload active tab of window 1
		  end tell 
EOF
}

function firefox() {
osascript << EOF
activate application "Firefox"
tell application "System Events" to keystroke "R" using command down

EOF
}
firefox
chrome
echo "Calling reload on Chrome"
