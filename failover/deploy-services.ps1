Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] $ResourceGroupLocation = "North Europe",
    [string] $TemplateFile = ".\azuredeploy-services.json",
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultResourceGroupName
)

#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "TODO"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation;
New-AzureRmResourceGroupDeployment -Name $ResourceGroupName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -keyVaultName $KeyVaultName -keyVaultResourceGroupName $KeyVaultResourceGroupName;