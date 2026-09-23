---
description: This is where you control the main features of Check.
---

# General

The General section holds the switches that decide how Check protects you, where it sends detection reports, and what it shows on the pages you visit. Select **Save Settings** after a change to apply it.

## Extension Settings

### Enable Page Blocking

Blocks access to detected phishing pages and shows a block page instead. When this setting is off, Check still analyses pages and records what it finds in the [Activity Logs](activity-logs.md), but shows a warning banner on a phishing page rather than blocking it, so you can still enter your credentials. Enabled by default. Leave it enabled unless you are testing a detection rule, and turn it back on as soon as you finish.

### Force Main Thread Phishing Processing

A troubleshooting option that makes Check run its phishing analysis directly in the page. Timing information and logs become more accurate, but pages can load more slowly while the analysis runs. Disabled by default. Leave it disabled unless you are diagnosing a detection problem.

### Enable CIPP Reporting

Sends Check's detections to your CIPP server so they can be reviewed and alerted on alongside the rest of your Microsoft 365 monitoring. Check reports high and critical detections, rogue applications, blocked phishing pages, and blocked domain squatting pages; it does not report routine events such as visits to genuine Microsoft sign-in pages. Reports are sent only when this setting is enabled and a **CIPP Server URL** is entered. Disabled by default.

### CIPP Server URL

The base URL of your CIPP instance, for example `https://your-cipp-server.com`. Check sends its reports here when **Enable CIPP Reporting** is on. Empty by default.

### Tenant ID/Domain

The tenant to attribute reports to, so CIPP can tell which tenant a detection came from when you manage several. Enter either the tenant GUID or the tenant's primary domain, for example `contoso.onmicrosoft.com`. Empty by default.

{% hint style="info" %}
CIPP shows these reports in its logbook.
{% endhint %}

## Generic Webhook

### Enable Generic Webhook

Sends the events you choose below to a webhook endpoint of your own, such as an automation platform or a ticketing system. Disabled by default. Events are sent only when this setting is enabled, a **Webhook URL** is entered, and at least one event type is selected.

### Webhook URL

The full URL of the endpoint that receives the events, for example `https://webhook.example.com/endpoint`. Empty by default.

### Event Types to Send

The kinds of event Check sends to the webhook. None are selected by default. The options are:

* **Detection Alerts**
* **False Positive Reports**
* **Page Blocked**
* **Rogue App Detected**
* **Domain Squatting Detected**
* **Threat Detected**
* **Validation Events**

Selecting **False Positive Reports** also adds a **Report False Positive** button to the block page, so users can tell you when Check has blocked a legitimate site. For what each event contains and when it is sent, see [webhooks.md](../webhooks.md "mention").

## User Interface

### Show Notifications

Shows a warning banner when you visit a page whose domain closely resembles a protected domain, a technique known as domain squatting. The banner appears only when domain squatting detection is turned on. Turning this setting off hides the banner but does not change which pages Check blocks. Enabled by default. Leave it enabled. For more on this protection, see [domain-squatting-detection.md](../features/domain-squatting-detection.md "mention").

### Show Valid Page Badge

Shows a green **Verified Microsoft Domain** badge on genuine Microsoft 365 sign-in pages, so you can see at a glance that the page really belongs to Microsoft. Enabled by default.

### Valid Page Badge Timeout (seconds)

How long the **Verified Microsoft Domain** badge stays on screen before it closes by itself, from 0 to 300 seconds. Set it to 0 to keep the badge on screen until you close it. The default is 5 seconds.

{% hint style="warning" %}
When your organisation manages Check through policy, the **General**, **Detection Rules** and **Branding** sections are hidden, and the page header shows **Managed by Policy**. Your IT department sets these options for you.
{% endhint %}
