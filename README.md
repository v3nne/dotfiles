# For a fresh Endeavour XFCE install

1. Run the install.sh script
2. Open Session and Startup
3. Select Current Session
    a) Set xfdesktop's  Restart Style to: Never
    b) Set xfwm's  Restart Style to: Never
    c) Save session
4. Reboot


### Fix panel

1. Right click bottom panel > preferences > click the `-` in the top right corner to remove
2. Click the items tab and remove the applets you don't want
3. Right click on the clock, choose layout "time only", add ` %a %b %e <b>%H:%M </b>` to its custom format
4. Right click power icon > properties > uncheck "lock screen", pick "session menu" for appearance, "cutom" for title, and paste:  
5. Right click panel > preferences > add item > add i3 workspaces plugin
