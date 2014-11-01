#!/bin/sh
# choosespeak='select (row 1 of table 1 of scroll area 1 of tab group 1 of window "Sound" whose value of text field 1 is "'$1'")'
# echo $choosespeak
# osascript -e 'tell application "System Preferences"' -e 'reveal anchor "output" of pane id "com.apple.preference.sound"' -e 'activate' -e 'tell application "System Events"' -e 'tell process "System Preferences"' -e $choosespeak -e 'end tell' -e 'end tell' -e 'quit' -e 'end tell'
osascript scripts/choose_speaker.scpt "$1"
