$Param = if ($args[0]) { $args[0] | ConvertFrom-Json }
$Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\{16e0423f-7058-48c9-a204-72' +
    '5362b67639}\Default'
if ($Param.SensorTag) {
    $Del = @($Param.SensorTag)
    $Tag = (reg query $Key) -match "GroupingTags"
    $Val = ($Tag -split 'REG_SZ')[-1].Trim().Split(',').Where({ $Del -notcontains $_ }) -join ','
    if ($Val) {
        [void] (reg add $Key /v GroupingTags /d $Val /f)
    } else {
        [void] (reg delete $Key /v GroupingTags /f)
    }
}
$Output = [PSCustomObject] @{
    SensorTag = "$((((reg query $Key) -match 'GroupingTags') -split 'REG_SZ')[-1].Trim())"
} | ConvertTo-Json -Compress
if ($Output -and $Param.Log -eq $true) {
    $Rtr = Join-Path $env:SystemRoot 'system32\drivers\CrowdStrike\Rtr'
    if ((Test-Path $Rtr) -eq $false) { New-Item $Rtr -ItemType Directory }
    $Output >> "$Rtr\remove_sensortag.json"
}
$Output