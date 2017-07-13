Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName = "FFC-Sitecore-Shared",
    [string] [Parameter(Mandatory=$true)] $KeyVaultName = "FFC-Sitecore-Keyvault",
    [string] $Location = "West Europe",
    [string] $LicenseFile = "D:\dev\ffc\Sitecore-PaaS\private\license.xml",
    [string] $SitecoreXmCdMsDeployPackageUrl = '',
    [string] $SitecoreXmCmMsDeployPackageUrl = '',
    [string] [Parameter(Mandatory=$true)] $SqlServerLogin = "scadmin",
    [securestring] [Parameter(Mandatory=$true)] $SqlServerPassword,
    [securestring] [Parameter(Mandatory=$true)] $SitecoreAdminPassword,
    [string] $VSTSServicePrincipalName = "https://VisualStudio/SPN080eb32b-8d77-436e-852b-f044bad72a56"
)

Function Zip
{
    param([byte[]]$content)
    $output = New-Object System.IO.MemoryStream; 
    $gzipStream = New-Object System.IO.Compression.GzipStream ($output , ([IO.Compression.CompressionMode]::Compress));
    $gzipStream.Write($content, 0, $content.Length);
    $gzipStream.Close();
    return $output.ToArray();
}

#Login-AzureRmAccount;
#Select-AzureRmSubscription -SubscriptionName "TODO"
#New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location;

New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForTemplateDeployment:$true;
Start-Sleep -Seconds 10

$zipContent = Zip([IO.File]::ReadAllBytes($LicenseFile));
$zipString=[System.Convert]::ToBase64String($zipContent);
$secretLicense = ConvertTo-SecureString $zipString -AsPlainText -Force;
$secretSqlServerLogin = ConvertTo-SecureString $SqlServerLogin -AsPlainText -Force;
$secretSitecoreXmCdMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCdMsDeployPackageUrl -AsPlainText -Force;
$secretSitecoreXmCmMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCmMsDeployPackageUrl -AsPlainText -Force;

#Set Secrets
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreLicense' -SecretValue $secretLicense;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SqlServerLogin' -SecretValue $secretSqlServerLogin;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SqlServerPassword' -SecretValue $SqlServerPassword;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreAdminPassword' -SecretValue $SitecoreAdminPassword;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCdMsDeployPackageUrl' -SecretValue $secretSitecoreXmCdMsDeployPackageUrl;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCmMsDeployPackageUrl' -SecretValue $secretSitecoreXmCmMsDeployPackageUrl;

#Set VSTS Policies
IF ([string]::IsNullOrWhitespace($VSTSServicePrincipalName)){
} else {
    Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVaultName -ServicePrincipalName $VSTSServicePrincipalName -PermissionsToSecrets 'Get';
}
