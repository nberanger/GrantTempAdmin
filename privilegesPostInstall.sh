#!/bin/bash

# postinstall.sh
# Marc Thielemann, 2016/08/26

ERROR=0

HELPER_PATH="$3/Applications/Utilities/Privileges.app/Contents/Library/LaunchServices/corp.sap.privileges.helper"

if [[ -f "$HELPER_PATH" ]]; then

	# create the target directory if needed
	if [[ ! -d "$3/Library/PrivilegedHelperTools" ]]; then
		/bin/mkdir -p "$3/Library/PrivilegedHelperTools"
		/bin/chmod 755 "$3/Library/PrivilegedHelperTools"
		/usr/sbin/chown -R root:wheel "$3/Library/PrivilegedHelperTools"
	fi
	
	# move the privileged helper into place
	/bin/cp -f "$HELPER_PATH" "$3/Library/PrivilegedHelperTools"
	
	if [[ $? -eq 0 ]]; then
		/bin/chmod 755 "$3/Library/PrivilegedHelperTools/corp.sap.privileges.helper"

		# create the launchd plist
		PLIST="$3/Library/LaunchDaemons/corp.sap.privileges.helper.plist"
	
		/bin/cat > "$PLIST" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>corp.sap.privileges.helper</string>
	<key>MachServices</key>
	<dict>
		<key>corp.sap.privileges.helper</key>
		<true/>
	</dict>
	<key>ProgramArguments</key>
	<array>
		<string>/Library/PrivilegedHelperTools/corp.sap.privileges.helper</string>
	</array>
</dict>
</plist>
EOF

		/bin/chmod 644 "$PLIST"
		
		# load the launchd plist only if installing on the boot volume
		if [[ "$3" = "/" ]]; then
			/bin/launchctl load -wF "$PLIST"
		fi

	else
		ERROR=1
	fi
else
	ERROR=1
fi

exit $ERROR