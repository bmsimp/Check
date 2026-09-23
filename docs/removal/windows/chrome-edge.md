# Chrome and Edge (Windows)

The removal script uninstalls Check from Chrome and Edge on a Windows device and removes every Check policy value that deployment created, including the domain squatting, webhook, branding, and allowlist settings.

{% hint style="danger" %}
The script deletes the force-install entries as well as the settings, so Chrome and Edge uninstall Check and the device loses its phishing protection.
{% endhint %}

## Before you run the script

Stop whatever deployed Check from applying it again. Group Policy, Intune, a CIPP standard, and a scheduled RMM script all write the policy values back at their next refresh or run, which reinstalls Check. Unassign or unlink that policy, or remove the device from its scope, first.

For an Intune deployment, change the app assignment to **Uninstall** instead of running the script by hand. Intune then runs this script for you. See [#intune](../../deployment/chrome-edge-deployment-instructions/windows/domain-deployment.md#intune "mention").

## Run the script

{% stepper %}
{% step %}
### Download the script

<a href="https://raw.githubusercontent.com/CyberDrain/Check/refs/heads/main/enterprise/Remove-Windows-Chrome-and-Edge.ps1" class="button primary">Download the Uninstall Script from GitHub</a>
{% endstep %}

{% step %}
### Run it as Administrator

Run the script as Administrator or as SYSTEM on the target device, because it removes values from `HKEY_LOCAL_MACHINE`.
{% endstep %}

{% step %}
### Restart the browsers

Restart Chrome and Edge so they reload their policies.
{% endstep %}
{% endstepper %}

The script also gives you a clean baseline when you are testing policy changes and want to redeploy from scratch.
