$Param = if ($args[0]) { $args[0] | ConvertFrom-Json }
$Output = (Get-Item -Path env: -EA 0).GetEnumerator().foreach{
    [PSCustomObject] @{ Name = $_.Key; Value = $_.Value }
}
if ($Output -and $Param.Log -eq $true) {
    $Rtr = Join-Path $env:SystemRoot 'system32\drivers\CrowdStrike\Rtr'
    if ((Test-Path $Rtr) -eq $false) { New-Item $Rtr -ItemType Directory }
    $Output | ForEach-Object { $_ | ConvertTo-Json -Compress >> "$Rtr\get_powershell_env.json" }
}
$Output | ForEach-Object { $_ | ConvertTo-Json -Compress }