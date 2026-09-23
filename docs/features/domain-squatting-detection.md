---
description: Warns about or blocks websites whose address imitates one of your own domains.
---

# Domain Squatting Detection

Domain squatting detection warns about or blocks websites whose address imitates a domain you trust, such as `cntoso.com` or `login-contoso.com` posing as `contoso.com`. It is off by default and protects only the domains you give it, so it does nothing until you turn it on and add your domains.

## What domain squatting is

Domain squatting, also called typosquatting, is registering an address that is deliberately close to a real one, so that a user who mistypes it, or skims a link in an email, lands on the attacker's site instead. The fake site usually copies the real sign-in page to collect usernames and passwords.

## How it protects you

When a page loads, Check compares its domain with each protected domain. Only the name part is compared, so for `contoso.com` Check looks at `contoso`. The same name on a different ending, such as `contoso.net`, is not flagged.

Check looks for three kinds of imitation. With the default settings, how closely a domain matches decides whether Check blocks it or shows a warning:

| Imitation                                                                                                | Examples for `contoso.com`                                       | Outcome |
| -------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- | ------- |
| Typing mistakes: two letters swapped, a letter missing or doubled, or a neighbouring key pressed          | `cotnoso.com`, `cntoso.com`, `conttoso.com`, `xontoso.com`       | Blocked |
| Added words attackers commonly use, such as `login`, `secure`, `verify`, `support`, `account`, or `signin` | `login-contoso.com`, `contoso-support.com`, `securecontoso.com`  | Blocked |
| Other added text, or up to two characters changed                                                         | `contosocloud.com`, `cont0so.com`                                | Warning |

When a page is blocked, the block page shows **Domain Squatting** as the threat and names the domain the site imitates. When a page gets a warning, a banner at the top of the page names the domain it resembles and the page stays usable. The banner appears only while **Show Notifications** is on.

A page is blocked only while **Enable Page Blocking** is on. With it off, a match that would be blocked shows the warning banner instead.

Every match is recorded in **Activity Logs**. If your organisation has set up a webhook, each match is also sent as a `domain_squatting_detected` event; see [webhooks.md](../webhooks.md "mention").

## Turn it on

{% stepper %}
{% step %}
### Enable the detection

On the **Detection Rules** settings page, turn on **Enable Domain Squatting Detection** on the **Detection Configuration** card.
{% endstep %}

{% step %}
### Add the domains to protect

Add each domain you want protected to **URL Allowlist (Regex or URL with wildcards)** on the same card, one per line, in the form `https://contoso.com/*`. Check protects the domain named in each entry.
{% endstep %}

{% step %}
### Save

Select **Save Settings**.
{% endstep %}
{% endstepper %}

Adding a domain to the URL Allowlist also stops Check from scanning that site, which is what you want for your own domains. For more on the allowlist, see [detection-rules.md](../settings/detection-rules.md "mention").

## Set it by policy

Admins can set domain squatting detection for every user with the `domainSquatting` policy object:

| Policy key                                | Type                         | Default | Description                                                                                                                                          |
| ----------------------------------------- | ---------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `domainSquatting.enabled`                 | Boolean                      | `false` | Turns domain squatting detection on.                                                                                                                 |
| `domainSquatting.Action`                  | `block`, `warn`, or `log`    | `block` | `block` blocks close matches and warns about the rest, as described above. `warn` shows the warning banner for every match and never blocks. `log` records matches in **Activity Logs** and sends webhooks, but shows the user nothing. |
| `domainSquatting.deviationThreshold`      | Integer from `1` to `5`      | `2`     | The largest number of changed characters that still counts as a match. Higher values catch more distant imitations and flag more legitimate sites. |
| `domainSquatting.algorithms.typosquat`    | Boolean                      | `true`  | Checks for typing mistakes.                                                                                                                          |
| `domainSquatting.algorithms.combosquat`   | Boolean                      | `true`  | Checks for added words and text.                                                                                                                     |
| `domainSquatting.algorithms.levenshtein`  | Boolean                      | `true`  | Checks for changed characters, up to `deviationThreshold`.                                                                                           |
| `domainSquatting.algorithms.homoglyph`    | Boolean                      | `true`  | Turns the look-alike character check on or off.                                                                                                                   |

`Action` starts with a capital A. The protected domains come from the `urlAllowlist` policy, in the same `https://contoso.com/*` form as on the settings page.

```json
{
  "domainSquatting": {
    "enabled": true,
    "Action": "block"
  },
  "urlAllowlist": [
    "https://contoso.com/*",
    "https://contoso.co.uk/*"
  ]
}
```

A `domainSquatting` policy replaces the user's own setting as a whole, so always include `enabled`. Any key you leave out takes its default. `enablePageBlocking` and `showNotifications` decide whether a match is blocked and whether the banner shows, as they do for the settings above.

For where to put policy values on each platform, see the [deployment guides](../deployment/chrome-edge-deployment-instructions/README.md) and [firefox-deployment.md](../deployment/firefox-deployment.md "mention").

## Troubleshooting

<details>

<summary>Check blocked or warned about a site I trust</summary>

Add the site to **URL Allowlist (Regex or URL with wildcards)** on the **Detection Rules** settings page. Check no longer scans an allowlisted site.

If your organisation has set up false positive reporting, the block page also shows **Report False Positive**, which sends the report to your IT team.

</details>

<details>

<summary>A look-alike site was not flagged</summary>

Any of these stops a look-alike from being flagged:

* **Enable Domain Squatting Detection** is off.
* The real domain is not in the URL Allowlist in the form `https://contoso.com/*`.
* The look-alike uses the real name on a different ending, such as `contoso.net`. Only the name part is compared.
* The look-alike differs by more characters than the threshold allows. The default is two.

Check's other phishing protections still examine the page itself, whatever its address.

</details>

<details>

<summary>I see no warning banner</summary>

The banner appears only while **Show Notifications** is on. If your organisation sets `domainSquatting.Action` to `log`, matches are recorded but never shown.

</details>

<details>

<summary>I can't find or change the setting</summary>

Your organisation manages Check through policy. The **Detection Rules** section of the settings page is hidden, so **Enable Domain Squatting Detection** cannot be changed there. Contact your IT team to change it.

</details>
