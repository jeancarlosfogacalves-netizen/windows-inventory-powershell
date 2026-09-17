# Windows Inventory - Jean Carlos Fogaça
# Coleta informações básicas de hardware, sistema e rede
# e exporta os dados para CSV.

$ComputerName = $env:COMPUTERNAME
$LoggedUser = $env:USERNAME

$OS = Get-CimInstance Win32_OperatingSystem
$ComputerSystem = Get-CimInstance Win32_ComputerSystem
$CPU = Get-CimInstance Win32_Processor | Select-Object -First 1
$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

$IPv4 = Get-NetIPAddress -AddressFamily IPv4 `
    | Where-Object {
        $_.IPAddress -notlike "169.254.*" -and
        $_.IPAddress -ne "127.0.0.1"
    } `
    | Select-Object -ExpandProperty IPAddress

$DefaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" `
    | Sort-Object RouteMetric `
    | Select-Object -First 1 -ExpandProperty NextHop

$DNS = Get-DnsClientServerAddress -AddressFamily IPv4 `
    | Where-Object { $_.ServerAddresses.Count -gt 0 } `
    | Select-Object -ExpandProperty ServerAddresses

$LastBoot = $OS.LastBootUpTime
$Uptime = (Get-Date) - $LastBoot

$DiskInfo = foreach ($Disk in $Disks) {
    "$($Disk.DeviceID) Total: $([math]::Round($Disk.Size / 1GB, 2)) GB | Livre: $([math]::Round($Disk.FreeSpace / 1GB, 2)) GB"
}

$Inventory = [PSCustomObject]@{
    ComputerName    = $ComputerName
    LoggedUser      = $LoggedUser
    Manufacturer    = $ComputerSystem.Manufacturer
    Model           = $ComputerSystem.Model
    Windows         = $OS.Caption
    WindowsVersion  = $OS.Version
    CPU             = $CPU.Name
    RAM_GB          = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
    IPv4            = ($IPv4 -join ", ")
    DefaultGateway  = $DefaultGateway
    DNS             = ($DNS -join ", ")
    Uptime_Days     = [math]::Round($Uptime.TotalDays, 2)
    DiskInfo        = ($DiskInfo -join " | ")
    InventoryDate   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

$OutputFolder = Join-Path $PSScriptRoot "output"

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

$OutputFile = Join-Path $OutputFolder "$ComputerName-inventory.csv"

$Inventory | Export-Csv `
    -Path $OutputFile `
    -NoTypeInformation `
    -Encoding UTF8

Write-Host ""
Write-Host "Inventário concluído."
Write-Host "Arquivo salvo em: $OutputFile"
Write-Host ""

$Inventory | Format-List
