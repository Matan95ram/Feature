# Define the path for the CSV file
$csvPath = "\\your-path\inventory.csv"

# Read the existing inventory data (if the file exists)
if (Test-Path $csvPath) {
    # Convert the CSV into a list to allow adding new entries
    $inventoryData = [System.Collections.Generic.List[PSObject]](Import-Csv -Path $csvPath)
} else {
    # If the file doesn't exist, initialize an empty list
    $inventoryData = New-Object System.Collections.Generic.List[PSObject]
}

# Get the computer's hostname
$hostname = $env:COMPUTERNAME

# Get the computer's manufacturer, model, serial number (from BIOS), and service tag
$systemInfo = Get-WmiObject -Class Win32_ComputerSystem
$biosInfo = Get-WmiObject -Class Win32_BIOS
$manufacturer = $systemInfo.Manufacturer
$model = $systemInfo.Model
$serialNumber = $biosInfo.SerialNumber
$serviceTag = $biosInfo.SerialNumber  # Usually the same as serial number for many systems

# Check if this serial number already exists in the inventory data
$existingComputer = $inventoryData | Where-Object { $_."Serial Number" -eq $serialNumber }

# Get network adapters with IP information
$networkAdapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null }

# Get all monitors
$monitors = Get-WmiObject -Namespace root\wmi -Class WmiMonitorID

# Create an array for monitor serial numbers
$monitorSerialNumbers = @()

# Collect monitor serial numbers
foreach ($monitor in $monitors) {
    $monitorSerial = ([System.Text.Encoding]::ASCII.GetString($monitor.SerialNumberID -ne 0)).Trim()
    $monitorSerialNumbers += $monitorSerial
}

# Create an object with the inventory data for this computer
$inventoryObject = [PSCustomObject]@{
    "Hostname"      = $hostname
    "Manufacturer"  = $manufacturer
    "Model"         = $model
    "Serial Number" = $serialNumber
    "Service Tag"   = $serviceTag
}

# Add network information to the base object
foreach ($adapter in $networkAdapters) {
    $ipAddress = $adapter.IPAddress[0]
    $dhcpEnabled = $adapter.DHCPEnabled

    # Determine DHCP status
    $dhcpStatus = if ($dhcpEnabled) { "DHCP" } else { "Static" }

    # Add the network info to the object
    $inventoryObject | Add-Member -MemberType NoteProperty -Name "IP Address" -Value $ipAddress
    $inventoryObject | Add-Member -MemberType NoteProperty -Name "DHCP Status" -Value $dhcpStatus
}

# Add monitor serial numbers to the object dynamically
for ($i = 0; $i -lt $monitorSerialNumbers.Count; $i++) {
    $inventoryObject | Add-Member -MemberType NoteProperty -Name "Monitor $($i + 1) Serial Number" -Value $monitorSerialNumbers[$i]
}

# If the serial number exists, update the existing entry, otherwise add the new entry
if ($existingComputer) {
    # Update the existing record
    $index = $inventoryData.IndexOf($existingComputer)
    $inventoryData[$index] = $inventoryObject
} else {
    # Add the new record to the inventory data using the Add method
    $inventoryData.Add($inventoryObject)
}

# Export the updated data to the CSV file
$inventoryData | Export-Csv -Path $csvPath -NoTypeInformation -Force

Write-Output "Inventory has been updated in $csvPath"
