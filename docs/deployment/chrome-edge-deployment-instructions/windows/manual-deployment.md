# Manual Deployment

Deploy Check to Chrome and Edge on a single Windows device, or through any tool that can run a PowerShell script, and load a local copy of the extension for development.

{% tabs %}
{% tab title="PowerShell" %}
`Deploy-Windows-Chrome-and-Edge.ps1` force-installs Check in both Chrome and Edge, pins it to the toolbar, and applies your settings as managed policy. Edit the variables at the top of the script, then run it on the endpoint or paste it into your RMM's scripting engine.

<a href="https://raw.githubusercontent.com/CyberDrain/Check/refs/heads/main/enterprise/Deploy-Windows-Chrome-and-Edge.ps1" class="button primary">Download the Script from GitHub</a>

{% hint style="info" %}
The script deploys to both browsers. Keep both, even if your organisation standardises on one, so that Check still protects anyone who opens the other browser.
{% endhint %}

## Run the script

The script writes to `HKEY_LOCAL_MACHINE`, so run it as Administrator or as SYSTEM. In an RMM, choose the option that runs the script as the system account.

The script has no parameters and reads no environment variables. Set every value by editing the variables in the script body before you run it.

{% hint style="warning" %}
The script sets every variable below as managed policy, including the ones you leave unchanged and the ones left blank. Users cannot change a managed setting in Check, so decide on each value before you deploy.
{% endhint %}

## Script variables

Where the script's value differs from Check's own default, the last column says so.

### Extension configuration

| Variable                  | Policy key                | Script value | Notes                                                                                                              |
| ------------------------- | ------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------ |
| `$showNotifications`      | `showNotifications`       | `1`          | `1` enables, `0` disables                                                                                          |
| `$enableValidPageBadge`   | `enableValidPageBadge`    | `0`          | Differs: Check shows the valid page badge by default. Set `1` to keep it                                            |
| `$enablePageBlocking`     | `enablePageBlocking`      | `1`          | `1` enables, `0` disables                                                                                          |
| `$forceToolbarPin`        | None                      | `1`          | Pins Check to the browser toolbar. `0` leaves it unpinned                                                          |
| `$enableCippReporting`    | `enableCippReporting`     | `0`          | Set `1` to report to CIPP, and fill in the two values below                                                        |
| `$cippServerUrl`          | `cippServerUrl`           | Blank        | Your CIPP URL, including `https://`                                                                                |
| `$cippTenantId`           | `cippTenantId`            | Blank        | The tenant ID or domain to report as                                                                               |
| `$customRulesUrl`         | `customRulesUrl`          | Blank        | Blank uses Check's standard detection rules                                                                        |
| `$updateInterval`         | `updateInterval`          | `24`         | Hours between detection rule updates, from `1` to `168`                                                            |
| `$urlAllowlist`           | `urlAllowlist`            | `@()`        | URLs to exclude from detection, for example `@("https://*.example.com")`. Supports `*` wildcards and regular expressions |
| `$domainSquattingEnabled` | `domainSquatting.enabled` | `0`          | `1` turns on domain squatting detection                                                                            |
| `$enableDebugLogging`     | `enableDebugLogging`      | `0`          | `1` turns on debug logging                                                                                         |

### Generic webhook

| Variable                | Policy key               | Script value | Notes                                                                                         |
| ----------------------- | ------------------------ | ------------ | --------------------------------------------------------------------------------------------- |
| `$enableGenericWebhook` | `genericWebhook.enabled` | `0`          | `1` sends events to your webhook                                                              |
| `$webhookUrl`           | `genericWebhook.url`     | Blank        | The endpoint, including `https://`                                                            |
| `$webhookEvents`        | `genericWebhook.events`  | `@()`        | The event types to send, for example `@("detection_alert", "page_blocked")`                   |

The event types and their payloads are on [webhooks.md](../../../webhooks.md "mention").

### Custom branding

| Variable            | Policy key                        | Script value                  | Notes                                                       |
| ------------------- | --------------------------------- | ----------------------------- | ----------------------------------------------------------- |
| `$companyName`      | `customBranding.companyName`      | `CyberDrain`                  |                                                             |
| `$productName`      | `customBranding.productName`      | `Check - Phishing Protection` | Differs: Check's own product name is `Check`                |
| `$supportEmail`     | `customBranding.supportEmail`     | Blank                         |                                                             |
| `$supportUrl`       | `customBranding.supportUrl`       | Blank                         |                                                             |
| `$privacyPolicyUrl` | `customBranding.privacyPolicyUrl` | Blank                         |                                                             |
| `$aboutUrl`         | `customBranding.aboutUrl`         | Blank                         |                                                             |
| `$primaryColor`     | `customBranding.primaryColor`     | `#F77F00`                     | A hex colour code                                           |
| `$logoUrl`          | `customBranding.logoUrl`          | Blank                         | An `https://` URL. 48 x 48 pixels recommended, 128 x 128 maximum |

The script does not set `validPageBadgeTimeout`, so the valid page badge keeps Check's default timeout.
{% endtab %}

{% tab title="Sideload" %}
Developers testing code changes can load the extension from a local copy of the repository.

## Load a local copy

{% stepper %}
{% step %}
### Get the code

Fork the repository and clone your fork.
{% endstep %}

{% step %}
### Open the extensions page

Open `chrome://extensions` or `edge://extensions`.
{% endstep %}

{% step %}
### Load the extension

Turn on **Developer mode**, choose **Load unpacked**, and select the repository root. Reload the extension after each change.
{% endstep %}
{% endstepper %}

{% hint style="info" %}
An unpacked extension gets a different extension ID from the store version, so policies deployed for the store IDs do not apply to it.
{% endhint %}
{% endtab %}
{% endtabs %}
