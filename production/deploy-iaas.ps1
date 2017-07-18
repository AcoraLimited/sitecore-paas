Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] $ResourceGroupLocation = "West Europe",
    [string] $TemplateFile = ".\azuredeploy-iaas.json",
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultResourceGroupName
)

#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "TODO"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation;
New-AzureRmResourceGroupDeployment -Name $ResourceGroupName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -keyVaultName $KeyVaultName -keyVaultResourceGroupName $KeyVaultResourceGroupName;