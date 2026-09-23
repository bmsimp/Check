# Branding

Branding replaces Check's name, logo, colour, and support contacts with your organisation's own. Your branding appears on the warning banner shown on suspicious pages, the block page, the extension popup, and this settings page. Individual users can leave every field empty and keep the default Check branding. Changes take effect when you click **Save Settings**.

## Company Information

### Company Name

Your organisation's name. The warning banner and the block page show it as **Protected by** followed by the name, the block page uses it in the browser tab title, and the popup shows it at the bottom. Empty by default, which keeps the default branding.

### Product Name

The name the extension goes by. It replaces **Check** in the popup, in the sidebar of this settings page, and in the block page heading, which reads **Access Blocked by** followed by the name. Leave it empty to keep **Check**.

### Support Email

The address users contact for help. When it is set, the block page shows a **Contact Admin** button that starts an email to this address; when it is empty, the button is hidden. Set it so that users who reach a blocked page can contact you.

### Support URL

The page the **Support** link in the popup opens, such as your help desk. Empty by default. Set it so the link takes users somewhere useful.

### Privacy URL

The page the **Privacy** link in the popup opens, such as your privacy policy. Empty by default.

### About URL

The page the **About** link in the popup opens. Leave it empty to open the **About** section of this settings page.

## Visual Customization

### Primary Color

The main colour of buttons, headings, and highlights in the popup, the block page, the warning banner, and this settings page. Choose it with the colour picker. The default is Check's orange, `#F77F00`.

### Logo URL

The web address of your logo, such as `https://yourcompany.com/logo.png`. It replaces the Check logo in the popup, the block page, the warning banner, this settings page, and the **Preview**. Use a square image; 48 × 48 to 128 × 128 pixels works well. The address must load in your users' browsers without signing in: if the logo does not appear, open the URL in a new tab to check.

## Preview

Shows how the popup header and a sample button look with your **Product Name**, **Logo URL**, and **Primary Color**, and updates as you type. This settings page also takes on the new colour straight away. Users see the changes only after you click **Save Settings**.

## Setting branding by policy

IT administrators can set branding for every user by policy instead of on each device, and a value set by policy takes precedence over anything entered here. For Chrome and Edge on Windows, see [domain-deployment.md](../deployment/chrome-edge-deployment-instructions/windows/domain-deployment.md "mention"). For Firefox, see [firefox-deployment.md](../deployment/firefox-deployment.md "mention").

{% hint style="warning" %}
When your organisation manages Check through policy, the **General**, **Detection Rules** and **Branding** sections are hidden, and the page header shows **Managed by Policy**. Your IT department sets these options for you.
{% endhint %}
