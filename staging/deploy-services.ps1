Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] $ResourceGroupLocation = "West Europe",
    [string] [Parameter(Mandatory=$true)] $SlotName,
    [string] $TemplateFile = ".\azuredeploy-services.json",
    [string] [Parameter(Mandatory=$true)] $KeyVaultName,
    [string] [Parameter(Mandatory=$true)] $KeyVaultResourceGroupName
)

#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "TODO"

New-AzureRmResourceGroupDeployment -Name $ResourceGroupName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -slotName $SlotName -keyVaultName $KeyVaultName -keyVaultResourceGroupName $KeyVaultResourceGroupName;
                                    