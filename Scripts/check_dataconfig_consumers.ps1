[CmdletBinding()]
param(
    [string]$ProjectRoot = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = [System.IO.Path]::GetFullPath($ProjectRoot)

$runtimeRoots = @(
    'PlayerModule/Formal',
    'EnemyModule/Formal',
    'LevelModule/Formal',
    'Global',
    'UI',
    'Tools',
    'Scenes'
)

$consumerFiles = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($relativeRoot in $runtimeRoots) {
    $rootPath = Join-Path $ProjectRoot ($relativeRoot -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $rootPath -PathType Container)) {
        continue
    }
    foreach ($file in Get-ChildItem -LiteralPath $rootPath -Recurse -Filter '*.gd' -File) {
        if ($file.FullName -ieq (Join-Path $ProjectRoot 'Tools/ConfigValidator.gd')) {
            continue
        }
        $consumerFiles.Add($file)
    }
}

$consumerText = ($consumerFiles | ForEach-Object {
    Get-Content -LiteralPath $_.FullName -Raw
}) -join [Environment]::NewLine

$consumedFields = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$propertyPattern = [regex]'\.\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)'
foreach ($match in $propertyPattern.Matches($consumerText)) {
    [void]$consumedFields.Add($match.Groups['name'].Value)
}

# These fields describe resources to humans/tools; they intentionally do not affect runtime behavior.
$metadataWhitelist = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(
        'DataConfig/Level/LevelConfig.gd::level_id',
        'DataConfig/Level/LevelConfig.gd::level_name',
        'DataConfig/Skill/SkillConfig.gd::skill_id',
        'DataConfig/Skill/SkillConfig.gd::skill_name',
        'DataConfig/Skill/SkillConfig.gd::skill_icon'
    ),
    [System.StringComparer]::Ordinal
)

$exportPattern = [regex]'@export(?:_[A-Za-z]+)?(?:\([^\r\n]*\))?\s+var\s+(?<name>[A-Za-z_][A-Za-z0-9_]*)'
$errors = [System.Collections.Generic.List[string]]::new()
$checkedCount = 0
$configRoot = Join-Path $ProjectRoot 'DataConfig'

foreach ($configFile in Get-ChildItem -LiteralPath $configRoot -Recurse -Filter '*.gd' -File) {
    $relativePath = [System.IO.Path]::GetRelativePath($ProjectRoot, $configFile.FullName).Replace('\', '/')
    $content = Get-Content -LiteralPath $configFile.FullName -Raw
    foreach ($match in $exportPattern.Matches($content)) {
        $fieldName = $match.Groups['name'].Value
        $fieldKey = "$relativePath::$fieldName"
        $checkedCount += 1
        if (-not $consumedFields.Contains($fieldName) -and -not $metadataWhitelist.Contains($fieldKey)) {
            $errors.Add("$fieldKey 没有正式运行时消费者；请接入代码、删除失效字段，或明确归类为元数据")
        }
    }
}

# Non-enemy resources must serialize every exported value so balancing never depends on
# reading a GDScript default. EnemyConfig is intentionally a shared superset; it is
# checked below against only the base + concrete archetype fields that actually run.
foreach ($resourceFile in Get-ChildItem -LiteralPath $configRoot -Recurse -Filter '*.tres' -File) {
    $resourceText = Get-Content -LiteralPath $resourceFile.FullName -Raw
    $scriptMatch = [regex]::Match(
        $resourceText,
        '\[ext_resource type="Script" path="res://(?<path>DataConfig/[^"]+\.gd)"'
    )
    if (-not $scriptMatch.Success -or $scriptMatch.Groups['path'].Value -eq 'DataConfig/Enemy/EnemyConfig.gd') {
        continue
    }
    $schemaPath = Join-Path $ProjectRoot ($scriptMatch.Groups['path'].Value -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    $schemaText = Get-Content -LiteralPath $schemaPath -Raw
    $resourceRelativePath = [System.IO.Path]::GetRelativePath($ProjectRoot, $resourceFile.FullName).Replace('\', '/')
    foreach ($match in $exportPattern.Matches($schemaText)) {
        $fieldName = $match.Groups['name'].Value
        if (-not [regex]::IsMatch($resourceText, '(?m)^' + [regex]::Escape($fieldName) + '\s*=')) {
            $errors.Add("$resourceRelativePath::$fieldName 未显式写入资源，当前会依赖脚本默认值")
        }
    }
}

$enemyConfigConsumers = [ordered]@{
    'SlimeConfig.tres' = 'Enemy_Slime.gd'
    'StreetSlimeConfig.tres' = 'Enemy_LanternGhost.gd'
    'PaperEffigyConfig.tres' = 'Enemy_PaperEffigy.gd'
    'ShadowConfig.tres' = 'Enemy_LanternGhost.gd'
    'CyberWolfConfig.tres' = 'Enemy_CyberWolf.gd'
    'CleanerConfig.tres' = 'Enemy_CyberWolf.gd'
    'SecurityConfig.tres' = 'Enemy_CyberWolf.gd'
    'CyberBullConfig.tres' = 'Enemy_CyberBull.gd'
    'LanternGhostConfig.tres' = 'Enemy_LanternGhost.gd'
    'BossHuadanConfig.tres' = 'Enemy_BossHuadan.gd'
}
$enemyBaseText = Get-Content -LiteralPath (Join-Path $ProjectRoot 'EnemyModule/Formal/EnemyBase.gd') -Raw
$enemyFieldPattern = [regex]'\bconfig\s*\.\s*(?<name>[A-Za-z_][A-Za-z0-9_]*)'
foreach ($entry in $enemyConfigConsumers.GetEnumerator()) {
    $resourcePath = Join-Path $ProjectRoot "DataConfig/Enemy/$($entry.Key)"
    $consumerPath = Join-Path $ProjectRoot "EnemyModule/Formal/$($entry.Value)"
    $resourceText = Get-Content -LiteralPath $resourcePath -Raw
    $consumerText = $enemyBaseText + (Get-Content -LiteralPath $consumerPath -Raw)
    $requiredFields = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($match in $enemyFieldPattern.Matches($consumerText)) {
        [void]$requiredFields.Add($match.Groups['name'].Value)
    }
    foreach ($fieldName in $requiredFields) {
        if (-not [regex]::IsMatch($resourceText, '(?m)^' + [regex]::Escape($fieldName) + '\s*=')) {
            $errors.Add("DataConfig/Enemy/$($entry.Key)::$fieldName 未显式写入，但 $($entry.Value) 会在运行时读取")
        }
    }
}

if ($errors.Count -gt 0) {
    foreach ($errorText in $errors) {
        Write-Error $errorText -ErrorAction Continue
    }
    exit 1
}

Write-Host "[dataconfig-usage] PASS — $checkedCount exported fields audited"
