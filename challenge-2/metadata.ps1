#This will fetch the Metadata of Azure Instance in json format and display the value in user readable format

$metadata = Invoke-RestMethod -Method GET -Proxy $Null -Uri http://169.254.169.254/metadata/instance?api-version=2021-02-01 -Headers @{“Metadata”=”True”}

#Creating an Array List to render the store data
$data = New-Object System.Collections.ArrayList
$data.Add([pscustomobject] @{"Properties" = "Server Name"; "Data" = $metadata.compute.name}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "Azure Location"; "Data" = $metadata.compute.location}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "Resource Group"; "Data" = $metadata.compute.resourceGroupName}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "Os Type"; "Data" = $metadata.compute.osType}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "Os Sku"; "Data" = $metadata.compute.sku}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "VmSize"; "Data" = $metadata.compute.vmSize}) | Out-Null
$data.Add([pscustomobject] @{"Properties" = "Private IP"; "Data" = $metadata.network.interface.ipv4.ipAddress.privateIpAddress}) | Out-Null

#metadata converted to json
$metadatajson = Invoke-RestMethod -Method GET -Uri http://169.254.169.254/metadata/instance?api-version=2020-09-01 -Headers @{“Metadata”=”True”} | ConvertTo-JSON -Depth 99
$metadatajson | Out-File -FilePath "C:\metadatafile.json" -Force

#Display Azure Intance metadata in a readable format
Write-Output $data
