# Common Issues

Fixes for the problems users and administrators most often run into with Check, listed by what you see.

<details>

<summary>Some settings pages are missing, or I can't change a setting</summary>

Your organisation manages Check by policy. When it does, the options page hides the **General**, **Detection Rules** and **Branding** sections, shows **Managed by Policy** at the top, and locks any setting the policy controls. Ask your IT department to change the setting for you.

</details>

<details>

<summary>There's no Contact Admin button on the block page</summary>

**Contact Admin** appears only when a support email address is set. Set **Support Email** on the [Branding](../settings/branding.md) page, or ask your IT department to set it by policy.

</details>

<details>

<summary>There's no Report False Positive button on the block page</summary>

**Report False Positive** appears only when a webhook is set up to receive the reports. On the [General](../settings/general.md) page, turn on **Enable Generic Webhook**, enter a **Webhook URL**, and select **False Positive Reports** under **Event Types to Send**. If your organisation manages Check, ask your IT department. See [webhooks.md](../webhooks.md "mention") for what the report contains.

</details>

<details>

<summary>My custom branding doesn't show</summary>

* Enter **Primary Color** as a hex colour code with its `#`, for example `#F77F00`.
* Open the **Logo URL** in the same browser to confirm it loads.
* If your organisation sets branding by policy, the policy's values replace anything entered on the [Branding](../settings/branding.md) page.

</details>

<details>

<summary>Check's settings don't appear in the Group Policy editor</summary>

* Install the templates with `Deploy-ADMX.ps1`, run as an administrator. The script needs its `admx` folder beside it, with `Check-Extension.admx` inside and `Check-Extension.adml` in `admx\en-US`. It exits with an error if either file is missing.
* By default the script installs the templates on the local computer only. To install them in the domain's Central Store, run it with `-Scope Domain`.
* If you downloaded the files, unblock them first: right-click each file, select **Properties**, and select **Unblock**.
* Close and reopen the Group Policy editor, then look under **Computer Configuration** > **Administrative Templates** > **CyberDrain** > **Check - Phishing Protection**.

{% hint style="warning" %}
If the domain has no Central Store yet, creating one that holds only Check's templates hides every other administrative template from the Group Policy editor. Copy the existing templates into the new Central Store as well.
{% endhint %}

The full procedure is in [domain-deployment.md](../deployment/chrome-edge-deployment-instructions/windows/domain-deployment.md "mention").

</details>

<details>

<summary>Check ignores the settings I deployed</summary>

* Confirm the values exist in the registry under the key for each browser:

  | Browser | Registry key                                                                                              |
  | ------- | --------------------------------------------------------------------------------------------------------- |
  | Edge    | `HKLM\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\knepjpocdagponkonnbggpcnhnaikajg\policy`        |
  | Chrome  | `HKLM\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\benimdeioplgkhanklclahllklceahbe\policy`         |

* Open `edge://policy` or `chrome://policy` to see the policies the browser has loaded.
* Restart the browser after changing policy.
* Confirm Check was installed from the Chrome Web Store or Edge Add-ons. A copy loaded from a folder has a different extension ID, so policy set for the store ID does not reach it.

For Firefox, see [firefox-deployment.md](../deployment/firefox-deployment.md "mention").

</details>
