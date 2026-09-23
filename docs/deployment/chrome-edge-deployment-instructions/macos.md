---
icon: apple
---

# macOS

Deploy Check through your MDM to install it in Chrome and Edge without any user interaction. For a single Mac, a command-line script can add Check to Chrome instead, but each user then has to approve the extension.

{% tabs %}
{% tab title="MDM" %}
Most MDMs accept a custom `.mobileconfig` profile, which you can use when your MDM has no built-in profile builder for Google Chrome or Microsoft Edge.

## Build the profile

This sample profile force-installs Check in Google Chrome and Microsoft Edge. It only installs the extension: it sets no Check settings, so Check runs with its defaults and users can change them.

Before you upload it:

* Replace each `REPLACE-WITH-UUID` placeholder with a new UUID. Run `uuidgen` in Terminal once per placeholder, and use the same UUID in a payload's `PayloadIdentifier` and `PayloadUUID`.
* Replace `YOUR ORG NAME` with your organisation's name.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>ExtensionInstallForcelist</key>
			<array>
				<string>benimdeioplgkhanklclahllklceahbe</string>
			</array>
			<key>PayloadDisplayName</key>
			<string>Google Chrome</string>
			<key>PayloadIdentifier</key>
			<string>com.google.Chrome.REPLACE-WITH-UUID-1</string>
			<key>PayloadType</key>
			<string>com.google.Chrome</string>
			<key>PayloadUUID</key>
			<string>REPLACE-WITH-UUID-1</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
		</dict>
		<dict>
			<key>ExtensionInstallForcelist</key>
			<array>
				<string>knepjpocdagponkonnbggpcnhnaikajg</string>
			</array>
			<key>PayloadDisplayName</key>
			<string>Microsoft Edge</string>
			<key>PayloadIdentifier</key>
			<string>com.microsoft.Edge.REPLACE-WITH-UUID-2</string>
			<key>PayloadType</key>
			<string>com.microsoft.Edge</string>
			<key>PayloadUUID</key>
			<string>REPLACE-WITH-UUID-2</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>PayloadDescription</key>
	<string>This profile installs and enforces the 'Check' browser extension from CyberDrain on Google Chrome and Microsoft Edge web browsers. </string>
	<key>PayloadDisplayName</key>
	<string>Check CyberDrain</string>
	<key>PayloadIdentifier</key>
	<string>REPLACE-WITH-UUID-3</string>
	<key>PayloadOrganization</key>
	<string>YOUR ORG NAME</string>
	<key>PayloadScope</key>
	<string>System</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>REPLACE-WITH-UUID-3</string>
	<key>PayloadVersion</key>
	<integer>1</integer>
	<key>RemovalDate</key>
	<date>2044-05-19T21:46:44Z</date>
	<key>TargetDeviceType</key>
	<integer>5</integer>
</dict>
</plist>
```
{% endtab %}

{% tab title="Command line" %}
This script adds Check to Chrome for every user on the Mac by writing an external extension file under `/Library`. Run with no argument, it adds Check. Pass a different Chrome extension ID as the argument to add that extension instead. The script is adapted from a script by @cezaraugusto.

## Run the script

Save the script as `install_extension.sh` and run it with `sudo`, because it writes to `/Library`:

```bash
sudo bash install_extension.sh
```

```bash
#!/bin/bash

# https://developer.chrome.com/docs/extensions/mv3/external_extensions/#preferences
# Credit to #cezaraugusto# from GitHub Gist for this script, modified to install Check by CyberDrain if no parameter is passed
# https://gist.github.com/cezaraugusto
# https://gist.github.com/cezaraugusto/0101d2cb251c088f398ca0f8d4495ca0

if [ $# -gt 1 ]; then
  echo "Usage: $0 [extension_id]"
  exit 1
fi

extension="${1:-benimdeioplgkhanklclahllklceahbe}"

install_chrome_extension() {
  chrome_extensions_folder="/Library/Application Support/Google/Chrome/External Extensions"
  chrome_extensions_preferences_file="$chrome_extensions_folder/$extension.json"
  # This URL is used by Chrome to check for updates to external extensions
  update_services_url="https://clients2.google.com/service/update2/crx"

  if [[ ! -d "$chrome_extensions_folder" ]]; then
    mkdir -p "$chrome_extensions_folder"
  fi

  echo "{" > "$chrome_extensions_preferences_file"
  echo "  \"external_update_url\": \"$update_services_url\"" >> "$chrome_extensions_preferences_file"
  echo "}" >> "$chrome_extensions_preferences_file"

  echo "Added \"$chrome_extensions_preferences_file\""
}

install_chrome_extension

# Usage:
# sudo ./install_extension.sh                  (installs Check)
# sudo ./install_extension.sh <extension_id>   (installs another extension)
# Sample: adding React Dev Tools from the command line to Chrome
# sudo ./install_extension.sh fmkadmapgofadopljbjfkapdkoienihi
```

## Approve the extension

Chrome adds the extension the next time it starts, then asks the user to approve it. The user selects **Enable Extension** to turn Check on. Because each user has to approve it, and can select **Remove from Chrome** instead, deploy through your MDM wherever you can.

<img width="448" height="330" alt="Chrome's prompt that Check by CyberDrain was added, with Remove from Chrome and Enable Extension buttons" src="https://github.com/user-attachments/assets/f53a13fe-c16b-4941-aa39-0799b2b32b6e" />
{% endtab %}
{% endtabs %}
