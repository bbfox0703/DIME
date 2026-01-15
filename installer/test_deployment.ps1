# 測試部署腳本是否正確複製 .cin 文件
# Test if deployment script correctly copies .cin files

Write-Host "`n=== Testing Deployment Script ===" -ForegroundColor Cyan

# 1. 檢查 Tables 目錄是否存在
Write-Host "`n1. Checking Tables directory..." -ForegroundColor Yellow
$tablesDir = "..\Tables"
if (Test-Path $tablesDir) {
    $sourceFiles = Get-ChildItem "$tablesDir\*.cin"
    Write-Host "   [OK] Found $($sourceFiles.Count) .cin file(s) in Tables/" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Tables directory not found!" -ForegroundColor Red
    exit 1
}

# 2. 檢查當前目錄是否有 .cin 文件（應該沒有，因為還沒運行部署腳本）
Write-Host "`n2. Checking current directory before deployment..." -ForegroundColor Yellow
$currentFiles = Get-ChildItem "*.cin" -ErrorAction SilentlyContinue
if ($currentFiles) {
    Write-Host "   [INFO] Found $($currentFiles.Count) .cin file(s) already present" -ForegroundColor Gray
    Write-Host "   [INFO] These will be overwritten" -ForegroundColor Gray
} else {
    Write-Host "   [OK] No .cin files present (clean state)" -ForegroundColor Green
}

# 3. 檢查 deploy-installerx64.cmd 是否包含正確的 copy 指令
Write-Host "`n3. Checking deploy-installerx64.cmd..." -ForegroundColor Yellow
$deployScript = Get-Content "deploy-installerx64.cmd" -Raw
if ($deployScript -match 'copy.*Tables.*\.cin') {
    Write-Host "   [OK] Script contains correct .cin copy command" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Script missing .cin copy command!" -ForegroundColor Red
    Write-Host "   Expected: copy ..\Tables\*.cin ." -ForegroundColor Gray
    exit 1
}

# 4. 檢查 NSIS 腳本是否包含正確的 File 指令
Write-Host "`n4. Checking DIME-x64OnlyCleaned.nsi..." -ForegroundColor Yellow
$nsiScript = Get-Content "DIME-x64OnlyCleaned.nsi" -Raw
if ($nsiScript -match 'File "\*\.cin"') {
    Write-Host "   [OK] NSIS script contains correct .cin file instruction" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] NSIS script missing .cin file instruction!" -ForegroundColor Red
    Write-Host "   Expected: File `"*.cin`"" -ForegroundColor Gray
    exit 1
}

# 5. 檢查 check_install.ps1 是否包含 .cin 驗證邏輯
Write-Host "`n5. Checking check_install.ps1..." -ForegroundColor Yellow
$checkScript = Get-Content "check_install.ps1" -Raw
if ($checkScript -match 'Checking IME Tables.*\.cin') {
    Write-Host "   [OK] Verification script includes .cin check" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Verification script missing .cin check!" -ForegroundColor Red
    exit 1
}

# 6. 模擬複製操作（不實際複製，只顯示會複製什麼）
Write-Host "`n6. Simulating copy operation..." -ForegroundColor Yellow
Write-Host "   Would copy the following files:" -ForegroundColor Cyan
Get-ChildItem "$tablesDir\*.cin" | Select-Object -First 5 | ForEach-Object {
    Write-Host "   - $($_.Name) ($([math]::Round($_.Length/1KB, 2)) KB)" -ForegroundColor Gray
}
if ($sourceFiles.Count -gt 5) {
    Write-Host "   - ... and $($sourceFiles.Count - 5) more files" -ForegroundColor Gray
}
$totalSize = ($sourceFiles | Measure-Object -Property Length -Sum).Sum
Write-Host "   Total size: $([math]::Round($totalSize/1MB, 2)) MB" -ForegroundColor Cyan

Write-Host "`n=== Pre-Deployment Test Complete ===" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Run: deploy-installerx64.cmd" -ForegroundColor White
Write-Host "2. Check: dir *.cin (should show $($sourceFiles.Count) files)" -ForegroundColor White
Write-Host "3. Verify: DIME-x64Installer.exe was created" -ForegroundColor White
Write-Host "4. Install and run: check_install.ps1" -ForegroundColor White
Write-Host ""
