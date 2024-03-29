#!/bin/sh
#schultza.2019.9.20
#This script places a LaunchDaemon and corresponding script to force the volume to zero when an internal speaker is selected
#Some models of Mac use different internal audio speaker names. Change $Output $OutputSource as needed.
#This script was built with iMacs in mind, the hardcoded audio devices in this script should reflect all models of iMac.


#Something like: /Library/.scripts/
scriptpath=""

#Something like: NewSpeakermute.sh
scriptname=""

#Should be /Library/LaunchDaemons/
daemonpath=""

#Something like: domain.org.name.plist
deamonname=""

#Place the LaunchDaemon

cat << 'EOF' > $daemonpath/$daemonname
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$daemonname</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>$scriptpath/$scriptname</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# Set Ownership and Permissions on the Daemon
chown root:wheel $daemonpath/$daemonname
chmod 644 $daemonpath/$daemonname


#Place the Script

cat << 'EOF' > $scriptpath/$scriptname

#!/bin/sh

Console=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

if [ "$Console" = "" ]; then
echo "No Console Session. Exiting"
exit 0
else
echo "Active Console User Detected. Muting if needed"
fi

#Get default Output from System Profiler
Output=`system_profiler SPAudioDataType | grep -B 2 "Default Output Device: Yes" | head -n 1 | sed -e 's/^[ \t]*//'`
OutputSource=`system_profiler SPAudioDataType | grep "Output Source:" | cut -f2- -d: | sed -e 's/^[ \t]*//'`

echo $Output $OutputSource

if [ "$Output" = 'Built-in Output:' ] && [ "$OutputSource" = 'Internal Speakers' ]; then
  echo "Internal speakers being used, setting volume to 0"
  osascript -e "set Volume 0"
else
  echo "Internal Speakers not being used, or detected"
fi

exit 0

EOF

launchctl load $daemonpath/$daemonname

exit 0
