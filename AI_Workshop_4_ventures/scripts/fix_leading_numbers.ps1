param(
    [string]$target_path = "C:\Users\andrew\PROJECTS\Scouter_Jenn\AI_Workshop_4_ventures"
)

$ErrorActionPreference = "Stop"

Write-Host "START: fixing names in $target_path"

if (-not (Test-Path -LiteralPath $target_path)) {
    Write-Host "ERROR: target path not found: $target_path" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
    [void][System.Console]::ReadLine()
    exit 1
}

# files and folders under target only
$items = Get-ChildItem -LiteralPath $target_path -Recurse -Force -ErrorAction Stop |
    Sort-Object FullName -Descending

foreach ($item in $items) {
    $original_name = $item.Name
    $new_name = $original_name -replace '^\d+[\s._-]+', ''

    if ($new_name -eq $original_name) {
        continue
    }

    $parent_dir = Split-Path -Path $item.FullName -Parent

    if ([string]::IsNullOrWhiteSpace($parent_dir)) {
        Write-Host "SKIPPED: could not determine parent for $($item.FullName)" -ForegroundColor Yellow
        continue
    }

    $new_full_path = Join-Path -Path $parent_dir -ChildPath $new_name

    if (Test-Path -LiteralPath $new_full_path) {
        Write-Host "SKIPPED (exists): $original_name -> $new_name" -ForegroundColor Yellow
        continue
    }

    try {
        Rename-Item -LiteralPath $item.FullName -NewName $new_name -ErrorAction Stop
        Write-Host "RENAMED: $original_name -> $new_name" -ForegroundColor Green
    }
    catch {
        Write-Host "FAILED: $original_name -> $new_name" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# optional: rename root folder itself if it starts with numbers
$root_name = Split-Path -Path $target_path -Leaf
$root_parent = Split-Path -Path $target_path -Parent
$new_root_name = $root_name -replace '^\d+[\s._-]+', ''

if ($new_root_name -ne $root_name -and -not [string]::IsNullOrWhiteSpace($root_parent)) {
    $new_root_path = Join-Path -Path $root_parent -ChildPath $new_root_name

    if (-not (Test-Path -LiteralPath $new_root_path)) {
        try {
            Rename-Item -LiteralPath $target_path -NewName $new_root_name -ErrorAction Stop
            Write-Host "ROOT RENAMED: $root_name -> $new_root_name" -ForegroundColor Green
        }
        catch {
            Write-Host "FAILED ROOT RENAME: $root_name -> $new_root_name" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
    else {
        Write-Host "SKIPPED ROOT RENAME (exists): $new_root_name" -ForegroundColor Yellow
    }
}

Write-Host "COMPLETE"

Write-Host ""
Write-Host "Press ENTER to exit..." -ForegroundColor Yellow
[void][System.Console]::ReadLine()

