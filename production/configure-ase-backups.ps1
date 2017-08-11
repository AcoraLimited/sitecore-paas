Param(
    [string] [Parameter(Mandatory=$true)] $StorageAccountResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $StorageAccountName,
    [string] [Parameter(Mandatory=$true)] $WebAppResourceGroupName,
    [string] $StorageAccountLocation = "West Europe",
    [string] $StorageSku = "Standard_LRS", 
    [string] $BlobContainerName = "backups",
    [int] $BackupRetentionDays = 30,
    [int] $BackupFrequencyIntervalHours = 24
)

#Login-AzureRmAccount 
#Select-AzureRmSubscription -SubscriptionName "TODO"

# Create a new storage account if not found
if ( (Get-AzureRmStorageAccount -StorageAccountName $StorageAccountName -ResourceGroupName $StorageAccountResourceGroupName -ErrorAction Ignore) -eq $null) {
    New-AzureRmStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName -Location $StorageAccountLocation -SkuName $StorageSku -Kind Storage -EnableEncryptionService "Blob,File"
}

# Return the first storage account key and create a new SAS Url
$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName
$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageAccountKey[0].Value

# Create storage container
if ( (Get-AzureStorageContainer -Name $BlobContainerName -Context $context -ErrorAction Ignore) -eq $null ) {
    New-AzureStorageContainer -Name $BlobContainerName -Permission Off -Context $context
}

# Generate new SAS Url for the storage container
$sasUrl = New-AzureStorageContainerSASToken -Name $BlobContainerName -Permission rwdl -Context $context -ExpiryTime (Get-Date).AddYears(20) -FullUri

# Update all web apps with a backup plan
foreach ($webApp in (Get-AzureRmWebApp -ResourceGroupName $WebAppResourceGroupName)) {
    Edit-AzureRmWebAppBackupConfiguration -Name $webApp.Name -ResourceGroupName $WebAppResourceGroupName -StorageAccountUrl $sasUrl -FrequencyInterval $BackupFrequencyIntervalHours -FrequencyUnit Hour -StartTime ([DateTime]::Today).AddDays(1) -KeepAtLeastOneBackup -RetentionPeriodInDays $BackupRetentionDays
}


