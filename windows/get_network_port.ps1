$Param = if ($args[0]) { $args[0] | ConvertFrom-Json }
$Process = Get-Process | Select-Object Id, Name
$Output = @(@(Get-NetTcpConnection -EA 0 | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State,
OwningProcess) + @(Get-NetUDPEndpoint -EA 0 | Select-Object LocalAddress, LocalPort)) | ForEach-Object {
    $Protocol = if ($_.State) { 'TCP' } else { 'UDP' }
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('Protocol',$Protocol)))
    $_ | Select-Object Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess
}
if ($Param.Filter) {
    $Output = $Output | Where-Object { $_.LocalPort -match $Param.Filter -or $_.RemotePort -match $Param.Filter }
}
$Output | ForEach-Object {
    $_.PSObject.Properties.Add((New-Object PSNoteProperty('OwningProcessName',
        ($Process | Where-Object Id -eq $_.OwningProcess).Name)))
}
if ($Output -and $Param.Log -eq $true) {
    $Rtr = Join-Path $env:SystemRoot 'system32\drivers\CrowdStrike\Rtr'
    if ((Test-Path $Rtr) -eq $false) { New-Item $Rtr -ItemType Directory }
    $Output | ForEach-Object { $_ | ConvertTo-Json -Compress >> "$Rtr\get_network_port.json" }
}
$Output | ForEach-Object { $_ | ConvertTo-Json -Compress }