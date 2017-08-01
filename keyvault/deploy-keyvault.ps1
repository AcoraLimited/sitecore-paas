Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] $Location = "West Europe",
    [string] $LicenseFile = '',
    [string] $SitecoreXmCdMsDeployPackageUrl = '',
    [string] $SitecoreXmCmMsDeployPackageUrl= '',
    [string] [Parameter(Mandatory=$true)] $IaasServerLogin,
    [string] [Parameter(Mandatory=$true)] $SqlServerLogin,
    [securestring] [Parameter(Mandatory=$true)] $SqlServerPassword,
    [securestring] [Parameter(Mandatory=$true)] $SitecoreAdminPassword,
    [securestring] [Parameter(Mandatory=$true)] $IaasServerPassword,
    [array] $VSTSServicePrincipalNames
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
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location;

New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location -EnabledForTemplateDeployment:$true;
Start-Sleep -Seconds 10

$zipContent = Zip([IO.File]::ReadAllBytes($LicenseFile));
$zipString=[System.Convert]::ToBase64String($zipContent);
$secretLicense = ConvertTo-SecureString $zipString -AsPlainText -Force;
$secretIaasServerLogin = ConvertTo-SecureString $IaasServerLogin -AsPlainText -Force; 
$secretSqlServerLogin = ConvertTo-SecureString $SqlServerLogin -AsPlainText -Force;
$secretSitecoreXmCdMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCdMsDeployPackageUrl -AsPlainText -Force;
$secretSitecoreXmCmMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCmMsDeployPackageUrl -AsPlainText -Force;
$secretSitecoreXmCdLiteMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCdMsDeployPackageUrl.Replace(".scwdp.zip", "-nodb.scwdp.zip") -AsPlainText -Force;
$secretSitecoreXmCmLiteMsDeployPackageUrl = ConvertTo-SecureString $SitecoreXmCmMsDeployPackageUrl.Replace(".scwdp.zip", "-nodb.scwdp.zip") -AsPlainText -Force;

#Set Secrets
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreLicense' -SecretValue $secretLicense;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SqlServerLogin' -SecretValue $secretSqlServerLogin;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SqlServerPassword' -SecretValue $SqlServerPassword;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'IaasServerLogin' -SecretValue $secretIaasServerLogin;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'IaasServerPassword' -SecretValue $IaasServerPassword;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreAdminPassword' -SecretValue $SitecoreAdminPassword;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCdMsDeployPackageUrl' -SecretValue $secretSitecoreXmCdMsDeployPackageUrl;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCmMsDeployPackageUrl' -SecretValue $secretSitecoreXmCmMsDeployPackageUrl;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCdLiteMsDeployPackageUrl' -SecretValue $secretSitecoreXmCdLiteMsDeployPackageUrl;
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name 'SitecoreXmCmLiteMsDeployPackageUrl' -SecretValue $secretSitecoreXmCmLiteMsDeployPackageUrl;

#Set VSTS Policies
IF ($VSTSServicePrincipalNames.Count -ne 0){
    foreach ($spn in $VSTSServicePrincipalNames) {
        Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVaultName -ServicePrincipalName $spn -PermissionsToSecrets 'Get';
    }    
}
