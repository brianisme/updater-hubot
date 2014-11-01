on run argv
  tell application "System Preferences"
    reveal anchor "output" of pane id "com.apple.preference.sound"
    activate
    tell application "System Events"
      tell process "System Preferences"
        select (row 1 of table 1 of scroll area 1 of tab group 1 of window "Sound" whose value of text field 1 is item 1 of argv)
      end tell
    end tell
    quit
  end tell
end run
