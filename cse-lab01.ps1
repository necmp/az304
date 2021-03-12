Set-NetFirewallProfile -All -Enabled False
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -DomainName "contoso.com" -DomainMode "WinThreshold" -ForestMode "WinThreshold" -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd1234" -AsPlainText -Force) -Force:$true
