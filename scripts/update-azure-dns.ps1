Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $ZoneName,    
    [string] [Parameter(Mandatory=$true)] $InputFile = 'input.csv'
)

# Create new DNS zone if not found
if ((Get-AzureRmDnsZone -Name $ZoneName -ResourceGroupName $ResourceGroupName -ErrorAction Ignore) -eq $null) {
    Write-Host "Azure DNS zone '$ZoneName' was not found, creating new DNS zone."
    New-AzureRmDnsZone -Name $ZoneName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
}

# Import entries from import CSV file
if (! (Test-Path -Path $InputFile)) {
    Write-Host "Input file '$InputFile' was not found, skipping record import."
} else {
    Write-Host "Importing DNS records into zone '$ZoneName' from input file '$InputFile'."    

    $zoneData = Import-Csv -Path $InputFile

    $zoneData | % {

        if ($_.Name -eq '') { $dnsName = '@'} else {$dnsName = $_.Name}
        $dnsType = $_.Type
        $dnsEntry = $_.Entry
        
        Write-Host "Creating DNS entry of type '$dnsType' for '$dnsName': $dnsEntry"
        
        switch ($_.Type) {
            "A" {
                New-AzureRmDnsRecordSet -Name $dnsName -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -Ttl 3600 -RecordType $dnsType -DnsRecords (New-AzureRmDnsRecordConfig -Ipv4Address "$dnsEntry")
              }
            "CNAME" {
                New-AzureRmDnsRecordSet -Name $dnsName -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -Ttl 3600 -RecordType $dnsType -DnsRecords (New-AzureRmDnsRecordConfig -Cname "$dnsEntry")
            }
            "MX" {
                $mxHost = $dnsEntry.Split(' ')[1]
                $mxPreference = $dnsEntry.Split(' ')[0]
                New-AzureRmDnsRecordSet -Name $dnsName -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -Ttl 3600 -RecordType $dnsType -DnsRecords (New-AzureRmDnsRecordConfig -Exchange "$mxHost" -Preference $mxPreference)
            }
            "TXT" {                
                New-AzureRmDnsRecordSet -Name $dnsName -ZoneName $ZoneName -ResourceGroupName $ResourceGroupName -Ttl 3600 -RecordType $dnsType -DnsRecords (New-AzureRmDnsRecordConfig -Value $dnsEntry)
            }
            default {
                Write-Host "Unknown or unsupported DNS record type: $($_.Type)"
            }
        }
        
    }
        

}


<!-- Custom URL Rewrite - Acora -->
<rewrite>
  <rules>
    <rule name="Redirect to www" stopProcessing="true">
      <match url="(.*)" />
      <conditions trackAllCaptures="true">
        <add input="{CACHE_URL}" pattern="^(.+)://" />
        <add input="{HTTP_HOST}" pattern="^fulhamfc\.com$" />
      </conditions>
      <action type="Redirect" url="{C:1}://www.fulhamfc.com/{R:1}" />
    </rule>
  </rules>      
</rewrite>
<!-- Custom URL Rewrite - Acora -->




