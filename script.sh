#!/bin/sh
#schultza.2019.9.20

cat << 'EOF' > /Library/LaunchDaemons/edu.uwm.cts.newspeakermute.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>edu.uwm.cts.newspeakermute</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Library/.uwm/newspeakermute.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer>1</integer>
</dict>
</plist>
EOF

# Set Ownership and Permissions on the script
chown root:wheel /Library/LaunchDaemons/edu.uwm.cts.newspeakermute.plist
chmod 644 /Library/LaunchDaemons/edu.uwm.cts.newspeakermute.plist

cat << 'EOF' > /Library/.uwm/newspeakermute.sh

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
  echo "Speakers not detected"
fi

exit 0


EOF

exit 0
