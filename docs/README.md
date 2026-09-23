---
icon: hand-wave
layout:
  width: default
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
  metadata:
    visible: true
---

# About Check

Check is a browser extension that protects users against Microsoft 365 phishing pages in real time. It spots fake Microsoft sign-in pages, including adversary-in-the-middle (AITM) phishing kits, and blocks them before users type their credentials.

## What is Check?

Check is built for organisations and managed service providers. It deploys and configures centrally by policy, records what it detects, and can report detections to CIPP for MSPs that manage many Microsoft 365 tenants, or to any webhook.

Check is available for **Google Chrome** and **Microsoft Edge**. Firefox support, for Firefox 142 or later, is coming soon.

Check is free and open source under the AGPL-3.0 licence, and you can deliver it to users fully white-labelled. The source is at [github.com/CyberDrain/Check](https://github.com/CyberDrain/Check).

Installing Check takes seconds and protects the user straight away.

<a href="https://microsoftedge.microsoft.com/addons/detail/check-by-cyberdrain/knepjpocdagponkonnbggpcnhnaikajg" class="button primary">Install for Edge</a> <a href="https://chromewebstore.google.com/detail/benimdeioplgkhanklclahllklceahbe" class="button primary">Install for Chrome</a>

## Why was Check created?

Check was created to give users better protection against AITM attacks. During a CyberDrain brainstorming session, CyberDrain's lead developer proposed a browser extension to protect users:

<figure><img src=".gitbook/assets/image.png" alt="Chat messages proposing a browser extension that confirms a Microsoft sign-in page is genuine"><figcaption></figcaption></figure>

A hackathon turned the idea into a proof of concept, which became Check. CyberDrain offers Check free to everyone as a community resource.

### What information does Check collect?

Check sends no browsing data to CyberDrain. It downloads detection rules and a list of known rogue Microsoft 365 apps, and it sends reports only to a CIPP instance or webhook that you set up yourself.

## How does it look?

Once Check is installed, its icon appears in the browser toolbar. You can [brand](settings/branding.md) the icon with your own logo and name.

<figure><img src=".gitbook/assets/image (1).png" alt="The Check popup open from the browser toolbar, showing the current page status and protection statistics"><figcaption></figcaption></figure>

When a page looks suspicious but Check is not confident it is phishing, Check shows a warning banner at the top of the page. When Check is confident the page is phishing or an AITM attack, it blocks the page and shows this instead:

<figure><img src=".gitbook/assets/image (3).png" alt="The Check block page, showing the reason for blocking and the Go Back and Contact Admin buttons"><figcaption></figcaption></figure>

The block page can also be [branded](settings/branding.md) to match your company colours. Alongside **Go Back**, it can show two more buttons:

* **Contact Admin** appears when a support email address is set in branding. It opens an email to that address with the blocked address, defanged so it cannot be clicked, and the reason Check blocked it.
* **Report False Positive** appears when a webhook is set up to receive false positive reports. It sends the details of the block to that webhook. See [webhooks.md](webhooks.md "mention").
