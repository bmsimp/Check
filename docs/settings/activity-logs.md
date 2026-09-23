# Activity Logs

The Activity Logs show what Check has done on the pages you visit: phishing pages it blocked, threats it warned you about, and other security events. Check always records security events. Routine activity, such as each page it scans and each visit to a genuine Microsoft sign-in page, is recorded only while **Developer Mode** is on.

## Logging Options

### Developer Mode (enables debug logging)

Records extra detail alongside the security events: every page Check scans, every visit to a genuine Microsoft sign-in page, and Check's own diagnostic messages. Select **Save Settings** after changing it. Disabled by default. Turn it on while you troubleshoot a problem or work with support, then turn it off again, because the extra entries fill the table and make security events harder to find.

### Simulate Enterprise Policy Mode (Dev Only)

Previews the options page as it appears when an organisation manages Check by policy, using sample policy values. It takes effect as soon as you tick it. This option appears only in a development copy of Check loaded unpacked into the browser; a copy installed from a browser store or deployed by your IT department does not show it. Disabled by default.

## Filtering and Managing Logs

### Event Type Filter

The drop-down list beside the logging options offers **All Events**, **Security Events**, **URL Access**, **Threats Detected**, **Page Scans**, and **Debug Events**.

### Refresh

Reloads the table so it includes events recorded since you opened the page.

### Clear Logs

Permanently deletes every stored log entry after you confirm. This cannot be undone, so export the logs first if you might need them.

### Export Logs

Downloads everything Check has stored, not only the entries shown in the table, as a JSON file named after the current date, for example `check-logs-2026-09-23.json`. The file also records the Check version. Send this file to support when you report a problem.

## Reading the Log Table

The table lists the 100 most recent entries, newest first. Check keeps a rolling history, so the oldest entries are removed as new ones arrive. Each row has these columns:

* **Timestamp**: when the event happened.
* **Event Type**: what kind of event it was, for example **Threat Blocked**.
* **URL/Domain**: the site involved.
* **Threat Level**: how serious Check judged it, for example **HIGH** or **NONE**.
* **Action Taken**: what Check did about it.
* **Details**: a summary of what happened.

Select a row to expand it and see the full detail of the event, including the criteria Check used to reach its decision.

### Common Log Entries

| Event type | What it means |
| --- | --- |
| **Threat Blocked** | Check identified a phishing page and blocked it. |
| **Threat Detected** | Check identified a phishing page but **Enable Page Blocking** is off, so it showed a warning instead of blocking the page. |
| **Page Scanned** | Check scanned a page and found nothing wrong. Recorded only while **Developer Mode** is on. |
| **Legitimate Access** | Check recognised the page as a genuine Microsoft sign-in page. Recorded only while **Developer Mode** is on. |

## Investigating a Blocked Page

{% stepper %}
{% step %}
### Note the time

Note roughly when Check blocked the page.
{% endstep %}

{% step %}
### Find the entry

Open the Activity Logs and look for a **Threat Blocked** entry at that time.
{% endstep %}

{% step %}
### Review the detail

Select the entry to see the URL and why Check blocked it. Check whether the URL is a site you meant to visit.
{% endstep %}

{% step %}
### Report a wrong block

If you believe Check blocked a legitimate site, export the logs and send them to your IT department or support. See [common-issues.md](../troubleshooting/common-issues.md "mention") for known causes first.
{% endstep %}
{% endstepper %}

## Collecting Logs for Support

{% stepper %}
{% step %}
### Turn on Developer Mode

Tick **Developer Mode (enables debug logging)** and select **Save Settings**.
{% endstep %}

{% step %}
### Reproduce the problem

Repeat whatever caused the problem, such as visiting the page that was blocked.
{% endstep %}

{% step %}
### Export the logs

Select **Export Logs** straight away and save the file.
{% endstep %}

{% step %}
### Send the file

Send the exported file to support with a description of the problem.
{% endstep %}

{% step %}
### Turn off Developer Mode

Untick **Developer Mode (enables debug logging)** and select **Save Settings**.
{% endstep %}
{% endstepper %}
