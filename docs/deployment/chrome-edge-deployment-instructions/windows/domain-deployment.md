# Domain Deployment

Deploy Check to Chrome and Edge on domain-joined or Intune-managed Windows devices. Each method force-installs the extension and applies its settings as managed policy, so users cannot remove Check or change the settings you set.

{% tabs %}
{% tab title="Intune" %}
Intune deploys Check as a Win32 app built from three PowerShell scripts: one installs and configures the extension, one removes it, and one tells Intune whether a device has the configuration you set.

## Prerequisites

* Microsoft Intune admin access
* The [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) (`IntuneWinAppUtil.exe`) to package the scripts as an `.intunewin` file
* Internet access to GitHub from the computer where you run the setup script, which downloads the latest scripts from the Check repository

## Deploy with Intune

{% stepper %}
{% step %}
### Generate the scripts

Download `Setup-Windows-Chrome-and-Edge.ps1` from the Check repository and run it on your own computer.

<a href="https://raw.githubusercontent.com/CyberDrain/Check/refs/heads/main/enterprise/Setup-Windows-Chrome-and-Edge.ps1" class="button primary">Download script</a>

The setup script prompts you for each Check setting, then for an output folder, and writes three configured scripts to that folder:

* `Deploy-Windows-Chrome-and-Edge.ps1`
* `Remove-Windows-Chrome-and-Edge.ps1`
* `Detect-Windows-Chrome-and-Edge.ps1`

The deploy and detection scripts carry the same values, which is how Intune confirms that a device has your configuration.

{% hint style="info" %}
You can also download the three scripts directly from the `enterprise` folder of the Check repository and edit the configuration block by hand. Give the deploy and detection scripts identical values.
{% endhint %}
{% endstep %}

{% step %}
### Package the scripts

Place the three configured scripts in one folder, then run:

```powershell
.\IntuneWinAppUtil.exe -c "C:\path\to\scripts\folder" -s "Deploy-Windows-Chrome-and-Edge.ps1" -o "C:\path\to\output"
```

This creates `Deploy-Windows-Chrome-and-Edge.intunewin`.
{% endstep %}

{% step %}
### Create the Win32 app

1. Open the [Microsoft Intune admin center](https://intune.microsoft.com).
2. Go to **Apps** > **Windows**.
3. Select **Add**, choose **Windows app (Win32)**, then select **Select**.
4. Upload the `.intunewin` file from the previous step.
{% endstep %}

{% step %}
### Enter the app information

| Field       | Value                                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------------------ |
| Name        | `Check by CyberDrain - Browser Extension`                                                                    |
| Description | `Deploys and configures the Check by CyberDrain phishing protection extension for Chrome and Edge browsers.` |
| Publisher   | Your company name or `CyberDrain`                                                                            |
{% endstep %}

{% step %}
### Configure the program

| Field                   | Value                                                                             |
| ----------------------- | --------------------------------------------------------------------------------- |
| Install command         | `powershell.exe -ExecutionPolicy Bypass -File Deploy-Windows-Chrome-and-Edge.ps1` |
| Uninstall command       | `powershell.exe -ExecutionPolicy Bypass -File Remove-Windows-Chrome-and-Edge.ps1` |
| Install behavior        | **System**                                                                        |
| Device restart behavior | **No specific action**                                                            |

The scripts write to `HKEY_LOCAL_MACHINE`, so **Install behavior** must be **System**.
{% endstep %}

{% step %}
### Set the requirements

| Field                         | Value                                                   |
| ----------------------------- | ------------------------------------------------------- |
| Operating system architecture | **64-bit**                                              |
| Minimum operating system      | **Windows 10 1607** (or your minimum supported version) |
{% endstep %}

{% step %}
### Add the detection rule

1. Under **Detection rules**, select **Use a custom detection script**.
2. Upload `Detect-Windows-Chrome-and-Edge.ps1`.
3. Set the following:

| Field                                          | Value  |
| ---------------------------------------------- | ------ |
| Run script as 32-bit process on 64-bit clients | **No** |
| Enforce script signature check                 | **No** |

The detection script checks that every registry value the deploy script writes exists and matches. It exits with code `0` when everything matches, so Intune reports the app as installed, and with code `1` when any value is missing or different, so Intune runs the install again.
{% endstep %}

{% step %}
### Assign the app

1. Under **Assignments**, select **Add group** under **Required**.
2. Choose your target:
   * **All devices**: every Intune-managed Windows device
   * **All users**: devices used by any licensed user
   * **Select groups**: specific Microsoft Entra ID groups
3. Select **Review + create**, then **Create**.
{% endstep %}
{% endstepper %}

## Update settings

{% stepper %}
{% step %}
### Generate new scripts

Run the setup script again with the new values, or edit the configuration block in both the deploy and detection scripts so the two match.
{% endstep %}

{% step %}
### Package the new deploy script

Run `IntuneWinAppUtil.exe` again to build a new `.intunewin` file.
{% endstep %}

{% step %}
### Update the app in Intune

In the existing app, upload the new `.intunewin` file, then under **Detection rules** upload the new `Detect-Windows-Chrome-and-Edge.ps1`. Alternatively, delete the app and create it again with the new files.
{% endstep %}
{% endstepper %}

Devices still carrying the old values fail the new detection script, so Intune reports the app as not installed and runs the new deploy script. If you replace only the package, the old detection script keeps passing on existing devices and they keep the old settings.

## Uninstall

* **Change the assignment to Uninstall:** in Intune, change the app assignment from **Required** to **Uninstall**. Intune runs `Remove-Windows-Chrome-and-Edge.ps1` on the targeted devices, which removes the Check policy values and the force-install entries, so Chrome and Edge uninstall the extension.
* **Delete the app:** deleting the app from Intune stops management but leaves the registry values on devices that already have them, so Check stays installed and configured.

## Troubleshooting

* **Extension not appearing after deployment:** confirm that the install ran as **System**, not as the user. Check that registry keys exist under `HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionSettings\` and `HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionSettings\`.
* **Intune keeps reinstalling the app:** the detection script values do not match what the deploy script wrote. Make sure both scripts have identical configuration values.
* **Detection script shows as failed:** run the detection script by hand on a test device as Administrator. It stops at the first mismatch and prints which value failed.
{% endtab %}

{% tab title="Group Policy" %}
Group Policy deploys Check through administrative templates (ADMX) that add a **CyberDrain** category to the Group Policy editor, with separate settings for Microsoft Edge and Google Chrome.

## Install the templates

{% stepper %}
{% step %}
### Download the files

Download these three files from the Check repository:

* [Deploy-ADMX.ps1](https://github.com/CyberDrain/Check/blob/main/enterprise/Deploy-ADMX.ps1)
* [Check-Extension.admx](https://github.com/CyberDrain/Check/blob/main/enterprise/admx/Check-Extension.admx)
* [Check-Extension.adml](https://github.com/CyberDrain/Check/blob/main/enterprise/admx/en-US/Check-Extension.adml)

Arrange them in this folder layout. The script looks for the templates in these subfolders and stops with an error if either file is missing:

```
Deploy-ADMX.ps1
admx\Check-Extension.admx
admx\en-US\Check-Extension.adml
```
{% endstep %}

{% step %}
### Run the deployment script

Open PowerShell as Administrator in the folder that holds `Deploy-ADMX.ps1`, then run one of the following.

To install the templates on this computer only:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Deploy-ADMX.ps1
```

To install the templates to the domain's Central Store, so they are available to every administrator editing Group Policy in the domain:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Deploy-ADMX.ps1 -Scope Domain
```

| Parameter     | What it does                                                                                                                                                                               |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `-Scope`      | `Local` (the default) copies the templates to `%SystemRoot%\PolicyDefinitions` on this computer. `Domain` copies them to `\\<domain>\SYSVOL\<domain>\Policies\PolicyDefinitions`.          |
| `-DomainName` | The domain to use with `-Scope Domain`. Defaults to the domain of the signed-in user. Set it when running from a computer outside the domain you are deploying to.                          |
| `-Uninstall`  | Removes the Check templates from the location `-Scope` points to instead of installing them.                                                                                                 |

A domain install needs an account with write access to the domain's SYSVOL share.

{% hint style="warning" %}
If the domain has no Central Store yet, `-Scope Domain` creates one containing only the Check templates. Group Policy editors in the domain then read templates from the Central Store alone, so every other administrative template disappears from them. Before you run the script, copy the contents of `%SystemRoot%\PolicyDefinitions` from a management computer to `\\<domain>\SYSVOL\<domain>\Policies\PolicyDefinitions`.
{% endhint %}
{% endstep %}

{% step %}
### Open the Check policies

In Group Policy Management, create a Group Policy Object or edit an existing one, then go to **Computer Configuration** > **Policies** > **Administrative Templates** > **CyberDrain** > **Check - Phishing Protection**. The settings are split into **Microsoft Edge** and **Google Chrome** folders.

![The Local Group Policy Editor showing the CyberDrain > Check - Phishing Protection > Microsoft Edge policies](<../../../.gitbook/assets/image (2).png>)
{% endstep %}

{% step %}
### Enable the installation policies

Enable **Configure Check extension installation (Edge)** in the **Microsoft Edge** folder and **Configure Check extension installation (Chrome)** in the **Google Chrome** folder. These are the policies that force-install Check, keep it updated from the browser's store, and pin it to the toolbar. The other Check policies configure the extension but do not install it.
{% endstep %}

{% step %}
### Configure the other settings

Set any other Check policies you need in each browser's folder, such as **Enable page blocking**, **Enable CIPP reporting**, and the branding settings. Each policy's help text in the editor describes what it sets.
{% endstep %}

{% step %}
### Link the policy

Link the Group Policy Object to the organisational units that hold your target computers. Devices pick up the policy at their next Group Policy refresh, or straight away after `gpupdate /force`.
{% endstep %}
{% endstepper %}

## Remove the templates

Run the script with `-Uninstall` and the same `-Scope` you installed with:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Deploy-ADMX.ps1 -Scope Domain -Uninstall
```

Removing the templates does not remove Check from devices. To stop deploying Check, unlink or delete the Group Policy Object first.
{% endtab %}

{% tab title="CIPP Standard" %}
A CIPP standard deploys Check the same way as the [#intune](domain-deployment.md#intune "mention") method, with CIPP creating the install and detection scripts for you.

For setup, see the [CIPP Standards documentation](https://standards.cipp.app/standards/deploycheckchromeextension).
{% endtab %}
{% endtabs %}
