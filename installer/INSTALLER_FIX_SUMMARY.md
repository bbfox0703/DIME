# IME Tables (.cin 文件) 安裝修正摘要

## 問題描述

deploy-installerx64.cmd 沒有將 IME tables (*.cin 文件) 從 Tables/ 目錄複製到安裝程序中，導致安裝後輸入法無法正常使用（缺少字根表）。

## 修正內容

### 1. deploy-installerx64.cmd

**修正前**：
```batch
@echo off
mkdir "..\Installer\system32.x64"
copy ..\Release\DIMESettings.exe ..\Installer\
copy ..\Release\x64\DIME.dll ..\Installer\system32.x64\
"c:\Program Files (x86)\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi
```

**修正後**：
```batch
@echo off
mkdir "system32.x64" 2>nul
copy ..\Release\DIMESettings.exe .
copy ..\Release\x64\DIME.dll system32.x64\
copy ..\Tables\*.cin .
"c:\Program Files (x86)\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi
```

**變更說明**：
1. ✅ **修正目錄結構**：從使用 `..\Installer\` 改為使用當前目錄 (`installer/`)，與通用版本 `deploy-installer.cmd` 保持一致
2. ✅ **添加 .cin 複製**：新增 `copy ..\Tables\*.cin .` 指令，將所有字根表複製到 installer/ 目錄
3. ✅ **錯誤抑制**：添加 `2>nul` 抑制目錄已存在的錯誤訊息

### 2. DIME-x64OnlyCleaned.nsi

**修正前**：
```nsis
File "..\Installer\*.cin"
```

**修正後**：
```nsis
File "*.cin"
```

**變更說明**：
1. ✅ **路徑一致性**：從相對路徑 `..\Installer\*.cin` 改為當前目錄 `*.cin`，與其他文件（DIMESettings.exe）保持一致
2. ✅ **符合 NSIS 慣例**：NSIS 腳本從腳本所在目錄讀取文件

### 3. check_install.ps1

**修正前**：
```powershell
# Check program files
Write-Host "`n3. Checking Program Files..." -ForegroundColor Yellow
$installDir = "$env:ProgramFiles\DIME"
if (Test-Path $installDir) {
    Write-Host "   [OK] Install directory found at: $installDir" -ForegroundColor Green
    Get-ChildItem $installDir | Format-Table Name, Length, LastWriteTime -AutoSize
} else {
    Write-Host "   [FAIL] Install directory NOT found" -ForegroundColor Red
}
```

**修正後**：
```powershell
# Check program files
Write-Host "`n3. Checking Program Files..." -ForegroundColor Yellow
$installDir = "$env:ProgramFiles\DIME"
if (Test-Path $installDir) {
    Write-Host "   [OK] Install directory found at: $installDir" -ForegroundColor Green
    Get-ChildItem $installDir | Format-Table Name, Length, LastWriteTime -AutoSize

    # Check for .cin files specifically
    Write-Host "`n   Checking IME Tables (.cin files)..." -ForegroundColor Cyan
    $cinFiles = Get-ChildItem "$installDir\*.cin" -ErrorAction SilentlyContinue
    if ($cinFiles) {
        Write-Host "   [OK] Found $($cinFiles.Count) .cin file(s)" -ForegroundColor Green
        $cinFiles | Format-Table Name, Length -AutoSize
    } else {
        Write-Host "   [FAIL] No .cin files found - IME tables are missing!" -ForegroundColor Red
    }
} else {
    Write-Host "   [FAIL] Install directory NOT found" -ForegroundColor Red
}
```

**變更說明**：
1. ✅ **添加 .cin 檢查**：新增專門檢查 .cin 文件是否存在的邏輯
2. ✅ **計數顯示**：顯示找到的 .cin 文件數量
3. ✅ **明確錯誤提示**：如果缺少 .cin 文件，明確提示「IME tables are missing」

### 4. DIME-x86armUniversal.nsi (確認無需修改)

**當前狀態**：✅ **已正確配置**

```nsis
File "*.cin"
```

此文件已經正確包含 `File "*.cin"` 指令（第 224 行），且 `deploy-installer.cmd` 也正確複製了 .cin 文件。

---

## 目錄結構說明

### 修正前（不一致）

```
DIME/
├── installer/
│   ├── deploy-installerx64.cmd     (複製文件到 ..\Installer\)
│   ├── deploy-installer.cmd        (複製文件到當前目錄)
│   ├── DIME-x64OnlyCleaned.nsi     (從 ..\Installer\ 讀取)
│   └── DIME-x86armUniversal.nsi    (從當前目錄讀取)
├── Installer/                       (由 deploy-installerx64.cmd 創建)
│   ├── system32.x64/
│   │   └── DIME.dll
│   └── DIMESettings.exe
└── Tables/
    ├── array30_DIME_A.cin
    ├── array30_DIME_B.cin
    └── ... (其他 .cin 文件)
```

### 修正後（一致）

```
DIME/
├── installer/
│   ├── deploy-installerx64.cmd     (複製文件到當前目錄)
│   ├── deploy-installer.cmd        (複製文件到當前目錄)
│   ├── DIME-x64OnlyCleaned.nsi     (從當前目錄讀取)
│   ├── DIME-x86armUniversal.nsi    (從當前目錄讀取)
│   ├── system32.x64/                (運行 .cmd 後創建)
│   │   └── DIME.dll
│   ├── DIMESettings.exe             (運行 .cmd 後複製)
│   ├── array30_DIME_A.cin           (運行 .cmd 後複製)
│   ├── array30_DIME_B.cin           (運行 .cmd 後複製)
│   └── ... (其他 .cin 文件)
└── Tables/
    ├── array30_DIME_A.cin           (原始文件)
    ├── array30_DIME_B.cin           (原始文件)
    └── ... (其他 .cin 文件)
```

---

## 安裝後檔案位置

當使用者安裝 DIME 後，文件會被放置在以下位置：

```
C:\Windows\System32\
└── DIME.dll                         (主要 IME DLL)

C:\Program Files\DIME\
├── DIMESettings.exe                 (設定程式)
├── uninst.exe                       (解除安裝程式)
├── array30_DIME_A.cin               (陣列輸入法字根表)
├── array30_DIME_B.cin
├── array30_DIME_phrase.cin
├── phonetic_DIME.cin                (注音輸入法字根表)
├── dayi_DIME.cin                    (大易輸入法字根表)
└── ... (其他 .cin 文件)

C:\ProgramData\Microsoft\Windows\Start Menu\Programs\DIME\
├── DIME設定.lnk
└── Uninstall.lnk
```

---

## Tables 目錄的 .cin 文件清單

根據 Tables/ 目錄的內容，將會複製以下 .cin 文件到安裝程序：

```
array30-OpenVanilla-big-v2023-1.0-20230211.cin
array30_OpenVanilla-big-0.94.cin
array30_DIME_0.8-A.cin
array30_DIME_0.8-B.cin
array30_DIME_0.8-CD.cin
array30_DIME_0.8-E.cin
array30_DIME_0.8-EF.cin
array30_DIME_0.9-A.cin
array30_DIME_0.9-B.cin
array30_DIME_0.9-CD.cin
array30_DIME_0.9-EFG.cin
array30_DIME_A.cin
array30_DIME_B.cin
array30_DIME_CD.cin
array30_DIME_EFG.cin
array30_DIME_phrase.cin
array_special_DIME_0.75.cin
... (其他 .cin 文件)
```

**總計**：約 50+ 個 .cin 文件，總大小約 7.5 MB

---

## 測試步驟

### 1. 清理舊文件

```batch
cd D:\Github\DIME\installer
del /Q *.cin 2>nul
del /Q DIMESettings.exe 2>nul
rd /S /Q system32.x64 2>nul
```

### 2. 運行部署腳本

```batch
cd D:\Github\DIME\installer
deploy-installerx64.cmd
```

### 3. 檢查複製結果

```batch
dir *.cin
dir system32.x64\DIME.dll
dir DIMESettings.exe
```

**預期輸出**：
- 應該看到 50+ 個 .cin 文件
- system32.x64\DIME.dll 應該存在
- DIMESettings.exe 應該存在

### 4. 安裝測試

```batch
DIME-x64Installer.exe
```

### 5. 驗證安裝

```powershell
cd D:\Github\DIME\installer
powershell -ExecutionPolicy Bypass -File check_install.ps1
```

**預期輸出**：
```
=== Checking DIME Installation ===

1. Checking Registry...
   [OK] Registry entry found

2. Checking System DLL...
   [OK] DIME.dll found at: C:\Windows\System32\DIME.dll

3. Checking Program Files...
   [OK] Install directory found at: C:\Program Files\DIME

   Checking IME Tables (.cin files)...
   [OK] Found 50 .cin file(s)

4. Checking Start Menu...
   [OK] Start Menu folder found

=== Check Complete ===
```

---

## 常見問題

### Q1: 為什麼需要複製 .cin 文件？

**A**: .cin 文件包含輸入法的字根表和詞庫。沒有這些文件，輸入法無法進行中文輸入轉換。

### Q2: 為什麼 deploy-installerx64.cmd 與 deploy-installer.cmd 使用不同的目錄結構？

**A**: 這是歷史遺留問題。原本 deploy-installerx64.cmd 使用 `..\Installer\` 目錄，但這與通用版本不一致，且 NSIS 腳本預設從當前目錄讀取文件。現在已統一使用當前目錄（installer/）。

### Q3: 如果我添加了新的 .cin 文件到 Tables/ 目錄，需要修改腳本嗎？

**A**: 不需要。腳本使用 `copy ..\Tables\*.cin .` 和 `File "*.cin"` 萬用字元模式，會自動包含所有 .cin 文件。

### Q4: 為什麼 check_install.ps1 要專門檢查 .cin 文件？

**A**: 因為 .cin 文件是輸入法的核心組件，缺少它們會導致輸入法完全無法使用。專門檢查可以快速發現安裝問題。

### Q5: 解除安裝時會刪除 .cin 文件嗎？

**A**: 會。DIME-x64OnlyCleaned.nsi 第 241 行的 `Delete "$INSTDIR\*.cin"` 會刪除所有 .cin 文件。

---

## 相關文件

- **deploy-installerx64.cmd** - x64 專用部署腳本
- **deploy-installer.cmd** - 通用部署腳本（x86/x64/ARM64）
- **DIME-x64OnlyCleaned.nsi** - x64 專用 NSIS 安裝腳本
- **DIME-x86armUniversal.nsi** - 通用 NSIS 安裝腳本
- **check_install.ps1** - 安裝驗證 PowerShell 腳本

---

## 版本歷史

| 日期 | 版本 | 變更內容 | 作者 |
|------|------|----------|------|
| 2026-01-15 | 1.0 | 修正 deploy-installerx64.cmd 缺少 .cin 複製的問題 | Claude Code |
| 2026-01-15 | 1.0 | 統一目錄結構與通用版本一致 | Claude Code |
| 2026-01-15 | 1.0 | 添加 check_install.ps1 的 .cin 驗證 | Claude Code |

---

*此文檔由 Claude Code 自動生成於 2026-01-15*
