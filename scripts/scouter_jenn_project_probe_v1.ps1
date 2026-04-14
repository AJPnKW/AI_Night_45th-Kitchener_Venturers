#requires -version 5.1
<#
[CAPABILITY] scouter_jenn_project_probe=YES
File: scouter_jenn_project_probe_v1.ps1
Version: 1.0.0
Purpose: Capture project state, detect mirror/junction/link behavior, compare sibling project trees, stage key review files, and produce one upload-ready zip bundle.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string]$Message
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[{0}] {1}" -f $timestamp, $Message
    Write-Host $line
    Add-Content -Path $script:LogFile -Value $line
}

function Write-Section {
    param(
        [Parameter(Mandatory = $true)][string]$Title
    )
    Write-Log ('=' * 20 + ' ' + $Title + ' ' + '=' * 20)
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)][string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-RelativePathSafe {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$TargetPath
    )
    $baseUri = New-Object System.Uri(($BasePath.TrimEnd('\') + '\'))
    $targetUri = New-Object System.Uri($TargetPath)
    $relative = $baseUri.MakeRelativeUri($targetUri).ToString()
    return [System.Uri]::UnescapeDataString($relative).Replace('/', '\')
}

function Export-ItemInventory {
    param(
        [Parameter(Mandatory = $true)][string]$RootPath,
        [Parameter(Mandatory = $true)][string]$OutputCsvPath,
        [Parameter(Mandatory = $true)][string[]]$IncludeExtensions
    )

    $items = Get-ChildItem -LiteralPath $RootPath -Recurse -Force -File | Sort-Object FullName
    $rows = New-Object System.Collections.Generic.List[object]

    foreach ($item in $items) {
        $extension = $item.Extension.ToLowerInvariant()
        if ($IncludeExtensions -contains $extension) {
            try {
                $hashValue = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash
            }
            catch {
                $hashValue = 'HASH_ERROR'
            }

            $rows.Add([pscustomobject]@{
                relative_path   = Get-RelativePathSafe -BasePath $RootPath -TargetPath $item.FullName
                length          = $item.Length
                last_write_time = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                sha256          = $hashValue
            })
        }
    }

    $rows | Export-Csv -LiteralPath $OutputCsvPath -NoTypeInformation -Encoding UTF8
    return $rows
}

function Save-TextFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $parent = Split-Path -Parent $Path
    Ensure-Directory -Path $parent
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Run-CaptureCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][scriptblock]$ScriptBlock
    )
    try {
        $result = & $ScriptBlock 2>&1 | Out-String
    }
    catch {
        $result = "ERROR`r`n$($_ | Out-String)"
    }
    Save-TextFile -Path $FilePath -Content $result
}

function Copy-IfExists {
    param(
        [Parameter(Mandatory = $true)][string]$SourcePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )
    if (Test-Path -LiteralPath $SourcePath) {
        $parent = Split-Path -Parent $DestinationPath
        Ensure-Directory -Path $parent
        Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force
        return $true
    }
    return $false
}

function Get-LatestDirectoryMatch {
    param(
        [Parameter(Mandatory = $true)][string]$BasePath,
        [Parameter(Mandatory = $true)][string]$Filter
    )
    if (-not (Test-Path -LiteralPath $BasePath)) {
        return $null
    }

    $dir = Get-ChildItem -LiteralPath $BasePath -Directory -Filter $Filter -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    return $dir
}

$workspaceRoot = 'C:\Users\andrew\PROJECTS\Scouter_Jenn'
$peerRoot = 'C:\Users\andrew\PROJECTS\AI_Night_45th-Kitchener_Venturers'
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outRoot = Join-Path $workspaceRoot ('out\project_probe_' + $timestamp)
$bundleRoot = Join-Path $outRoot 'bundle'
$reportsRoot = Join-Path $outRoot 'reports'
$stagedRoot = Join-Path $bundleRoot 'staged_files'
$compareRoot = Join-Path $bundleRoot 'compare'
$systemRoot = Join-Path $bundleRoot 'system'
$zipPath = Join-Path $workspaceRoot ('out\project_probe_' + $timestamp + '.zip')
$script:LogFile = Join-Path $outRoot ('project_probe_' + $timestamp + '.log.txt')

Ensure-Directory -Path $workspaceRoot
Ensure-Directory -Path $outRoot
Ensure-Directory -Path $bundleRoot
Ensure-Directory -Path $reportsRoot
Ensure-Directory -Path $stagedRoot
Ensure-Directory -Path $compareRoot
Ensure-Directory -Path $systemRoot

Write-Section -Title 'START'
Write-Log ('Workspace root: ' + $workspaceRoot)
Write-Log ('Peer root: ' + $peerRoot)
Write-Log ('Output root: ' + $outRoot)
Write-Log ('Zip path: ' + $zipPath)

$progressId = 1
Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Capturing environment' -PercentComplete 5

Write-Section -Title 'ENVIRONMENT'
Run-CaptureCommand -FilePath (Join-Path $systemRoot 'pwd.txt') -ScriptBlock { Get-Location | Format-List * }
Run-CaptureCommand -FilePath (Join-Path $systemRoot 'powershell_version.txt') -ScriptBlock { $PSVersionTable | Format-List * }
Run-CaptureCommand -FilePath (Join-Path $systemRoot 'os_version.txt') -ScriptBlock { Get-CimInstance Win32_OperatingSystem | Format-List * }
Run-CaptureCommand -FilePath (Join-Path $systemRoot 'git_version.txt') -ScriptBlock { git --version }

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Capturing parent folder and reparse data' -PercentComplete 15

Write-Section -Title 'PARENT_FOLDER_ANALYSIS'
Run-CaptureCommand -FilePath (Join-Path $reportsRoot 'projects_parent_dir_force.txt') -ScriptBlock { Get-ChildItem -LiteralPath 'C:\Users\andrew\PROJECTS' -Force | Format-Table Mode,Attributes,LastWriteTime,Length,Name -AutoSize }
Run-CaptureCommand -FilePath (Join-Path $reportsRoot 'projects_parent_dir_al.txt') -ScriptBlock { cmd /c dir /AL "C:\Users\andrew\PROJECTS" }

$rootPaths = @($workspaceRoot, $peerRoot)
$rootMetaRows = New-Object System.Collections.Generic.List[object]

foreach ($rootPath in $rootPaths) {
    $name = Split-Path -Leaf $rootPath
    $exists = Test-Path -LiteralPath $rootPath
    if (-not $exists) {
        $rootMetaRows.Add([pscustomobject]@{
            path = $rootPath
            exists = $false
            mode = ''
            attributes = ''
            link_type = ''
            target = ''
            creation_time = ''
            last_write_time = ''
        })
        continue
    }

    $item = Get-Item -LiteralPath $rootPath -Force
    $targetValue = ''
    if ($null -ne $item.Target) {
        if ($item.Target -is [System.Array]) {
            $targetValue = ($item.Target -join '; ')
        }
        else {
            $targetValue = [string]$item.Target
        }
    }

    $rootMetaRows.Add([pscustomobject]@{
        path = $item.FullName
        exists = $true
        mode = $item.Mode
        attributes = [string]$item.Attributes
        link_type = [string]$item.LinkType
        target = $targetValue
        creation_time = $item.CreationTime.ToString('yyyy-MM-dd HH:mm:ss')
        last_write_time = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    })

    Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_item_format_list.txt')) -ScriptBlock { Get-Item -LiteralPath $rootPath -Force | Format-List * }
    Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_attrib.txt')) -ScriptBlock { cmd /c attrib "$rootPath" }

    if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
        Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_reparsepoint_query.txt')) -ScriptBlock { fsutil reparsepoint query "$rootPath" }
    }
    else {
        Save-TextFile -Path (Join-Path $reportsRoot ($name + '_reparsepoint_query.txt')) -Content 'NOT_A_REPARSE_POINT'
    }
}

$rootMetaPath = Join-Path $reportsRoot 'root_metadata.csv'
$rootMetaRows | Export-Csv -LiteralPath $rootMetaPath -NoTypeInformation -Encoding UTF8

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Capturing git state' -PercentComplete 25

Write-Section -Title 'GIT_STATE'
foreach ($rootPath in $rootPaths) {
    $name = Split-Path -Leaf $rootPath
    if (Test-Path -LiteralPath $rootPath) {
        Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_git_status.txt')) -ScriptBlock { git -C $rootPath status --short --branch }
        Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_git_remote_v.txt')) -ScriptBlock { git -C $rootPath remote -v }
        Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_git_branch_vv.txt')) -ScriptBlock { git -C $rootPath branch -vv }
        Run-CaptureCommand -FilePath (Join-Path $reportsRoot ($name + '_git_log_12.txt')) -ScriptBlock { git -C $rootPath log --oneline --decorate -n 12 }
    }
}

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Hashing canonical project files' -PercentComplete 40

Write-Section -Title 'INVENTORY_AND_HASH_COMPARE'
$includeExtensions = @(
    '.md', '.txt', '.html', '.css', '.js', '.json', '.yml', '.yaml',
    '.ps1', '.py', '.csv'
)

$currentInventoryPath = Join-Path $compareRoot 'scouter_jenn_inventory.csv'
$peerInventoryPath = Join-Path $compareRoot 'ai_night_45th_inventory.csv'

$currentRows = Export-ItemInventory -RootPath $workspaceRoot -OutputCsvPath $currentInventoryPath -IncludeExtensions $includeExtensions
$peerRows = @()
if (Test-Path -LiteralPath $peerRoot) {
    $peerRows = Export-ItemInventory -RootPath $peerRoot -OutputCsvPath $peerInventoryPath -IncludeExtensions $includeExtensions
}

$currentMap = @{}
foreach ($row in $currentRows) {
    $currentMap[$row.relative_path] = $row
}

$peerMap = @{}
foreach ($row in $peerRows) {
    $peerMap[$row.relative_path] = $row
}

$allPaths = New-Object System.Collections.Generic.List[string]
$currentMap.Keys | ForEach-Object { $allPaths.Add($_) }
$peerMap.Keys | ForEach-Object {
    if (-not $allPaths.Contains($_)) {
        $allPaths.Add($_)
    }
}
$allPaths = $allPaths | Sort-Object

$compareRows = foreach ($relativePath in $allPaths) {
    $left = $null
    $right = $null
    $leftExists = $currentMap.ContainsKey($relativePath)
    $rightExists = $peerMap.ContainsKey($relativePath)
    if ($leftExists) { $left = $currentMap[$relativePath] }
    if ($rightExists) { $right = $peerMap[$relativePath] }

    [pscustomobject]@{
        relative_path = $relativePath
        scouter_exists = $leftExists
        ai_night_exists = $rightExists
        scouter_length = if ($leftExists) { $left.length } else { $null }
        ai_night_length = if ($rightExists) { $right.length } else { $null }
        scouter_last_write_time = if ($leftExists) { $left.last_write_time } else { '' }
        ai_night_last_write_time = if ($rightExists) { $right.last_write_time } else { '' }
        scouter_sha256 = if ($leftExists) { $left.sha256 } else { '' }
        ai_night_sha256 = if ($rightExists) { $right.sha256 } else { '' }
        status = if ($leftExists -and $rightExists) {
            if (($left.length -eq $right.length) -and ($left.sha256 -eq $right.sha256)) { 'MATCH' } else { 'DIFFERENT' }
        }
        elseif ($leftExists) {
            'ONLY_IN_SCOUTER_JENN'
        }
        else {
            'ONLY_IN_AI_NIGHT'
        }
    }
}

$compareCsv = Join-Path $compareRoot 'inventory_compare.csv'
$compareRows | Export-Csv -LiteralPath $compareCsv -NoTypeInformation -Encoding UTF8

$summary = [pscustomobject]@{
    compared_paths = ($compareRows | Measure-Object).Count
    matches = ($compareRows | Where-Object { $_.status -eq 'MATCH' } | Measure-Object).Count
    differences = ($compareRows | Where-Object { $_.status -eq 'DIFFERENT' } | Measure-Object).Count
    only_in_scouter_jenn = ($compareRows | Where-Object { $_.status -eq 'ONLY_IN_SCOUTER_JENN' } | Measure-Object).Count
    only_in_ai_night = ($compareRows | Where-Object { $_.status -eq 'ONLY_IN_AI_NIGHT' } | Measure-Object).Count
}

$summary | ConvertTo-Json | Save-TextFile -Path (Join-Path $compareRoot 'inventory_compare_summary.json')

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Staging files for review' -PercentComplete 60

Write-Section -Title 'STAGE_KEY_FILES'
$staticStageList = @(
    '.gitignore',
    'README.md',
    '.github\workflows\deploy-pages.yml',
    'AI_Workshop_4_ventures\config\delivery_system_config.json',
    'AI_Workshop_4_ventures\scripts\build_delivery_system.py',
    'AI_Workshop_4_ventures\scripts\run_delivery_build.ps1',
    'AI_Workshop_4_ventures\scripts\sync_public_site.ps1',
    'AI_Workshop_4_ventures\scripts\validate_delivery_system.ps1',
    'AI_Workshop_4_ventures\docs\repo_rationalization_plan.html',
    'AI_Workshop_4_ventures\docs\participant_workbook_and_forms_solution.html',
    'AI_Workshop_4_ventures\docs\participant_workbook_form_blueprint.html',
    'AI_Workshop_4_ventures\docs\participant_workbook_gap_assessment.html',
    'AI_Workshop_4_ventures\docs\participant_workbook_sheet_schema.html',
    'AI_Workshop_4_ventures\docs\participant_workbook_apps_script_spec.html',
    'AI_Workshop_4_ventures\docs\session_run_of_show_90_minutes.html',
    'AI_Workshop_4_ventures\docs\facilitator_answer_key.html',
    'AI_Workshop_4_ventures\docs\exercise_cards_guided_build_remix_stretch.html',
    'AI_Workshop_4_ventures\docs\pre_event_survey_and_feedback_plan.html',
    'AI_Workshop_4_ventures\docs\project_coordination_dashboard.html',
    'AI_Workshop_4_ventures\docs\current_state_validated_vs_unvalidated.html',
    'AI_Workshop_4_ventures\web\index.html',
    'AI_Workshop_4_ventures\web\participant\index.html',
    'AI_Workshop_4_ventures\web\participant\exercises.html',
    'AI_Workshop_4_ventures\web\participant\reflections.html',
    'AI_Workshop_4_ventures\web\facilitator\run-of-show.html'
)

$stageManifest = New-Object System.Collections.Generic.List[object]

foreach ($relativePath in $staticStageList) {
    $sourcePath = Join-Path $workspaceRoot $relativePath
    $destinationPath = Join-Path $stagedRoot $relativePath
    $copied = Copy-IfExists -SourcePath $sourcePath -DestinationPath $destinationPath
    $stageManifest.Add([pscustomobject]@{
        relative_path = $relativePath
        copied = $copied
    })
}

$latestBuildArtifact = Get-LatestDirectoryMatch -BasePath (Join-Path $workspaceRoot 'AI_Workshop_4_ventures\artifacts') -Filter 'build_*'
$latestValidationArtifact = Get-LatestDirectoryMatch -BasePath (Join-Path $workspaceRoot 'AI_Workshop_4_ventures\artifacts') -Filter 'validation_*'
$latestBuildReport = Get-LatestDirectoryMatch -BasePath (Join-Path $workspaceRoot 'AI_Workshop_4_ventures\reports') -Filter 'build_*'
$latestValidationReport = Get-LatestDirectoryMatch -BasePath (Join-Path $workspaceRoot 'AI_Workshop_4_ventures\reports') -Filter 'validation_*'

$dynamicFiles = @()
if ($null -ne $latestBuildArtifact) {
    $dynamicFiles += Join-Path $latestBuildArtifact.FullName 'build_manifest.json'
}
if ($null -ne $latestValidationArtifact) {
    $dynamicFiles += Join-Path $latestValidationArtifact.FullName 'validation_result.json'
}
if ($null -ne $latestBuildReport) {
    $dynamicFiles += Join-Path $latestBuildReport.FullName 'build_delivery_system_report.html'
}
if ($null -ne $latestValidationReport) {
    $dynamicFiles += Join-Path $latestValidationReport.FullName 'validation_result.html'
}

foreach ($absoluteSourcePath in $dynamicFiles) {
    if (Test-Path -LiteralPath $absoluteSourcePath) {
        $relativePath = Get-RelativePathSafe -BasePath $workspaceRoot -TargetPath $absoluteSourcePath
        $destinationPath = Join-Path $stagedRoot $relativePath
        $copied = Copy-IfExists -SourcePath $absoluteSourcePath -DestinationPath $destinationPath
        $stageManifest.Add([pscustomobject]@{
            relative_path = $relativePath
            copied = $copied
        })
    }
}

$stageManifest | Export-Csv -LiteralPath (Join-Path $reportsRoot 'staged_file_manifest.csv') -NoTypeInformation -Encoding UTF8

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Writing human summary' -PercentComplete 80

Write-Section -Title 'SUMMARY'
$rootMeta = Import-Csv -LiteralPath $rootMetaPath
$workspaceMeta = $rootMeta | Where-Object { $_.path -eq $workspaceRoot } | Select-Object -First 1
$peerMeta = $rootMeta | Where-Object { $_.path -eq $peerRoot } | Select-Object -First 1

$summaryLines = @()
$summaryLines += '=== START SUMMARY ==='
$summaryLines += ('workspace_root=' + $workspaceRoot)
$summaryLines += ('peer_root=' + $peerRoot)
$summaryLines += ('workspace_mode=' + $workspaceMeta.mode)
$summaryLines += ('workspace_attributes=' + $workspaceMeta.attributes)
$summaryLines += ('workspace_link_type=' + $workspaceMeta.link_type)
$summaryLines += ('workspace_target=' + $workspaceMeta.target)
$summaryLines += ('peer_mode=' + $peerMeta.mode)
$summaryLines += ('peer_attributes=' + $peerMeta.attributes)
$summaryLines += ('peer_link_type=' + $peerMeta.link_type)
$summaryLines += ('peer_target=' + $peerMeta.target)
$summaryLines += ('compared_paths=' + $summary.compared_paths)
$summaryLines += ('matches=' + $summary.matches)
$summaryLines += ('differences=' + $summary.differences)
$summaryLines += ('only_in_scouter_jenn=' + $summary.only_in_scouter_jenn)
$summaryLines += ('only_in_ai_night=' + $summary.only_in_ai_night)
$summaryLines += ('latest_build_artifact=' + $(if ($null -ne $latestBuildArtifact) { $latestBuildArtifact.FullName } else { '' }))
$summaryLines += ('latest_validation_artifact=' + $(if ($null -ne $latestValidationArtifact) { $latestValidationArtifact.FullName } else { '' }))
$summaryLines += ('latest_build_report=' + $(if ($null -ne $latestBuildReport) { $latestBuildReport.FullName } else { '' }))
$summaryLines += ('latest_validation_report=' + $(if ($null -ne $latestValidationReport) { $latestValidationReport.FullName } else { '' }))
$summaryLines += ('zip_path=' + $zipPath)
$summaryLines += '=== END SUMMARY ==='
Save-TextFile -Path (Join-Path $outRoot 'summary.txt') -Content ($summaryLines -join "`r`n")

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Creating zip bundle' -PercentComplete 92

Write-Section -Title 'ZIP'
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
Compress-Archive -Path (Join-Path $outRoot '*') -DestinationPath $zipPath -CompressionLevel Optimal -Force

Write-Progress -Id $progressId -Activity 'Project probe' -Status 'Complete' -PercentComplete 100
Write-Section -Title 'COMPLETE'
Write-Log ('Summary file: ' + (Join-Path $outRoot 'summary.txt'))
Write-Log ('Zip bundle: ' + $zipPath)
Write-Log 'Upload the zip bundle in chat.'

Write-Progress -Id $progressId -Activity 'Project probe' -Completed

Write-Host ''
Write-Host 'Press Enter to exit...'
[void][System.Console]::ReadLine()
