param(
    [Parameter(Mandatory = $true)][string]$Target
)

$ErrorActionPreference = 'Stop'
Get-ChildItem -LiteralPath $Target -Recurse -File | ForEach-Object {
    $lower = $_.Name.ToLower()
    if ($_.Name -cne $lower) {
        $tmp = $_.FullName + '.__tmp__'
        Rename-Item -LiteralPath $_.FullName -NewName ($_.Name + '.__tmp__')
        Rename-Item -LiteralPath $tmp -NewName $lower
    }
}
