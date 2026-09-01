[CmdletBinding()]
param(
    [string]$GodotPath = $env:GODOT_46_BIN,
    [switch]$SkipSceneSmoke,
    [switch]$SkipExport
)

$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

if ([string]::IsNullOrWhiteSpace($GodotPath)) {
    foreach ($commandName in @('godot4.6', 'godot4', 'godot')) {
        $candidate = Get-Command $commandName -ErrorAction SilentlyContinue
        if ($candidate) {
            $GodotPath = $candidate.Source
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($GodotPath) -or -not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw '未找到 Godot 4.6。请传入 -GodotPath，或设置 GODOT_46_BIN。'
}

$GodotPath = [System.IO.Path]::GetFullPath($GodotPath)
$versionLines = @(& $GodotPath --version 2>&1)
$versionExitCode = $LASTEXITCODE
$versionText = ($versionLines -join "`n").Trim()
if ($versionExitCode -ne 0 -or $versionText -notmatch '^4\.6(?:\.|$)') {
    throw "预检只接受 Godot 4.6，当前为：$versionText"
}
Write-Host "[preflight] Godot $versionText"

$projectSettingsPath = Join-Path $projectRoot 'project.godot'
$projectSettingsText = Get-Content -LiteralPath $projectSettingsPath -Raw
$editorSection = [regex]::Match($projectSettingsText, '(?ms)^\[editor\]\s*(?<body>.*?)(?=^\[|\z)')
if (-not $editorSection.Success -or $editorSection.Groups['body'].Value -notmatch '(?m)^import/use_multiple_threads=false\s*$') {
    throw 'project.godot 必须保持 editor/import/use_multiple_threads=false，以规避 Godot 4.6 动态字体并行导入的引擎竞态崩溃。'
}
Write-Host '[preflight] 字体导入线程安全设置 PASS'

function Invoke-GodotCheck {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string[]]$Arguments
    )

    Write-Host "[preflight] $Name"
    $outputLines = @(& $GodotPath @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $outputText = $outputLines -join "`n"
    foreach ($line in $outputLines) {
        Write-Host $line
    }
    if ($exitCode -ne 0) {
        throw "$Name 退出码为 $exitCode"
    }
    $blockingLines = @($outputLines | Where-Object {
        $_ -match '(?:SCRIPT ERROR:|ERROR:)' -or
        $_ -match 'Invalid UID:' -or
        $_ -match 'ObjectDB instances leaked at exit' -or
        $_ -match 'resources still in use at exit' -or
        $_ -match 'orphaned lambdas becoming invalid'
    })
    if ($blockingLines.Count -gt 0) {
        throw "$Name 输出了 Godot 错误或资源生命周期告警"
    }
}

$diffCheck = @(& git -C $projectRoot diff --check 2>&1)
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check 失败：`n$($diffCheck -join "`n")"
}
Write-Host '[preflight] git diff --check PASS'

& (Join-Path $PSScriptRoot 'check_resource_paths.ps1') -ProjectRoot $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw 'res:// 路径大小写审计失败'
}

& (Join-Path $PSScriptRoot 'check_dataconfig_consumers.ps1') -ProjectRoot $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw 'DataConfig 运行时消费者审计失败'
}

Invoke-GodotCheck -Name '脚本与资源编译' -Arguments @(
    '--headless', '--path', $projectRoot, '--editor', '--recovery-mode', '--quit'
)

Invoke-GodotCheck -Name '核心契约与 DataConfig 审计' -Arguments @(
    '--headless', '--path', $projectRoot, 'res://Tests/SelfTest/ContractTestRunner.tscn'
)

Invoke-GodotCheck -Name '正式主线真实转场冒烟' -Arguments @(
    '--headless', '--path', $projectRoot, 'res://Tests/SelfTest/TransitionSmokeRunner.tscn'
)

Invoke-GodotCheck -Name '主场景启动' -Arguments @(
    '--headless', '--path', $projectRoot, 'res://Tests/SelfTest/MainSceneSmokeRunner.tscn'
)

if (-not $SkipSceneSmoke) {
    $scenePaths = @(
        'res://LevelModule/Formal/Level_01.tscn',
        'res://LevelModule/Formal/Level_02.tscn',
        'res://LevelModule/Formal/Level_02_01.tscn',
        'res://LevelModule/Formal/Level_02_02.tscn',
        'res://LevelModule/Formal/Level_02_03.tscn',
        'res://LevelModule/Formal/Level_03.tscn',
        'res://LevelModule/Formal/Level_03_Official.tscn',
        'res://LevelModule/Formal/Level_04.tscn',
        'res://LevelModule/Formal/Level_05.tscn',
        'res://LevelModule/Formal/Level_fuzhan_01.tscn',
        'res://LevelModule/Formal/Level_fuzhan_02.tscn',
        'res://LevelModule/Formal/Level_final.tscn',
        'res://PlayerModule/Formal/Player_Warrior.tscn',
        'res://PlayerModule/Formal/Player_Warrior_Cyber.tscn',
        'res://PlayerModule/Formal/Player_Warrior_Lingnan.tscn',
        'res://EnemyModule/Formal/Enemy_Slime.tscn',
        'res://EnemyModule/Formal/Enemy_PaperEffigy.tscn',
        'res://EnemyModule/Formal/Enemy_LanternGhost.tscn',
        'res://EnemyModule/Formal/Enemy_CyberWolf.tscn',
        'res://EnemyModule/Formal/Enemy_CyberBull.tscn',
        'res://EnemyModule/Formal/Enemy_BossHuadan.tscn'
    )
    $smokeArguments = @('--headless', '--path', $projectRoot, 'res://Tests/SelfTest/SceneSmokeRunner.tscn', '--') + $scenePaths
    Invoke-GodotCheck -Name '正式场景实例化冒烟' -Arguments $smokeArguments
}

if (-not $SkipExport) {
    $tempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $exportPack = [System.IO.Path]::GetFullPath((Join-Path $tempRoot ("HackathonGame-preflight-{0}.pck" -f [guid]::NewGuid().ToString('N'))))
    if (-not $exportPack.StartsWith($tempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw '临时导出路径越出系统临时目录，已拒绝。'
    }
    try {
        Invoke-GodotCheck -Name 'Web 导出资源包' -Arguments @(
            '--headless', '--quiet', '--path', $projectRoot, '--export-pack', 'Web', $exportPack
        )
    }
    finally {
        if (Test-Path -LiteralPath $exportPack -PathType Leaf) {
            Remove-Item -LiteralPath $exportPack -Force
        }
    }
}

Write-Host '[preflight] ALL CHECKS PASSED'
