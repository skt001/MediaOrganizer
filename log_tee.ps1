param(
    [Parameter(Mandatory = $true)][string]$LogFile,
    [Parameter(Mandatory = $true)][string]$Exe,
    [Parameter(Mandatory = $true)][string]$ArgFile
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
$utf8 = New-Object System.Text.UTF8Encoding $false

function Write-LogLine([string]$Line) {
    [Console]::WriteLine($Line)
    if ($LogFile) {
        [System.IO.File]::AppendAllText($LogFile, $Line + [Environment]::NewLine, $utf8)
    }
}

if (-not (Test-Path -LiteralPath $Exe)) {
    $resolved = Get-Command $Exe -ErrorAction SilentlyContinue
    if ($resolved) {
        $Exe = $resolved.Source
    } else {
        Write-LogLine "Error: executable not found: $Exe"
        exit 1
    }
}

$cmdArgs = @()
if (Test-Path -LiteralPath $ArgFile) {
    $cmdArgs = @(Get-Content -LiteralPath $ArgFile -Encoding UTF8)
}

try {
    & $Exe @cmdArgs 2>&1 | ForEach-Object { Write-LogLine ("$_") }
} catch {
    Write-LogLine $_.Exception.Message
    exit 1
}

$code = $LASTEXITCODE
if ($null -eq $code) { $code = 0 }
exit $code
