Param(
    [string] [Parameter(Mandatory=$true)] $StorageAccouuntResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $StorageAccountName,
    [string] $StorageAccountLocation = "West Europe",
    [string] $StorageSku = "Standard_LRS",
    [string] [Parameter(Mandatory=$true)] $WebAppResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $WebAppName,
    [string] $BlobContainerName = "backups"
)

#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "TODO"

# Create a new storage account
# TODO: Check if exists
New-AzureRmStorageAccount -ResourceGroupName $StorageAccouuntResourceGroupName -Name $StorageAccountName -Location $StorageAccountLocation -SkuName $StorageSku -Kind Storage -EnableEncryptionService "Blob,File"

# Return the first storage account key and create a new SAS Url
$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccouuntResourceGroupName -Name $StorageAccountName
$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey[0].Value

# Create storage container
# TODO: Check if exists
New-AzureStorageContainer -Name $BlobContainerName -Permission Off -Context $context

# Generate new SAS Url for tyhe backup plan
$sasUrl = New-AzureStorageContainerSASToken -Name $BlobContainerName -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddYears(20) -FullUri

# Update the web app with a backup plan
Edit-AzureRmWebAppBackupConfiguration -Name $WebAppName -ResourceGroupName $WebAppResourceGroupName -StorageAccountUrl $sasUrl -FrequencyInterval 6 -FrequencyUnit Hour -StartTime (Get-Date).AddHours(1) -KeepAtLeastOneBackup -RetentionPeriodInDays 30
