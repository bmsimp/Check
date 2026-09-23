---
description: >-
  Deploy Check to Chrome and Edge on Windows devices through your RMM's
  scripting engine.
---

# RMM Deployment

Deploy Check to Windows devices through your RMM. Most methods below run the deployment script from [#powershell](manual-deployment.md#powershell "mention"). If your RMM is not listed, run the same script through its scripting engine.

{% hint style="warning" %}
The deployment script has no parameters and reads no environment variables, so script variables defined in an RMM have no effect. Edit the variables in the script body before you add it to your RMM. The script writes to `HKEY_LOCAL_MACHINE`, so run it as SYSTEM.
{% endhint %}

<details>

<summary>Action1</summary>

Save the script from [#powershell](manual-deployment.md#powershell "mention") as a `.ps1` file and deploy it through a [custom package in the software repository](https://www.action1.com/documentation/add-custom-packages-to-app-store/) or the [script library](https://www.action1.com/documentation/script-library/). Run it as the system account.

</details>

<details>

<summary>Acronis RMM</summary>

Use the script from [#powershell](manual-deployment.md#powershell "mention") to [create a script in the Script repository](https://www.acronis.com/en-us/support/documentation/CyberProtectionService/#cyber-scripting-creating-script.html), then run it through a [Script Plan](https://www.acronis.com/en-us/support/documentation/CyberProtectionService/#cyber-scripting-scripting-plans.html) as the system account.

</details>

<details>

<summary>ConnectWise Automate</summary>

1. Go to **Automation** > **Scripts** > **Script Manager**.
2. Create a new script.
3. Add a PowerShell Execute Script step, set to run as the system account.
4. Copy in the [#powershell](manual-deployment.md#powershell "mention") script.
5. Save and assign the script to your target devices.

</details>

<details>

<summary>Datto RMM</summary>

1. Go to **Automation** > **Components**.
2. Create a new Custom Component.
3. Copy in the [#powershell](manual-deployment.md#powershell "mention") script.
4. Save and publish the component.
5. Go to **Automation** > **Jobs** > **Create Job**.
6. Name the job `Check Browser Extension Deployment`.
7. Add the custom component you just created.
8. Target your selected devices.
9. Schedule the job.

Run the component as the system account.

</details>

<details>

<summary>ImmyBot</summary>

ImmyBot includes a pre-built Global Computer Task for deploying Check, configured through the ImmyBot interface.

First, create a deployment:

1. Go to **Deployments** in the left menu.
2. Select **New** to create a deployment.
3. Choose **Check by CyberDrain** from the available global tasks.
4. Choose the enforcement type:
   * **Required**: applies automatically during maintenance sessions
   * **Onboarding**: applies only during computer onboarding
   * **Ad Hoc**: runs only when triggered
5. Select the targets:
   * **Cross Tenant**: all computers across all tenants
   * **Single Tenant**: computers in one tenant
   * **Individual**: specific computers or users
   * Use filters, tags, or integration-specific targeting as needed

Next, set the task parameters:

1. Configure the task parameters for your environment:
   * Company branding options (company name, logo URL, primary colour)
   * CIPP reporting settings (server URL, tenant ID)
   * Notification and blocking preferences
   * A custom detection rules URL, if you use one
2. Set dependencies if required, for example to apply Windows updates first.
3. Configure scheduling if you use time-based deployment.

Then deploy and monitor:

1. Select **Create** to save the deployment.
2. Run a maintenance session on the target computers to apply the deployment.
3. Check the results in the maintenance session logs and address any failures.

Test with a deployment that targets a small group before rolling out widely, and create separate deployments for customers that need different configurations. For more on deployments, tasks, and maintenance sessions, see the [ImmyBot documentation](https://docs.immy.bot).

</details>

<details>

<summary>Kaseya VSA</summary>

1. Go to **Agent Procedures** > **Installer Wizards** > **Application Deploy**.
2. Upload the [#powershell](manual-deployment.md#powershell "mention") script as a `.ps1` file.
3. Choose Private or Shared Files.
4. Select the installer type.
5. Name the procedure `Check Browser Extension Deployment`.
6. Save and schedule the procedure, running it as the system account.

</details>

<details>

<summary>ManageEngine Endpoint Central</summary>

1. Go to **Manage** > **Extension Repository**.
2. Select **Add Extensions** and select the browser.
3. Select the Web Store Extension Type.
4. Enter the extension ID:
   1. Chrome: `benimdeioplgkhanklclahllklceahbe`
   2. Edge: `knepjpocdagponkonnbggpcnhnaikajg`
5. Select **Add** after each.
6. Go to **Browsers** > **Manage** > **Groups & Computers**.
7. Select the custom groups or computers to distribute the extension to.
8. Select **Distribute Extensions**.
9. Select the extensions you just added to the repository.
10. Select **Distribute**.

{% hint style="warning" %}
This method installs Check but does not configure its settings. To manage settings, deploy the [#powershell](manual-deployment.md#powershell "mention") script instead.
{% endhint %}

</details>

<details>

<summary>N-able N-Central</summary>

1. Go to **Configuration** > **Scheduled Tasks** > **Script/Software Repository**.
2. Select **Add** > **Script**.
3. Choose:
   1. Script Type: **PowerShell**
   2. Operating System: **Windows**
4. Upload the [#powershell](manual-deployment.md#powershell "mention") script as a `.ps1` file or paste it in.
5. Name the script `Check Browser Extension Deployment`.
6. Save the script.
7. Go to **Configuration** > **Scheduled Task** > **Add Task**.
8. Choose **Run a Script**.
9. Select the script you just uploaded.
10. Configure the task:
    1. Name: **Check Browser Extension Deployment**
    2. Target Devices: choose specific devices, groups, or filters
    3. Schedule: set your interval. Running at login or startup gives the best coverage, but a less frequent schedule still reaches every machine
    4. Execution Context: **System Account**
11. Select **Save and Activate**.

</details>

<details>

<summary>N-able N-Sight</summary>

1. Go to **Settings** > **Script Manager**.
2. Select **New**.
3. Enter `Check Browser Extension Deployment` for the name and a brief description.
4. Set a script timeout of 600 seconds.
5. Upload the [#powershell](manual-deployment.md#powershell "mention") script as a `.ps1` file, leaving `Script check and automated task` selected.
6. Select **Save**.
7. On the **All Devices** view, right-click your target Client or Site.
8. Select **Task** > **Add**.
9. Select the script you just uploaded.
10. Enter a name for the task, for example `<Client/Site> Check Browser Extension Deployment`.
11. Select `Once per day` for the frequency method.
12. Set a **Start Date**, **Start Time**, **End Date**, and **End Time**.
13. Set a maximum permitted execution time, for example 600 seconds.
14. Set `Run task as soon as possible if schedule is missed`.
15. Select **Next**.
16. Select the target devices and select **Add Task**.

</details>

<details>

<summary>NinjaOne</summary>

1. Go to **Administration** > **Library** > **Automation** > **Add** > **New Script**.
2. Enter:
   1. Name: `Check Browser Extension Deployment`
   2. Description: To deploy Check by CyberDrain for Edge and Chrome
   3. Categories: select as appropriate for your environment
   4. Language: PowerShell
   5. Operating System: Windows
   6. Architecture: All
   7. Run As: System
3. Copy the [#powershell](manual-deployment.md#powershell "mention") script into the editor.
4. Select **Save**.
5. Go to **Administration** > **Policies**.
6. Create a new policy, or add the automation to an existing policy that targets Windows devices.
7. Select **Scheduled Automation** on the left.
8. Select **Add a Scheduled automation**.
9. Select the script and set the frequency.
10. Select **Add**.
11. Select **Save**.

</details>

<details>

<summary>Pulseway</summary>

1. Go to **Automation** > **Scripts**.
2. Optionally, create a new **Script Category** called Browser Extensions.
3. Select **Create Script**.
4. Name the script `Check Browser Extension Deployment`.
5. Turn on **Enabled** under the Windows tab.
6. Select **PowerShell** as the script type, running as the system account.
7. Paste the [#powershell](manual-deployment.md#powershell "mention") script into the editor.
8. Select **Save Script**.
9. Go to **Automation** > **Tasks**.
10. Select **Create Task**.
11. Name the task `Check Browser Extension Deployment`.
12. Choose the PowerShell script you just added.
13. Set the **Scope** to **All Systems** or create a custom scope.
14. Set **Daily** for **Schedule**.
15. Save the task.

</details>

<details>

<summary>SuperOps.ai</summary>

1. Go to **Modules** > **Scripts**.
2. Select **+ Script**.
3. Name the script `Check Browser Extension Deployment`.
4. Choose **PowerShell** as the language.
5. Paste the [#powershell](manual-deployment.md#powershell "mention") script.
6. Set a timeout of 600 seconds.
7. Choose to run as **System/Root User**.
8. Save the script.
9. Deploy it with any of SuperOps' scheduled action methods. See the SuperOps documentation to choose one.

</details>

<details>

<summary>Syncro</summary>

1. Go to the **Scripts** tab.
2. Select **+Script**.
3. Name the script `Check Browser Extension Deployment`.
4. Choose **PowerShell** as the file type.
5. Set **Run As** to **System**.
6. Copy the [#powershell](manual-deployment.md#powershell "mention") script into the editor.
7. Select **Create Script**.
8. Go to **Policies**.
9. Select **+New Policy**.
10. Name the policy `Check Browser Extension Deployment`.
11. Choose the **Scripting** policy category.
12. Select **+Add Entry**.
13. Select the script you just created from the drop-down list.
14. Select a frequency of at least daily.
15. Select **Save Policy**.

</details>
