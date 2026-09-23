---
hidden: true
noIndex: true
---

# Firefox Deployment

Deploy Check to Firefox on Windows, macOS and Linux with Firefox's `policies.json` enterprise policy file. One file force-installs the extension, stops users from removing it, and sets Check's managed settings.

## Before you start

| Requirement       | Detail                                                                    |
| ----------------- | ------------------------------------------------------------------------- |
| Firefox version   | Firefox 142 or later on every device                                      |
| Access            | Administrator or root rights on each device                               |
| Extension package | A Mozilla-signed `.xpi` file, hosted at a URL every device can reach      |
| Extension ID      | `check@cyberdrain.com`                                                    |
| Template          | `enterprise/firefox/policies.json` in the Check repository               |

Firefox reads `policies.json` from these locations:

| Platform                        | Policy file location                                                      |
| ------------------------------- | ------------------------------------------------------------------------- |
| Windows                         | `%ProgramFiles%\Mozilla Firefox\distribution\policies.json`               |
| macOS                           | `/Applications/Firefox.app/Contents/Resources/distribution/policies.json` |
| Linux (system-wide)             | `/etc/firefox/policies/policies.json`                                     |
| Linux (installation directory)  | `/usr/lib/firefox/distribution/policies.json`                             |
| Linux (RHEL, CentOS and Fedora) | `/usr/lib64/firefox/distribution/policies.json`                           |

{% hint style="warning" %}
`policies.json` holds every Firefox policy on the device, not only Check's. If a device already has one, merge Check's entries into it instead of replacing the file.
{% endhint %}

## Build a signed package

{% stepper %}
{% step %}
### Create the Firefox package

In PowerShell on Windows, run the packaging script from the root of the Check repository:

```powershell
.\Prepare-StorePackage.ps1 -Version 1.2.0
```

Set `-Version` to the version you are packaging. The script writes `check-extension-firefox-v<version>.zip` to the `store-packages` folder, containing only the files the extension needs and the Firefox manifest.
{% endstep %}

{% step %}
### Sign the package with Mozilla

Upload the Firefox package to [addons.mozilla.org](https://addons.mozilla.org/developers/) and choose unlisted distribution, which signs the add-on for you to host yourself.
{% endstep %}

{% step %}
### Host the signed file

Download the signed `.xpi` file and host it on a web server every device can reach. You need its URL for `policies.json`.
{% endstep %}
{% endstepper %}

## Configure policies.json

Start from `enterprise/firefox/policies.json` in the repository. Firefox's own policies install and lock the extension:

| Field                                                   | Value                           |
| ------------------------------------------------------- | ------------------------------- |
| `Extensions` > `Install`                                | The URL of your signed `.xpi`   |
| `Extensions` > `Locked`                                 | `check@cyberdrain.com`          |
| `ExtensionSettings` > `check@cyberdrain.com` > `installation_mode` | `force_installed`    |
| `ExtensionSettings` > `check@cyberdrain.com` > `install_url`       | The URL of your signed `.xpi` |
| `ExtensionSettings` > `check@cyberdrain.com` > `default_area`      | `navbar`             |

Check's own settings go under `3rdparty` > `Extensions` > `check@cyberdrain.com`. This example force-installs Check, adds branding, allowlists one site and sends events to a webhook. `policies.json` must be plain JSON, with no comments:

```json
{
  "policies": {
    "Extensions": {
      "Install": ["https://files.example.com/check/check-extension.xpi"],
      "Locked": ["check@cyberdrain.com"]
    },
    "ExtensionSettings": {
      "check@cyberdrain.com": {
        "installation_mode": "force_installed",
        "install_url": "https://files.example.com/check/check-extension.xpi",
        "default_area": "navbar"
      }
    },
    "3rdparty": {
      "Extensions": {
        "check@cyberdrain.com": {
          "enablePageBlocking": true,
          "enableValidPageBadge": true,
          "validPageBadgeTimeout": 5,
          "updateInterval": 24,
          "urlAllowlist": ["https://trusted-domain.com/*"],
          "customBranding": {
            "companyName": "Contoso",
            "productName": "Contoso Phishing Protection",
            "supportEmail": "helpdesk@contoso.com",
            "primaryColor": "#F77F00",
            "logoUrl": "https://contoso.com/logo.png"
          },
          "genericWebhook": {
            "enabled": true,
            "url": "https://webhook.example.com/endpoint",
            "events": ["page_blocked", "rogue_app_detected", "false_positive_report"]
          }
        }
      }
    }
  }
}
```

{% hint style="info" %}
When `policies.json` sets any Check setting, the options page hides the **General**, **Detection Rules** and **Branding** sections from users and shows **Managed by Policy**.
{% endhint %}

### Check policy keys

Set only the keys you want to enforce. Nested keys are shown as dotted paths: `customBranding.primaryColor` is `primaryColor` inside the `customBranding` object.

| Key                                   | Type                                 | Default                                        | Description                                                                                                                                                                                     |
| ------------------------------------- | ------------------------------------ | ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `enablePageBlocking`                  | Boolean                              | `true`                                         | Blocks detected phishing pages. When `false`, Check shows a warning banner on the page instead of blocking it.                                                                                 |
| `showNotifications`                   | Boolean                              | `true`                                         | Shows a warning banner when a site looks like one of your protected domains.                                                                                                                    |
| `enableValidPageBadge`                | Boolean                              | `true`                                         | Shows a **Verified Microsoft Domain** badge on genuine Microsoft sign-in pages.                                                                                                                 |
| `validPageBadgeTimeout`               | Integer, 0 to 300                    | `5`                                            | Seconds before the badge closes itself. `0` keeps it open until the user closes it.                                                                                                             |
| `enableCippReporting`                 | Boolean                              | `false`                                        | Sends detections to your CIPP instance. Needs `cippServerUrl` as well.                                                                                                                          |
| `cippServerUrl`                       | String (URL)                         | Blank                                          | Base URL of your CIPP instance, including `https://`.                                                                                                                                           |
| `cippTenantId`                        | String                               | Blank                                          | Tenant ID or domain sent with each CIPP report.                                                                                                                                                 |
| `customRulesUrl`                      | String (URL)                         | Blank, which uses the rules CyberDrain publishes | URL of a detection rules file. The file replaces the published rules entirely, so start from a full copy. See [creating-detection-rules.md](../advanced/creating-detection-rules.md "mention"). |
| `updateInterval`                      | Integer, 1 to 168                    | `24`                                           | Hours between detection rule updates.                                                                                                                                                           |
| `urlAllowlist`                        | Array of strings                     | Empty                                          | URLs Check never flags. Each entry matches from the start of the full URL, and `*` is a wildcard, for example `https://trusted-domain.com/*`. An entry starting with `^` is read as a regular expression. |
| `enableDebugLogging`                  | Boolean                              | `false`                                        | Also records page scans and legitimate sign-ins in **Activity Logs**, for troubleshooting. Security events are recorded either way.                                                          |
| `genericWebhook.enabled`              | Boolean                              | `false`                                        | Sends Check events to your webhook.                                                                                                                                                             |
| `genericWebhook.url`                  | String (URL)                         | Blank                                          | The endpoint that receives the events.                                                                                                                                                          |
| `genericWebhook.events`               | Array of strings                     | Empty                                          | The event types to send. See [webhooks.md](../webhooks.md "mention") for each event type and its payload.                                                                                     |
| `customBranding.companyName`          | String                               | Blank                                          | Your company name, shown in the extension.                                                                                                                                                      |
| `customBranding.productName`          | String                               | Blank, which shows **Check**                   | The extension name users see.                                                                                                                                                                   |
| `customBranding.supportEmail`         | String (email address)               | Blank                                          | The address the **Contact Admin** button on the block page emails. The button only appears when this is set.                                                                                   |
| `customBranding.supportUrl`           | String (URL)                         | Blank                                          | Opened by the popup's **Support** link.                                                                                                                                                         |
| `customBranding.privacyPolicyUrl`     | String (URL)                         | Blank                                          | Opened by the popup's **Privacy** link.                                                                                                                                                         |
| `customBranding.aboutUrl`             | String (URL)                         | Blank                                          | Opened by the popup's **About** link.                                                                                                                                                           |
| `customBranding.primaryColor`         | String (hex colour)                  | `#F77F00`                                      | Theme colour, as `#RRGGBB` or `#RGB`.                                                                                                                                                           |
| `customBranding.logoUrl`              | String (URL)                         | Blank                                          | Your logo, shown in place of Check's.                                                                                                                                                           |
| `domainSquatting.enabled`             | Boolean                              | `false`                                        | Warns about or blocks lookalikes of the domains in `urlAllowlist`. See [domain-squatting-detection.md](../features/domain-squatting-detection.md "mention").                                   |
| `domainSquatting.deviationThreshold`  | Integer, 1 to 5                      | `2`                                            | The most characters a lookalike can differ by and still be caught. Lower values are stricter.                                                                                                  |
| `domainSquatting.Action`              | String: `block`, `warn` or `log`     | `block`                                        | What Check does when it finds a lookalike domain. The key starts with a capital `A`.                                                                                                           |
| `domainSquatting.algorithms.levenshtein` | Boolean                           | `true`                                         | Catches domains with a few characters changed.                                                                                                                                                  |
| `domainSquatting.algorithms.homoglyph`   | Boolean                           | `true`                                         | Turns the look-alike character check on or off.                                                                                                                                                 |
| `domainSquatting.algorithms.typosquat`   | Boolean                           | `true`                                         | Catches common typing mistakes and swapped characters.                                                                                                                                          |
| `domainSquatting.algorithms.combosquat`  | Boolean                           | `true`                                         | Catches domains with words added before or after yours.                                                                                                                                         |

## Deploy the policy file

{% tabs %}
{% tab title="Windows" %}
### Manual deployment

{% stepper %}
{% step %}
#### Create the distribution folder

```powershell
New-Item -ItemType Directory -Force -Path "$env:ProgramFiles\Mozilla Firefox\distribution"
```
{% endstep %}

{% step %}
#### Copy the policy file

```powershell
Copy-Item policies.json "$env:ProgramFiles\Mozilla Firefox\distribution\policies.json"
```
{% endstep %}

{% step %}
#### Restart Firefox

Firefox reads `policies.json` when it starts.
{% endstep %}
{% endstepper %}

### Intune or RMM deployment

Package this script with your `policies.json` and run it as SYSTEM from Intune or your RMM tool:

```powershell
$policiesPath = "$env:ProgramFiles\Mozilla Firefox\distribution"
New-Item -ItemType Directory -Force -Path $policiesPath | Out-Null
Copy-Item -Path "$PSScriptRoot\policies.json" -Destination "$policiesPath\policies.json" -Force
```

### Group Policy

Firefox also reads policy from Group Policy through Mozilla's ADMX templates. Download them, and read how each policy maps to `policies.json`, at [Mozilla's policy templates](https://github.com/mozilla/policy-templates).
{% endtab %}

{% tab title="macOS" %}
### Manual deployment

{% stepper %}
{% step %}
#### Create the distribution folder

```bash
sudo mkdir -p "/Applications/Firefox.app/Contents/Resources/distribution"
```
{% endstep %}

{% step %}
#### Copy the policy file

```bash
sudo cp policies.json "/Applications/Firefox.app/Contents/Resources/distribution/policies.json"
```
{% endstep %}

{% step %}
#### Set ownership and permissions

```bash
sudo chmod 644 "/Applications/Firefox.app/Contents/Resources/distribution/policies.json"
sudo chown root:wheel "/Applications/Firefox.app/Contents/Resources/distribution/policies.json"
```
{% endstep %}

{% step %}
#### Restart Firefox

Firefox reads `policies.json` when it starts.
{% endstep %}
{% endstepper %}

### MDM deployment

Deploy this as a script payload from your MDM, for example Jamf or Intune. Replace `{"policies": {}}` with the full contents of your `policies.json`:

```bash
#!/bin/bash

POLICIES_DIR="/Applications/Firefox.app/Contents/Resources/distribution"
POLICIES_FILE="$POLICIES_DIR/policies.json"

mkdir -p "$POLICIES_DIR"

cat > "$POLICIES_FILE" << 'EOF'
{"policies": {}}
EOF

chmod 644 "$POLICIES_FILE"
chown root:wheel "$POLICIES_FILE"
```
{% endtab %}

{% tab title="Linux" %}
### Manual deployment

{% stepper %}
{% step %}
#### Create the policies folder

```bash
sudo mkdir -p /etc/firefox/policies
```
{% endstep %}

{% step %}
#### Copy the policy file

```bash
sudo cp policies.json /etc/firefox/policies/policies.json
```
{% endstep %}

{% step %}
#### Set permissions

```bash
sudo chmod 644 /etc/firefox/policies/policies.json
```
{% endstep %}

{% step %}
#### Restart Firefox

Firefox reads `policies.json` when it starts.
{% endstep %}
{% endstepper %}

If your distribution installs Firefox elsewhere, use the matching path from the table in [Before you start](#before-you-start).

### Configuration management

With Ansible:

```yaml
- name: Deploy Firefox Check Extension Policy
  copy:
    src: policies.json
    dest: /etc/firefox/policies/policies.json
    owner: root
    group: root
    mode: '0644'
```

With Puppet:

```puppet
file { '/etc/firefox/policies':
  ensure => directory,
  mode   => '0755',
}

file { '/etc/firefox/policies/policies.json':
  ensure  => file,
  source  => 'puppet:///modules/firefox/policies.json',
  mode    => '0644',
  require => File['/etc/firefox/policies'],
}
```
{% endtab %}
{% endtabs %}

## Verify the deployment

{% stepper %}
{% step %}
### Check the policies loaded

Open `about:policies` in Firefox. Your policies appear under **Active Policies**, and any error in the file is listed there too.
{% endstep %}

{% step %}
### Check the extension installed

Open `about:addons`. Check is installed and shows **Managed by your organization**. When `check@cyberdrain.com` is in `Locked`, users cannot disable or remove it.
{% endstep %}

{% step %}
### Check detection works

Open a test page and confirm Check blocks it or shows a warning, and that your branding appears. [testing-check.md](../troubleshooting/testing-check.md "mention") covers the test pages in the repository.
{% endstep %}
{% endstepper %}

## Update Check

Build and sign the new version as in [Build a signed package](#build-a-signed-package), and host it. If its URL changes, update `Install` and `install_url` in `policies.json` and deploy the file again.

## Remove Check

See [firefox.md](../removal/windows/firefox.md "mention").

## Troubleshooting

<details>

<summary>My policies don't show up in about:policies</summary>

* Confirm `policies.json` is at the right path for the platform, in the table in [Before you start](#before-you-start).
* Confirm Firefox can read the file. `644` permissions work on macOS and Linux.
* Validate the JSON. Plain JSON allows no comments and no trailing commas.
* Restart Firefox, which reads the file only at startup.

</details>

<details>

<summary>Check doesn't install</summary>

* Confirm the `.xpi` is signed by Mozilla. Firefox refuses unsigned add-ons.
* Open the `install_url` from an affected device to confirm the URL is reachable through any firewall or proxy.
* Confirm the device runs Firefox 142 or later.

</details>

<details>

<summary>Check installs, but my settings aren't applied</summary>

* Confirm the settings are under `3rdparty` > `Extensions` > `check@cyberdrain.com`, spelt exactly.
* Confirm each key matches the [Check policy keys](#check-policy-keys) table, including case.
* Restart Firefox after changing the file.

</details>

<details>

<summary>Users can still disable or remove Check</summary>

* Confirm `check@cyberdrain.com` is in the `Locked` list.
* Confirm `installation_mode` is `force_installed`.
* Restart Firefox after deploying the file.

</details>

## Further reading

* [firefox-support.md](../firefox-support.md "mention")
* [Mozilla policy templates](https://github.com/mozilla/policy-templates)
* [Firefox for Enterprise](https://support.mozilla.org/en-US/products/firefox-enterprise)
