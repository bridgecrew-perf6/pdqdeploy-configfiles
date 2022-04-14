# Source : https://www.reddit.com/r/pdq/comments/ppf7ch/pdq_and_wsus/hd7dvoc/?context=3
# Author : kramder : https://www.reddit.com/user/kramder/
# Date : 16.09.2021


# I use this powershell script in pdq deploy. You must have powershell 5 or higher. You may need to set strong cryptography on 64 bit .Net framework on OS's pre Server 2019.

# Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord

# Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord


# And the PS script. This will reboot after patches are installed. Test in a non production environment first.:


# Install required modules

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Install-Module pswindowsupdate -force

Import-Module PSWindowsUpdate -force

# End installing required modules

# SMTP Email Configuration Settings

$from = "someone@email.com"

$to = "someone@email.com"

$smtp = "mailserver.domain.com"

$sub = "$($env:COMPUTERNAME): Windows Updates Installed and Rebooted"

$sub1 = "$($env:COMPUTERNAME): No Updates Needed"

$body = "Server Windows Update Report"

$body1 = "No new updates found."

# This is needed if the smtp server requires authentication

# Define the email attachment report

$attachement = "c:\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log"

#$mycreds = New-Object System.Management.Automation.PSCredential ("smtp username", $secpasswd)

# Start WSUS updates

$updates = Get-wulist -verbose

$updatenumber = ($updates.kb).count

if ($updates -ne $null) {
    Install-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-File "c:\$(get-date -f yyyy-MM-dd)-WindowsUpdate.log" -force

    # Now let's send the email report
    Send-MailMessage -To $to -From $from -Subject $sub -Body $body -Attachments $attachement -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml
}

else{
    Send-MailMessage -To $to -From $from -Subject $sub1 -Body $body1 -SmtpServer $smtp -DeliveryNotificationOption Never -BodyAsHtml

}