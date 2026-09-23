# Detection Rules

Detection Rules controls where Check gets the rules it uses to recognise phishing pages, how often it refreshes them, which sites it never scans, and whether it looks for look-alike domains. It also shows the rules currently in use and lets you test candidate rules before they go live. Most people can leave every setting here at its default.

## Detection Configuration

### Config URL

The address Check downloads its detection rules from. By default this is the CyberDrain rules file on GitHub, and leaving the field empty also uses the CyberDrain rules. A custom rules file replaces the CyberDrain rules completely rather than adding to them, so enter a URL here only when your IT department gives you one. If Check cannot download the file, it uses the rules built into the extension until the next successful download. To build a custom rules file, see [creating-detection-rules.md](../advanced/creating-detection-rules.md "mention").

### Update Interval (hours)

How often Check downloads the rules again, from 1 to 168 hours (one week). The default is 24 hours. Leave it at 24 unless your IT department asks for something different; a shorter interval picks up new rules sooner.

### URL Allowlist (Regex or URL with wildcards)

Sites Check never scans, one pattern per line. On a matching page Check runs no phishing detection at all, so use this for internal sites or trusted services that trigger a false warning. Your entries are added to the exclusions in the detection rules; they do not replace them. The list is empty by default.

Each line is either a URL with `*` wildcards or a regular expression that starts with `^`:

* `https://training.yourcompany.com/*` matches every page on that site.
* `https://*.yourcompany.com/*` matches every subdomain of `yourcompany.com`, but not `yourcompany.com` itself.
* `https://yourcompany.com` (no path) matches every page on that site. A URL with a path and no trailing `*` matches that exact address only.
* `^https://trusted\.example\.com/.*` is a regular expression, used as written.

Domains in the allowlist also become protected domains for **Enable Domain Squatting Detection**: an entry such as `https://yourcompany.com/*` makes Check watch for look-alikes of `yourcompany.com`. Look-alikes are compared on the name without its ending, so `yourcompany.net` counts as the same name as `yourcompany.com` and is not flagged.

{% hint style="info" %}
**Allowlisting a phishing simulation platform**

Add the platform's URLs here so its training pages are not blocked. To exclude a platform for every user from a custom rules file instead, see [Exclusions](../advanced/creating-detection-rules.md#exclusions).
{% endhint %}

### Enable Domain Squatting Detection

Checks each site you visit against your protected domains and flags look-alikes: typosquats (misspellings), homoglyphs (characters that look alike), and combosquats (a protected name with extra words added). Off by default. Protected domains come from the detection rules and from the domains in your **URL Allowlist**, so turn this on once your organisation's own domains are in the allowlist. A close look-alike is blocked when **Enable Page Blocking** is on, and any other match shows a warning banner when **Show Notifications** is on. Both settings are on [General](general.md). For how detection works, see [domain-squatting-detection.md](../features/domain-squatting-detection.md "mention").

### Update Rules Now

Downloads the rules from the saved **Config URL** straight away instead of waiting for the next update. If you have just changed the Config URL, click **Save Settings** first. When the download finishes, Check shows **Detection rules updated successfully**. Reload this settings page to see the new rules in the **Configuration Overview**, and reload any other open tabs, because a page keeps the rules it loaded with. If the **Version** in the Configuration Overview has not changed after an update you expected, open the Config URL in a browser tab to check that it returns the rules file.

## Configuration Overview

A read-only view of the rules Check is using. It opens on **Basic Information**, which shows the rules **Version**, the **Last Updated** date recorded in the rules file, and a description. Below it are collapsed sections for each part of the rules that is present: **Detection Thresholds**, **Trusted Login Patterns**, **Microsoft Domain Patterns**, **Domain Squatting Detection**, **Rogue Apps Detection**, **Phishing Indicators**, **Microsoft 365 Detection Requirements**, **Exclusion System**, and **Configuration Statistics**. Click a section's header to open it. Use the **Version** to confirm which rules are loaded.

### Expand All

Opens every section at once. The button then reads **Collapse All** and closes them again.

### Show Raw JSON

Shows the complete rules file as JSON instead of the formatted sections. The button then reads **Show Formatted** and switches back. Use it to look up a specific rule or pattern.

## Rule Playground (Beta)

Tests candidate rules against a page you paste in, without changing the rules Check uses. Nothing entered here is saved to the extension.

{% hint style="warning" %}
The playground evaluates indicators that use a regular expression (a `pattern`) and some blocking rules. It does not evaluate code-driven indicators, so a page can pass in the playground and still be flagged in the browser.
{% endhint %}

### Load Current

Loads the rules file built into the extension into **Candidate Rules JSON**, as a starting point to edit. It does not load rules from a custom **Config URL**; to test those, paste the file in instead.

### Candidate Rules JSON

The rules to test: a complete rules file, an object with a `phishing_indicators` array, or an array of indicators. **Validate** checks that the JSON parses and lists basic problems, such as a rule with no `id`; it does not check regular expressions or rule logic. **Sanitize** reformats the JSON with consistent indentation without changing any values. **Copy** copies the JSON to your clipboard, for example to save it into a custom rules file.

### Test URL

The address of the page you are simulating. Required. Regular-expression indicators are matched against it as well as against the HTML.

### Sample HTML (will not fetch live)

The page's HTML source. Required, because the playground never fetches the live page: open the page in a browser, view its source, and paste all of it here.

### Test Rules

Runs the candidate rules against the **Test URL** and **Sample HTML**. **Clear** empties all three fields. The results appear below:

* **Decision & Summary**: the decision (**PASS**, **WARN**, or **BLOCK**), the threat score, the number of threats at each severity, and the reason if a blocking rule triggered.
* **Threats**: each rule that matched, with its severity, action, category, and the snippet of HTML that matched.
* **Unsupported Features**: checks the playground cannot simulate from pasted HTML (dynamic scripts, network headers, live stylesheet rules, and referrer validation). The same list appears on every run.
* **Raw JSON**: the full evaluation result.

{% hint style="warning" %}
When your organisation manages Check through policy, the **General**, **Detection Rules** and **Branding** sections are hidden, and the page header shows **Managed by Policy**. Your IT department sets these options for you.
{% endhint %}
