[CmdletBinding()]
param(
    [string]$ProjectRoot = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$pathPattern = [regex]'["''](?<path>res://[^"'']+)["'']'
$errors = [System.Collections.Generic.List[string]]::new()

$rg = Get-Command rg -ErrorAction SilentlyContinue
if ($rg) {
    $relativeFiles = @(& $rg.Source --files $ProjectRoot `
        -g '*.gd' -g '*.tscn' -g '*.tres' -g '*.gdshader' -g 'project.godot' `
        -g '!addons/godot_ai/**' -g '!LevelModule/Backup/**' -g '!.godot/**')
}
else {
    $relativeFiles = @(Get-ChildItem -LiteralPath $ProjectRoot -Recurse -File | Where-Object {
        $_.Extension -in @('.gd', '.tscn', '.tres', '.gdshader') -or $_.Name -eq 'project.godot'
    } | Where-Object {
        $_.FullName -notmatch '[\\/](?:addons[\\/]godot_ai|LevelModule[\\/]Backup|\.godot)[\\/]'
    } | ForEach-Object { $_.FullName })
}

$seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($fileEntry in $relativeFiles) {
    $sourceFile = if ([System.IO.Path]::IsPathRooted($fileEntry)) { $fileEntry } else { Join-Path $ProjectRoot $fileEntry }
    $content = Get-Content -LiteralPath $sourceFile -Raw
    foreach ($match in $pathPattern.Matches($content)) {
        $resourcePath = $match.Groups['path'].Value
        if ($resourcePath.IndexOfAny([char[]]'*?%{}') -ge 0 -or -not $seen.Add($resourcePath)) {
            continue
        }
        $relativePath = $resourcePath.Substring(6)
        $candidate = Join-Path $ProjectRoot ($relativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $candidate)) {
            # 可选资源缺失由运行时 ResourceLoader.exists() 与 ConfigValidator 分别处理。
            continue
        }

        $cursor = $ProjectRoot
        foreach ($segment in ($relativePath -split '/')) {
            $exactEntry = Get-ChildItem -LiteralPath $cursor -Force | Where-Object { $_.Name -ceq $segment } | Select-Object -First 1
            if (-not $exactEntry) {
                $errors.Add("$resourcePath 的大小写与磁盘不一致（来源：$sourceFile）")
                break
            }
            $cursor = $exactEntry.FullName
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($errorText in $errors) {
        Write-Error $errorText -ErrorAction Continue
    }
    exit 1
}

Write-Host "[path-case] PASS — $($seen.Count) literal res:// paths scanned"
