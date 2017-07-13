Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] $ResourceGroupLocation = "East US",
    [string] [Parameter(Mandatory=$true)] $SlotName,
    [string] $TemplateFile = ".\azuredeploy.json",#".\azuredeploy-msdeploy.json",
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultResourceGroupName
)

Function Unzip
{
    param([byte[]]$gzipContent)
    $input = New-Object System.IO.MemoryStream (,$zipContent); 
    $gzipStream = New-Object System.IO.Compression.GzipStream ($input, ([IO.Compression.CompressionMode]::Decompress));
    $output = New-Object System.IO.MemoryStream;
    $gzipStream.CopyTo($output);
    return $output.ToArray();
}

$secretLicense = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name "SitecoreLicense";
$zipContent = [System.Convert]::FromBase64String($secretLicense.SecretValueText);
$licenseFile = Unzip($zipContent);
$licenseFileContent = [System.Text.Encoding]::UTF8.GetString($licenseFile);

$parameters = New-Object -TypeName Hashtable;
$parameters.Add("slotName", $SlotName);
$parameters.Add("licenseXml", $licenseFileContent);
$parameters.Add("keyVaultName", $KeyVaultName);
$parameters.Add("keyVaultResourceGroupName", $KeyVaultResourceGroupName);

#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "TODO"
New-AzureRmResourceGroupDeployment -Name $ResourceGroupName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterObject $parameters;

                                    