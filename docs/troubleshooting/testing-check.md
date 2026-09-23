# Testing Check

See Check block a phishing page without visiting a live one. Use this to confirm a deployment works, try out your own detection rules, or check a change to Check itself.

## Test pages in the repository

The [Check repository](https://github.com/CyberDrain/Check) has a `test-pages` folder with two pages, linked from `index.html`:

| Page                 | What Check should do                                           |
| -------------------- | -------------------------------------------------------------- |
| `phishing-basic.html` | Block it, or warn about it: a fake Microsoft 365 sign-in form |
| `safe-page.html`     | Nothing: an ordinary company portal page                       |

Serve the folder from a local web server and open the pages over `http://`. Firefox does not let Check scan pages opened straight from disk, and Chrome and Edge only allow it when the extension has access to file URLs. After opening each page, open the Check popup to see what Check found.

## Test against a real phishing kit

For a realistic adversary-in-the-middle (AITM) test, run Evilginx on your own hardware. [Jan Bakker's guide to running Evilginx 3.0 on Windows](https://janbakker.tech/running-evilginx-3-0-on-windows/) walks through the setup.

{% hint style="danger" %}
Never share phishing links, even for testing. Some phishing kits in circulation run malicious code in the visitor's browser.
{% endhint %}
