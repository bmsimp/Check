# Creating Detection Rules

All of Check's detection logic is defined in one JSON rules file, [`rules/detection-rules.json`](https://github.com/CyberDrain/Check/blob/main/rules/detection-rules.json). You can host your own copy of the file, add indicators, exclusions, and blocking rules for your organisation, and point Check at it. This page describes the file's format and how Check uses each section. To suggest a change to the CyberDrain rules for everyone, open a pull request against that file.

{% hint style="danger" %}
**A custom rules file replaces the CyberDrain rules completely.** Check does not merge your file with the default rules. Start from a full copy of `rules/detection-rules.json` and edit it: a file that contains only your additions leaves Check with no other indicators, exclusions, or blocking rules. While you use a custom file, CyberDrain's rule updates reach your users only when you copy them into your file.
{% endhint %}

## Hosting a custom rules file

Host the file anywhere your users' browsers can download it over HTTPS without signing in, such as a fork of the Check repository on GitHub (use the raw file URL) or Azure Blob Storage. The URL must return the JSON file itself, not a web page about it.

Point Check at the file with the **Config URL** field on [detection-rules.md](../settings/detection-rules.md "mention"), or for every user with the `customRulesUrl` policy key. Check downloads the file again every 24 hours by default; set a different interval, from 1 to 168 hours, with **Update Interval (hours)** or the `updateInterval` policy key. If a download fails, Check uses the rules built into the extension and tries again later.

A page that is already open keeps the rules it loaded with. After changing the rules, click **Update Rules Now** on the Detection Rules settings page and reload any open tabs.

## Rules file sections

| Section | What it controls |
| --- | --- |
| `trusted_login_patterns` | Genuine Microsoft sign-in domains. Check never scans them and can show its valid page badge on them. |
| `microsoft_domain_patterns` | Other Microsoft domains. Check never scans them and shows no badge. |
| `exclusion_system` | Domains Check never scans. |
| `m365_detection_requirements` | The page elements that make a page look like a Microsoft 365 sign-in page. |
| `phishing_indicators` | Patterns and logic that identify phishing content. |
| `blocking_rules` | Conditions that block a Microsoft 365 sign-in page outright. |
| `domain_squatting` | The domains to protect from look-alikes. |
| `rogue_apps_detection` | Where Check gets its list of known malicious OAuth applications. |

Check also shows `version` and `lastUpdated` from the top of the file in **Configuration Overview**, so change them whenever you publish a new version of your file.

## Exclusions

{% hint style="info" %}
To exclude a site for one person or through policy without maintaining a rules file, use **URL Allowlist (Regex or URL with wildcards)** on [detection-rules.md](../settings/detection-rules.md "mention"), or the `urlAllowlist` policy key. Allowlist entries are added to the exclusions in the rules file rather than replacing them.
{% endhint %}

To stop Check scanning a domain at all, add a regular expression to the `exclusion_system.domain_patterns` array:

```json
{
  "exclusion_system": {
    "domain_patterns": [
      "^https://([^/]*\\.)?yourdomain\\.com$",
      "^https://([^/]*\\.)?trusted-site\\.org$"
    ]
  }
}
```

### Pattern format

Exclusion patterns are matched against the page's origin only: the scheme and host (and port, if there is one), with no path and no trailing slash. For example, on `https://mail.yourdomain.com/inbox` the pattern is tested against `https://mail.yourdomain.com`.

* `^https://` matches the start of the origin.
* `([^/]*\\.)?` matches any subdomain, or none, so the pattern covers both `yourdomain.com` and `mail.yourdomain.com`.
* `\\.` is an escaped dot. JSON needs the backslash doubled.
* `$` ends the match, so `yourdomain.com.attacker.net` does not match.

A pattern written as `^https://[^/]*\\.yourdomain\\.com(/.*)?$` still works for subdomains, but it misses the bare `yourdomain.com`, because `[^/]*\\.` requires at least a dot before the domain.

## Trusted and Microsoft domains

`trusted_login_patterns` lists the domains where genuine Microsoft sign-in happens. Like exclusions, the patterns are matched against the origin:

```json
"trusted_login_patterns": [
  "^https://login\\.microsoftonline\\.(com|us)$",
  "^https://login\\.microsoft\\.com$"
]
```

`microsoft_domain_patterns` uses the same format for Microsoft domains that are not sign-in pages.

## Phishing indicators

Phishing indicators run only on pages where the Microsoft 365 detection requirements find Microsoft elements, and never on trusted, Microsoft, or excluded domains. The one exception is an indicator marked `url_only` (see [URL-only indicators](#url-only-indicators)).

### Indicator fields

| Field | Meaning |
| --- | --- |
| `id` | Unique identifier, shown in logs and webhooks. |
| `description` | What the indicator detects, shown in logs and webhooks. |
| `severity` | `critical`, `high`, `medium`, or `low`. |
| `action` | `block` or `warn`. |
| `confidence` | How reliable the indicator is, from 0.0 to 1.0. Defaults to 0.5. |
| `category` | A grouping label, such as `credential_harvesting`. |
| `pattern`, `flags` | For a regex indicator: the regular expression and its flags. `flags` defaults to `i`. |
| `code_driven`, `code_logic` | For a code-driven indicator: `code_driven: true` and the logic to evaluate. |
| `context_required` | Optional. Words that must also appear on the page for the indicator to count. |
| `url_only` | Optional. `true` to test `pattern` against the URL before the page's content is checked. |

### How matches become a verdict

* An indicator with `severity` `critical` and `action` `block` blocks the page on its own. No other combination blocks by itself: a `high` indicator with `action` `block` counts as a warning.
* Each matching indicator scores points for its severity (critical 25, high 15, medium 10, low 5), multiplied by its `confidence`.
* On a page that shows Microsoft elements but is not a full sign-in page, three or more matching indicators escalate to a block. Fewer show a warning banner.
* On a page that looks like a full Microsoft 365 sign-in page, the indicator score is subtracted from the page's legitimacy score. A low result shows a warning; a very low one blocks the page.

### Regex indicators

A regex indicator matches `pattern` against the page's HTML source, then its visible text, then its URL:

```json
{
  "id": "custom_indicator_001",
  "pattern": "(?:suspicious-pattern-here)",
  "flags": "i",
  "severity": "high",
  "description": "Description of what this detects",
  "action": "warn",
  "category": "custom_category",
  "confidence": 0.85
}
```

### Code-driven indicators

Code-driven indicators combine simple checks without regular expressions. Set `code_driven` to `true` and describe the logic in `code_logic`:

```json
{
  "id": "phi_example_code_driven",
  "code_driven": true,
  "code_logic": {
    "type": "all_of",
    "operations": [
      {
        "type": "substring_present",
        "values": ["microsoft", "office", "365"]
      },
      {
        "type": "substring_present",
        "values": ["password", "login"]
      }
    ]
  },
  "severity": "high",
  "description": "Microsoft branding with credential fields",
  "action": "warn",
  "category": "credential_harvesting",
  "confidence": 0.8
}
```

#### Operations

Every operation checks the page's HTML source and, unless noted, ignores case. Add `"invert": true` to any operation to reverse its result.

| `type` | Matches when | Fields |
| --- | --- | --- |
| `substring_present` | Any of `values` appears. | `values` |
| `all_substrings_present` | Every one of `values` appears. | `values` |
| `substring_count` | The number of different `substrings` that appear is between `min_count` and `max_count`. Each substring counts once, however often it appears. | `substrings`, `min_count`, `max_count` (optional) |
| `substring_proximity` | `word2` appears within `max_distance` characters of the first `word1`. | `word1`, `word2`, `max_distance` |
| `multi_proximity` | Any one of `pairs` has its two words within that pair's `max_distance` characters. | `pairs` (each `words` and `max_distance`) |
| `has_but_not` | Any of `required` appears and none of `prohibited` does. With `check_url_only: true`, it checks the URL instead of the page. | `required`, `prohibited`, `check_url_only` (optional) |
| `not_if_contains` | None of `prohibited` appears. Use it inside `all_of` to exclude legitimate contexts. | `prohibited` |
| `pattern_count` | The total number of regex matches across `patterns` is between `min_count` and `max_count`. | `patterns`, `flags` (default `gi`), `min_count`, `max_count` (optional) |
| `word_density` | `words`, as whole words, occur at least `min_density` times per 1,000 characters. | `words`, `min_density` |
| `substring_before` | `first` appears before `second`. | `first`, `second` |
| `substring_in_range` | `substring` first appears between character positions `min_position` and `max_position`. | `substring`, `min_position`, `max_position` |
| `resource_pattern` | The number of `src`, `href`, and `action` URLs matching the regex `pattern` is between `min_count` (default 1) and `max_count`. | `pattern`, `flags` (default `i`), `min_count`, `max_count` |
| `resource_from_domain` | Every `src` or `href` URL containing `resource_type` comes from one of `allowed_domains`, or there are none. Use `invert` to match when one does not. | `resource_type`, `allowed_domains` |
| `form_action_check` | At least one form's `action` does not contain any of `required_domains`. Forms without an `action` attribute are ignored. | `required_domains` |
| `obfuscation_check` | At least `min_matches` of `indicators` appear. Case-sensitive. | `indicators`, `min_matches` |
| `all_of` | Every operation in `operations` matches. | `operations` |
| `any_of` | At least one operation in `operations` matches. | `operations` |

`substring_or_regex` is also available, but only as the top-level `code_logic` type, not inside `all_of` or `any_of`. It matches when any of `substrings` appears, or otherwise when `regex` matches:

```json
"code_logic": {
  "type": "substring_or_regex",
  "substrings": ["atob(", "unescape(", "eval("],
  "regex": "(?:var|let|const)\\s+\\w+\\s*=\\s*(?:atob|unescape)\\([^)]+\\)",
  "flags": "i"
}
```

#### Operation examples

Require at least two of a set of words:

```json
{
  "type": "substring_count",
  "substrings": ["verify", "urgent", "suspended"],
  "min_count": 2
}
```

Count form tags whose action is set. Keep `g` in `flags`, or the count is unreliable:

```json
{
  "type": "pattern_count",
  "patterns": ["<form[^>]*action"],
  "flags": "gi",
  "min_count": 1
}
```

Require Microsoft sign-in words but skip pages that offer Microsoft as a third-party sign-in option:

```json
{
  "type": "has_but_not",
  "required": ["microsoft", "login"],
  "prohibited": [
    "sign in with microsoft",
    "sso",
    "oauth",
    "third party auth"
  ]
}
```

Match when a custom CSS file is loaded from anywhere other than Microsoft's CDN:

```json
{
  "type": "resource_from_domain",
  "resource_type": "customcss",
  "allowed_domains": ["aadcdn.msftauthimages.net"],
  "invert": true
}
```

Skip pages that describe Microsoft 365 services rather than imitate the sign-in page:

```json
{
  "type": "all_of",
  "operations": [
    {
      "type": "substring_present",
      "values": ["microsoft", "office", "365"]
    },
    {
      "type": "not_if_contains",
      "prohibited": ["migration tool", "microsoft partner", "tenant migration"]
    }
  ]
}
```

#### Complete example

This indicator from the CyberDrain rules detects Microsoft branding combined with urgency:

```json
{
  "id": "phi_004",
  "code_driven": true,
  "code_logic": {
    "type": "all_of",
    "operations": [
      {
        "type": "any_of",
        "operations": [
          {
            "type": "substring_proximity",
            "word1": "urgent",
            "word2": "action",
            "max_distance": 500
          },
          {
            "type": "substring_proximity",
            "word1": "immediate",
            "word2": "attention",
            "max_distance": 500
          },
          {
            "type": "substring_proximity",
            "word1": "act",
            "word2": "now",
            "max_distance": 500
          }
        ]
      },
      {
        "type": "substring_present",
        "values": ["microsoft", "office", "365"]
      }
    ]
  },
  "severity": "medium",
  "description": "Urgency tactics targeting Microsoft users",
  "action": "warn",
  "category": "social_engineering",
  "confidence": 0.65
}
```

It matches when any of the urgency word pairs (urgent and action, immediate and attention, or act and now) appears close together, and Microsoft branding words also appear.

#### Choosing code-driven or regex

Use code-driven logic when you need several conditions combined with AND or OR, when word proximity matters, or when you need to exclude legitimate contexts. Substring checks are also faster than complex regular expressions and easier to maintain. Use a regex indicator for a single, well-tested pattern or for complex character matching.

### Context requirements

`context_required` makes an indicator count only when at least one of the listed words or phrases also appears in the page's HTML source or visible text. The entries are plain text, not regular expressions, and are matched without regard to case:

```json
{
  "id": "context_example",
  "pattern": "malicious-pattern",
  "context_required": ["microsoft", "office 365", "password"]
}
```

### URL-only indicators

An indicator with `"url_only": true` tests its `pattern` against the page URL before Check looks at the page's content, so it catches phishing kits that strip every Microsoft element from the page. When a URL-only indicator with `severity` `critical` or `action` `block` matches, Check runs its full phishing analysis on the page even if it finds no Microsoft elements.

## Blocking rules

Blocking rules run on pages that look like a Microsoft 365 sign-in page but are not on a trusted domain. When any rule's condition is met, Check blocks the page. Each rule has an `id`, a `description`, a `type`, and a `condition`:

| `type` | Blocks when | `condition` fields |
| --- | --- | --- |
| `form_action_validation` | A form sends to an address that does not contain `action_must_not_contain`. A form with no action sends to the page itself. | `form_selector` (default `form`), `has_password_field` (only check forms with a password field), `action_must_not_contain` |
| `resource_validation` | A resource loaded by the page, such as a script, image, or stylesheet, whose URL contains `resource_pattern` does not start with `required_origin`. | `resource_pattern`, `required_origin` |
| `css_spoofing_validation` | At least `minimum_css_matches` of the `css_indicators` regular expressions match the page source, and a form sends to an address that does not contain `form_action_must_not_contain`. | `css_indicators`, `minimum_css_matches` (default 2), `has_credential_fields` (only check forms with an email or password field), `form_action_must_not_contain` |
| `aitm_origin_validation` | At least `minimum_marker_matches` of the `microsoft_source_markers` regular expressions match the page source on a page with a credential field. | `microsoft_source_markers`, `minimum_marker_matches` (default 3), `require_credential_input` (default `true`), `require_non_trusted_host` (default `true`) |

## Microsoft 365 sign-in page detection

`m365_detection_requirements` decides whether a page looks like a Microsoft 365 sign-in page, which in turn decides whether phishing indicators and blocking rules run on it. It lists `primary_elements` and `secondary_elements`:

```json
"m365_detection_requirements": {
  "primary_elements": [
    {
      "id": "custom_primary",
      "type": "source_content",
      "pattern": "your-pattern-here",
      "description": "Custom primary element",
      "weight": 3,
      "category": "primary"
    }
  ],
  "secondary_elements": [
    {
      "id": "custom_secondary",
      "type": "css_pattern",
      "patterns": ["css-pattern-here"],
      "description": "Custom secondary element",
      "weight": 1,
      "category": "secondary"
    }
  ]
}
```

Each element found adds its `weight` (default 1) to the page's total. An element counts as primary when its `category` is `primary`.

### Element types

| `type` | Matches | Field |
| --- | --- | --- |
| `source_content` | The page's HTML source | `pattern` (one regular expression) |
| `css_pattern` | The HTML source, then any stylesheets the browser can read | `patterns` |
| `page_title` | The page title | `patterns` |
| `meta_tag` | The content of the meta tag named in `attribute`, such as `description` or `og:title` | `attribute`, `patterns` |
| `url_pattern` | The full page URL | `patterns` |
| `text_content` | The page's visible text | `patterns` |
| `code_driven` | The same logic as a code-driven indicator | `code_logic` |

All patterns ignore case. For types that take `patterns`, the element is found when any one of them matches.

### Detection thresholds

`detection_thresholds` inside `m365_detection_requirements` sets how many elements make a sign-in page:

| Field | Default | Meaning |
| --- | --- | --- |
| `minimum_primary_elements` | 1 | Primary elements needed when any are found. |
| `minimum_total_weight` | 4 | Total weight needed when a primary element is found. |
| `minimum_elements_overall` | 3 | Elements of any kind needed when a primary element is found. |
| `minimum_secondary_only_weight` | 9 | Total weight needed when no primary element is found. |
| `minimum_secondary_only_elements` | 7 | Elements needed when no primary element is found. |

A page that falls short of these thresholds but has at least one primary element, or reaches `minimum_total_weight`, still counts as showing Microsoft elements, so phishing indicators run on it.

## Domain squatting

To protect domains from look-alikes for everyone who uses your rules file, list them in `domain_squatting.protected_domains`:

```json
"domain_squatting": {
  "protected_domains": ["yourcompany.com", "yourbrand.com"]
}
```

These are added to any domains taken from the URL allowlist. Detection itself stays off until it is turned on with **Enable Domain Squatting Detection** or the `domainSquatting.enabled` policy key. For how detection works, see [domain-squatting-detection.md](../features/domain-squatting-detection.md "mention").

## Rogue apps detection

Check warns users who reach a Microsoft sign-in for a known malicious OAuth application. It downloads the list of those applications from the [Huntress Labs rogue apps project](https://github.com/huntresslabs/rogueapps), configured in `rogue_apps_detection`:

```json
"rogue_apps_detection": {
  "enabled": true,
  "source_url": "https://huntresslabs.github.io/rogueapps/rogueapps.json",
  "cache_duration": 86400000,
  "update_interval": 43200000,
  "detection_action": "warn",
  "severity": "high",
  "auto_update": true
}
```

`update_interval` and `cache_duration` are in milliseconds: the list refreshes every 12 hours and a downloaded copy is kept for 24 hours.

## Browser console testing

These functions run Check's detection on the page open in the current tab. Open Developer Tools (F12), and in the **Console** tab change the JavaScript context from **top** to the Check extension before calling them:

```javascript
// Test detection patterns against the current page
testDetectionPatterns();

// Check whether detection rules are loaded
checkRulesStatus();

// Analyse the current page
analyzeCurrentPage();

// Run the phishing indicators against the current page
manualPhishingCheck();

// Run the full protection analysis again
rerunProtection();
```
