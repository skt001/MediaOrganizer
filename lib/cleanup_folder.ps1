param(
    [Parameter(Mandatory = $true)][string]$Target
)

# List subfolders without following junctions/reparse points, then
# remove only empty ones (deepest first). Same contract as `rd` without /s.
if (-not (Test-Path -LiteralPath $Target)) { exit 0 }

$dirs = New-Object System.Collections.Generic.List[string]
$stack = New-Object System.Collections.Stack
$stack.Push($Target)

while ($stack.Count -gt 0) {
    $current = $stack.Pop()
    $children = Get-ChildItem -LiteralPath $current -Directory -Force -ErrorAction SilentlyContinue
    foreach ($child in $children) {
        if (($child.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            continue
        }
        $dirs.Add($child.FullName)
        $stack.Push($child.FullName)
    }
}

Write-Output ("Found {0} folders" -f $dirs.Count)

foreach ($dir in ($dirs | Sort-Object { $_.Length } -Descending)) {
    try {
        $any = $false
        foreach ($entry in [System.IO.Directory]::EnumerateFileSystemEntries($dir)) {
            $any = $true
            break
        }
        if (-not $any) {
            [System.IO.Directory]::Delete($dir)
            Write-Output "Removed: $dir"
        }
    } catch {
        # not empty, in use, or access denied — skip
    }
}
