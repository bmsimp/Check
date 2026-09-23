---
hidden: true
noIndex: true
---

# Firefox Support

Check runs on Firefox 142 or later. In Firefox, Check's extension ID is `check@cyberdrain.com`, which every Firefox policy for Check refers to. To install Check on managed devices, see [firefox-deployment.md](deployment/firefox-deployment.md "mention").

## Differences from Chrome and Edge

| Area                 | Firefox                                                            | Chrome and Edge                                                  |
| -------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------- |
| Extension ID         | `check@cyberdrain.com`                                             | A separate store ID for each browser                             |
| Installing           | A Mozilla-signed `.xpi` file that you host                         | The Chrome Web Store or Edge Add-ons                             |
| Managed settings     | The `3rdparty` section of Firefox's `policies.json`                | Browser policy, set through the registry, Group Policy or MDM    |
| Pages on your device | Check does not scan pages opened from `file:///` addresses         | Check can scan pages opened from `file:///` addresses when the browser allows the extension access to file URLs |

## Try Check in Firefox

A temporary install runs Check from a copy of the repository until Firefox restarts. Use it to try Check or test detection rules, not for everyday protection.

{% stepper %}
{% step %}
### Get the repository

Clone or download the [Check repository](https://github.com/CyberDrain/Check).
{% endstep %}

{% step %}
### Switch the repository to Firefox

From the repository folder, run:

```bash
npm run build:firefox
```

This puts the Firefox manifest in place of the Chrome one.
{% endstep %}

{% step %}
### Load Check

In Firefox, open `about:debugging#/runtime/this-firefox`, select **Load Temporary Add-on**, and choose `manifest.json` from the repository folder.
{% endstep %}
{% endstepper %}

{% hint style="info" %}
To load the same folder in Chrome or Edge afterwards, run `npm run build:chrome` first to put the Chrome manifest back.
{% endhint %}

## Test detection

The repository's `test-pages` folder holds a page Check should block (`phishing-basic.html`) and one it should leave alone (`safe-page.html`), linked from `index.html`. Firefox does not let Check scan pages opened straight from disk, so serve the folder from a local web server and open it over `http://`. For testing against a real phishing kit, see [testing-check.md](troubleshooting/testing-check.md "mention").

## Troubleshooting

<details>

<summary>Check disappears when I restart Firefox</summary>

A temporary add-on is removed every time Firefox closes. Load it again from `about:debugging`, or install a signed `.xpi` through policy as described in [firefox-deployment.md](deployment/firefox-deployment.md "mention").

</details>

<details>

<summary>Firefox won't load Check</summary>

* Run `npm run build:firefox` in the repository folder before loading `manifest.json`.
* Confirm you are on Firefox 142 or later.
* Open the Browser Console (Ctrl+Shift+J) and read the error Firefox reports.

</details>

<details>

<summary>Check doesn't react to a page I opened from my computer</summary>

Firefox does not let Check scan pages opened from `file:///` addresses. Serve the page from a local web server and open it over `http://` or `https://`.

</details>

<details>

<summary>My Firefox policies don't take effect</summary>

See the troubleshooting section of [firefox-deployment.md](deployment/firefox-deployment.md "mention").

</details>
