# Firefox (Windows)

Remove Check from Firefox by deleting its entries from the Firefox policies file, `%ProgramFiles%\Mozilla Firefox\distribution\policies.json`.

## Before you edit the file

If a script or Intune wrote the policies file, stop it from running again first, or it writes the Check entries back. If you deployed Check with Firefox's Group Policy templates instead, remove the Check settings from that Group Policy Object rather than editing the file.

## Remove the entries

{% stepper %}
{% step %}
### Open the policies file

Open `%ProgramFiles%\Mozilla Firefox\distribution\policies.json` in a text editor running as Administrator.
{% endstep %}

{% step %}
### Delete the Check entries

Under `policies`, remove:

* the Check install URL from `Extensions.Install`
* `check@cyberdrain.com` from `Extensions.Locked`
* the `check@cyberdrain.com` block from `ExtensionSettings`
* the `check@cyberdrain.com` block from `3rdparty.Extensions`

Keep the file valid JSON, and leave any other policies in place.
{% endstep %}

{% step %}
### Restart Firefox

Restart Firefox so it reloads the policies.
{% endstep %}
{% endstepper %}

For the policy format, see [Firefox Deployment](../../deployment/firefox-deployment.md).
