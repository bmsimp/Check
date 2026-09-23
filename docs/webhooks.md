---
description: Send Check detection events to your own endpoint as JSON, and what each event contains.
---

# Webhook System

Check can post an event to a URL of your choice each time it blocks a page, spots a look-alike domain or a rogue OAuth app, validates a Microsoft sign-in page, or a user reports a false positive. Use it to feed detections into a SIEM, a ticketing system, or an automation platform. Reporting to CIPP is configured separately and is covered in [CIPP reporting](#cipp-reporting).

## Configure the generic webhook

Set the webhook on the **Generic Webhook** card of the **General** settings page:

* **Enable Generic Webhook** turns sending on or off.
* **Webhook URL** is the endpoint that receives the events.
* **Event Types to Send** chooses which events are sent. Nothing is sent until at least one event type is selected.

To set the webhook for every user, deploy it by policy instead:

| Policy key               | Type             | Default | Description                                                    |
| ------------------------ | ---------------- | ------- | -------------------------------------------------------------- |
| `genericWebhook.enabled` | Boolean          | `false` | Turns the generic webhook on.                                  |
| `genericWebhook.url`     | String (URL)     | Empty   | The endpoint that receives the events.                         |
| `genericWebhook.events`  | Array of strings | Empty   | The event types to send, using the strings in the table below. The policy does not list `domain_squatting_detected`; select **Domain Squatting Detected** on the options page instead. |

```json
{
  "genericWebhook": {
    "enabled": true,
    "url": "https://webhook.example.com/endpoint",
    "events": [
      "page_blocked",
      "rogue_app_detected",
      "false_positive_report"
    ]
  }
}
```

For where to put policy values on each platform, see the [deployment guides](deployment/chrome-edge-deployment-instructions/README.md) and [firefox-deployment.md](deployment/firefox-deployment.md "mention").

## Event types

| Event string                | On-screen label           | Sent when                                                                                                                                                  |
| --------------------------- | ------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `detection_alert`           | **Detection Alerts**      | Check reports a high or critical detection, a rogue OAuth app, or a blocked look-alike domain to CIPP. Sent only while CIPP reporting is set up (see below). |
| `false_positive_report`     | **False Positive Reports** | A user selects **Report False Positive** on the block page.                                                                                                |
| `page_blocked`              | **Page Blocked**          | Check blocks a page as phishing. Not sent while **Enable Page Blocking** is off.                                                                           |
| `rogue_app_detected`        | **Rogue App Detected**    | A Microsoft sign-in page is opened for a known rogue OAuth application.                                                                                   |
| `domain_squatting_detected` | **Domain Squatting Detected** | A page's domain closely resembles a protected domain, whether Check blocks it, warns, or only logs it.                                                 |
| `validation_event`          | **Validation Events**     | A page on a trusted Microsoft sign-in domain finishes loading.                                                                                             |

Selecting **False Positive Reports** also adds the **Report False Positive** button to the block page. Without it, users have no way to report a false positive.

## Common payload fields

Every event is a JSON object with the same outer fields. The event's details are in `data`, which differs by event type.

```json
{
  "version": "1.0",
  "type": "page_blocked",
  "timestamp": "2026-09-23T14:05:12.345Z",
  "source": "Check Extension",
  "extensionVersion": "1.2.0",
  "data": { },
  "user": {
    "email": "adele.vance@contoso.com",
    "id": "1234567890",
    "accountType": "work-school",
    "provider": "unknown",
    "isManaged": true,
    "profileId": "profile-id"
  }
}
```

| Field              | Description                                                                                                                                      |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `version`          | Payload format version, currently `1.0`.                                                                                                         |
| `type`             | The event string.                                                                                                                                |
| `timestamp`        | When the event was sent, in UTC.                                                                                                                 |
| `source`           | Always `Check Extension`.                                                                                                                        |
| `extensionVersion` | The version of Check that sent the event.                                                                                                        |
| `data`             | The event's details, described per event below.                                                                                                  |
| `user`             | The browser profile the event came from. `email` is the account the browser is signed in with, or `null` when the browser does not share it. Omitted when Check cannot read the profile, and never present on `validation_event` or `false_positive_report`. |

URLs in `page_blocked`, `domain_squatting_detected`, `detection_alert`, and `false_positive_report` events are defanged so that they cannot be opened by accident: every colon is replaced with `[:]`, so `https://example.com` arrives as `https[:]//example.com`. A `rogue_app_detected` URL can arrive either defanged or as a normal URL, and a `validation_event` URL is never defanged.

## Event payloads

The examples below show the `data` object for each event.

### detection\_alert

```json
{
  "url": "https[:]//login.example-phish.com/common/oauth2",
  "severity": "critical",
  "score": 0,
  "threshold": 85,
  "reason": "Critical phishing indicators detected: phi_010_aad_fingerprint, phi_013_form_action_mismatch",
  "detectionMethod": "rules_engine",
  "rule": null,
  "ruleDescription": "Critical phishing indicators detected: phi_010_aad_fingerprint, phi_013_form_action_mismatch",
  "category": "phishing",
  "confidence": 0.8,
  "matchedRules": [
    {
      "id": "phi_010_aad_fingerprint",
      "description": "AAD-like login interface on non-Microsoft domain",
      "severity": "critical",
      "confidence": 0.98
    },
    {
      "id": "phi_013_form_action_mismatch",
      "description": "Microsoft-branded password form with non-Microsoft action",
      "severity": "critical",
      "confidence": 0.95
    }
  ],
  "context": {
    "referrer": null,
    "pageTitle": null,
    "domain": null,
    "redirectTo": null
  }
}
```

`matchedRules` lists each rule or indicator that matched, as an object with its `id`, `description`, and `severity`. Depending on what triggered the alert, `rule` can hold a single rule ID and `matchedRules` can be empty.

`detection_alert` is sent to the generic webhook only while **Enable CIPP Reporting** is on and a **CIPP Server URL** is set, and only for the detections Check reports to CIPP: high and critical detections, rogue OAuth apps, and look-alike domains that Check blocked. Lower-severity detections never produce a `detection_alert`.

### false\_positive\_report

```json
{
  "reportedUrl": "https[:]//intranet.contoso.com/sign-in",
  "reportedReason": "Critical phishing indicators detected: phi_013_form_action_mismatch",
  "reportTimestamp": "2026-09-23T14:07:40.112Z",
  "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",
  "browserInfo": {
    "platform": "Win32",
    "language": "en-GB",
    "vendor": "Google Inc.",
    "cookiesEnabled": true,
    "onLine": true
  },
  "screenResolution": {
    "width": 1920,
    "height": 1080,
    "availWidth": 1920,
    "availHeight": 1040,
    "colorDepth": 24
  },
  "detectionDetails": { },
  "userComments": null
}
```

The report is sent straight from the block page when the user selects **Report False Positive**. `reportedUrl` and `reportedReason` are the URL and reason shown on the block page; `reportedUrl` is defanged and cut to 80 characters. `detectionDetails` carries the detection details the block page received, which vary with what triggered the block. `userComments` is always `null`.

### page\_blocked

```json
{
  "url": "https[:]//login.example-phish.com/common/oauth2",
  "severity": "critical",
  "score": 0,
  "threshold": 85,
  "reason": "Critical phishing indicators detected: phi_010_aad_fingerprint",
  "detectionMethod": "rules_engine",
  "rule": "phi_010_aad_fingerprint",
  "ruleDescription": "Critical phishing indicators detected: phi_010_aad_fingerprint",
  "category": "phishing",
  "action": "blocked",
  "matchedRules": [
    {
      "id": "phi_010_aad_fingerprint",
      "description": "AAD-like login interface on non-Microsoft domain",
      "severity": "critical",
      "confidence": 0.98
    }
  ],
  "context": {
    "referrer": null,
    "pageTitle": null,
    "domain": null,
    "redirectTo": null
  }
}
```

`matchedRules` lists each rule or indicator that caused the block. `confidence` appears on phishing indicators only. A page blocked as a look-alike domain sends `domain_squatting_detected` instead.

### rogue\_app\_detected

```json
{
  "url": "https[:]//login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=00000000-0000-0000-0000-000000000000",
  "severity": "critical",
  "reason": "Rogue App: Example Mail Sync",
  "detectionMethod": "rogue_app_detection",
  "category": "oauth_threat",
  "clientId": "00000000-0000-0000-0000-000000000000",
  "appName": "Example Mail Sync",
  "appInfo": {
    "description": "Application observed in business email compromise campaigns",
    "tags": ["BEC", "exfiltration"],
    "references": ["https://example.com/advisory"],
    "risk": "high"
  },
  "context": {
    "referrer": null,
    "pageTitle": null,
    "domain": null,
    "redirectTo": "attacker-redirect.example.net",
    "isLocalhost": false,
    "isPrivateIP": false
  }
}
```

`clientId` is the OAuth client ID from the sign-in URL. `context.redirectTo` is the host name the app asks Microsoft to redirect to, and `context.isLocalhost` is `true` when that host is `localhost`.

### domain\_squatting\_detected

```json
{
  "url": "https[:]//login-contoso.com/",
  "testDomain": "login-contoso.com",
  "protectedDomain": "contoso.com",
  "techniques": [
    {
      "technique": "combosquat",
      "description": "Domain adds suspicious prefix/suffix to protected domain"
    }
  ],
  "severity": "critical",
  "confidence": 0.9,
  "action": "blocked",
  "reason": "Domain squatting detected: Domain adds suspicious prefix/suffix to protected domain"
}
```

| Field             | Description                                                                                          |
| ----------------- | ---------------------------------------------------------------------------------------------------- |
| `testDomain`      | The host name of the page that was visited.                                                          |
| `protectedDomain` | The protected domain it resembles.                                                                   |
| `techniques`      | Each technique that matched: `levenshtein`, `homoglyph`, `typosquat`, or `combosquat`, with a description. |
| `severity`        | `low`, `medium`, `high`, or `critical`.                                                               |
| `confidence`      | A value from 0 to 1.                                                                                 |
| `action`          | What Check did: `blocked`, `warned`, or `logged`.                                                     |

Unlike the other events, `domain_squatting_detected` has no `context`, `category`, or `detectionMethod` field. For how detection works and what is protected, see [domain-squatting-detection.md](features/domain-squatting-detection.md "mention").

### validation\_event

```json
{
  "url": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
  "severity": "info",
  "reason": "Legitimate domain validated",
  "detectionMethod": "domain_validation",
  "category": "validation",
  "result": "legitimate",
  "confidence": 1,
  "context": {
    "referrer": null,
    "pageTitle": null,
    "domain": null,
    "redirectTo": null
  }
}
```

A `validation_event` is sent for every page load on a trusted Microsoft sign-in domain, so it can be a high-volume event. Select it only if you need a record of legitimate sign-ins.

## CIPP reporting

CIPP reporting is set on the **Extension Settings** card of the **General** settings page with **Enable CIPP Reporting**, **CIPP Server URL**, and **Tenant ID/Domain**, or by policy with `enableCippReporting`, `cippServerUrl`, and `cippTenantId`.

Check sends the same detections as `detection_alert` to `<CIPP Server URL>/api/PublicPhishingCheck`, in CIPP's own format rather than the payload on this page. The CIPP payload is a flat JSON object carrying the detection's fields together with `tenantId`, `userEmail`, `userDisplayName`, `alertSeverity`, `alertCategory`, and a `browserContext` object. Apart from `detection_alert`, the generic webhook does not depend on CIPP reporting, so you can use either or both.

## Delivery

* Each event is sent as an HTTP `POST` with a JSON body, from the user's browser.
* Requests carry the headers `Content-Type: application/json`, `X-Webhook-Type` (the event string), and `X-Webhook-Version: 1.0`.
* Any `2xx` response counts as delivered. A failed delivery is not retried, so the event is lost if your endpoint is unreachable.
* Requests are not signed and carry no authentication header. Use an endpoint URL that is hard to guess, and treat incoming events as untrusted input.
* Your endpoint must be reachable from every device that runs Check, not only from your own network.
