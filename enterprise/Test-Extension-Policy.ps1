# Quick Test Script for Check Extension Registry Settings
# Run as Administrator: Right-click PowerShell -> Run as Administrator
# Then execute: .\Test-Extension-Policy.ps1

# Extension IDs
$chromeExtId = "jlpkafnpidpjinmghilbonlgnilmkknn"
$edgeExtId = "jlpkafnpidpjinmghilbonlgnilmkknn"

# Registry paths
$chromePolicyKey = "HKLM:\SOFTWARE\Policies\Google\Chrome\3rdparty\extensions\$chromeExtId\policy"
$edgePolicyKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\extensions\$edgeExtId\policy"

# Test configuration (modify these values to test different settings)
$testConfig = @{
  showNotifications = 1
  enableValidPageBadge = 1
  enablePageBlocking = 0
  enableCippReporting = 0
  cippServerUrl = ""
  cippTenantId = ""
  customRulesUrl = ""
  updateInterval = 24
  enableDebugLogging = 1
}

$testDomainSquatting = @{
  enabled = 1
}

# Custom branding test values
$testBranding = @{
  companyName = "Test Company"
  productName = "Test Product"
  supportEmail = "test@example.com"
  primaryColor = "#FF6B00"
  logoUrl = ""
}

$testGenericWebhook = @{
  enabled = 0
  url = ""
  events = @("detection_alert", "page_blocked")
}

function Set-TestPolicies {
  param([string]$PolicyKey)
  
  if (!(Test-Path $PolicyKey)) {
    New-Item -Path $PolicyKey -Force | Out-Null
    Write-Output "Created policy key: $PolicyKey"
  }
  
  foreach ($key in $testConfig.Keys) {
    $value = $testConfig[$key]
    $type = if ($value -is [int]) { "DWord" } else { "String" }
    New-ItemProperty -Path $PolicyKey -Name $key -PropertyType $type -Value $value -Force | Out-Null
  }

  $domainSquattingKey = "$PolicyKey\domainSquatting"
  if (!(Test-Path $domainSquattingKey)) {
    New-Item -Path $domainSquattingKey -Force | Out-Null
  }
  New-ItemProperty -Path $domainSquattingKey -Name "enabled" -PropertyType DWord -Value $testDomainSquatting.enabled -Force | Out-Null
  
  $brandingKey = "$PolicyKey\customBranding"
  if (!(Test-Path $brandingKey)) {
    New-Item -Path $brandingKey -Force | Out-Null
  }
  
  foreach ($key in $testBranding.Keys) {
    New-ItemProperty -Path $brandingKey -Name $key -PropertyType String -Value $testBranding[$key] -Force | Out-Null
  }

  $genericWebhookKey = "$PolicyKey\genericWebhook"
  if (!(Test-Path $genericWebhookKey)) {
    New-Item -Path $genericWebhookKey -Force | Out-Null
  }
  New-ItemProperty -Path $genericWebhookKey -Name "enabled" -PropertyType DWord -Value $testGenericWebhook.enabled -Force | Out-Null
  New-ItemProperty -Path $genericWebhookKey -Name "url" -PropertyType String -Value $testGenericWebhook.url -Force | Out-Null

  $webhookEventsKey = "$genericWebhookKey\events"
  if (!(Test-Path $webhookEventsKey)) {
    New-Item -Path $webhookEventsKey -Force | Out-Null
  }
  Remove-ItemProperty -Path $webhookEventsKey -Name * -Force -ErrorAction SilentlyContinue | Out-Null
  for ($i = 0; $i -lt $testGenericWebhook.events.Count; $i++) {
    New-ItemProperty -Path $webhookEventsKey -Name ($i + 1) -PropertyType String -Value $testGenericWebhook.events[$i] -Force | Out-Null
  }
  
  Write-Output "Applied test policies to: $PolicyKey"
}

function Show-CurrentPolicies {
  param([string]$PolicyKey)
  
  if (Test-Path $PolicyKey) {
    Write-Output "`nCurrent policies in $PolicyKey"
    Get-ItemProperty -Path $PolicyKey | Format-List
    
    $brandingKey = "$PolicyKey\customBranding"
    if (Test-Path $brandingKey) {
      Write-Output "`nCustom Branding:"
      Get-ItemProperty -Path $brandingKey | Format-List
    }

    $genericWebhookKey = "$PolicyKey\genericWebhook"
    if (Test-Path $genericWebhookKey) {
      Write-Output "`nGeneric Webhook:"
      Get-ItemProperty -Path $genericWebhookKey | Format-List
    }

    $domainSquattingKey = "$PolicyKey\domainSquatting"
    if (Test-Path $domainSquattingKey) {
      Write-Output "`nDomain Squatting:"
      Get-ItemProperty -Path $domainSquattingKey | Format-List
    }
  } else {
    Write-Output "No policies set at: $PolicyKey"
  }
}

function Remove-TestPolicies {
  param([string]$PolicyKey)
  
  if (Test-Path $PolicyKey) {
    Remove-Item -Path $PolicyKey -Recurse -Force
    Write-Output "Removed test policies from: $PolicyKey"
  }
}

Write-Output "=== Check Extension Policy Testing Tool ==="
Write-Output ""
Write-Output "1. Apply test policies (Chrome & Edge)"
Write-Output "2. Show current policies"
Write-Output "3. Remove test policies"
Write-Output "4. Exit"
Write-Output ""
$choice = Read-Host "Select option"

switch ($choice) {
  "1" {
    Write-Output "`nApplying test policies..."
    Set-TestPolicies -PolicyKey $chromePolicyKey
    Set-TestPolicies -PolicyKey $edgePolicyKey
    Write-Output "`nDone! Restart Chrome/Edge to apply changes."
    Write-Output "View policies at: chrome://policy or edge://policy"
  }
  "2" {
    Show-CurrentPolicies -PolicyKey $chromePolicyKey
    Show-CurrentPolicies -PolicyKey $edgePolicyKey
  }
  "3" {
    Write-Output "`nRemoving test policies..."
    Remove-TestPolicies -PolicyKey $chromePolicyKey
    Remove-TestPolicies -PolicyKey $edgePolicyKey
    Write-Output "`nDone! Restart Chrome/Edge to clear changes."
  }
  "4" {
    exit
  }
  default {
    Write-Output "Invalid option"
  }
}
