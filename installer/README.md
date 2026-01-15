# DIME 安裝程序建置指南

## 概述

本目錄包含 DIME 輸入法的安裝程序建置腳本和驗證工具。

## 文件說明

| 文件 | 用途 |
|------|------|
| `deploy-installerx64.cmd` | x64 專用部署腳本 - 建置 x64 安裝程序 |
| `deploy-installer.cmd` | 通用部署腳本 - 建置 x86/x64/ARM64 通用安裝程序 |
| `DIME-x64OnlyCleaned.nsi` | NSIS 腳本 - x64 安裝程序配置 |
| `DIME-x86armUniversal.nsi` | NSIS 腳本 - 通用安裝程序配置 |
| `check_install.ps1` | 安裝驗證腳本 - 檢查 DIME 是否正確安裝 |
| `test_deployment.ps1` | 部署測試腳本 - 驗證建置腳本配置 |
| `INSTALLER_FIX_SUMMARY.md` | 修正摘要 - IME tables 安裝問題的修正記錄 |

## 建置安裝程序

### 前置條件

1. **編譯 DIME**
   ```batch
   cd D:\Github\DIME
   "C:\Program Files\Microsoft Visual Studio\18\Insiders\MSBuild\Current\Bin\amd64\MSBuild.exe" DIME.sln /p:Configuration=Release /p:Platform=x64
   ```

2. **安裝 NSIS**
   - 下載並安裝 [NSIS](https://nsis.sourceforge.io/)
   - 預設安裝路徑：`C:\Program Files (x86)\NSIS\`

### x64 專用安裝程序

```batch
cd D:\Github\DIME\installer
deploy-installerx64.cmd
```

**輸出**：`DIME-x64Installer.exe`

**包含內容**：
- x64 DIME.dll
- DIMESettings.exe
- 23 個 .cin 字根表文件（約 7.22 MB）

### 通用安裝程序（x86/x64/ARM64）

```batch
cd D:\Github\DIME\installer

REM 先編譯所有平台
"C:\Program Files\Microsoft Visual Studio\18\Insiders\MSBuild\Current\Bin\amd64\MSBuild.exe" ..\DIME.sln /p:Configuration=Release /p:Platform=Win32
"C:\Program Files\Microsoft Visual Studio\18\Insiders\MSBuild\Current\Bin\amd64\MSBuild.exe" ..\DIME.sln /p:Configuration=Release /p:Platform=x64
"C:\Program Files\Microsoft Visual Studio\18\Insiders\MSBuild\Current\Bin\amd64\MSBuild.exe" ..\DIME.sln /p:Configuration=Release /p:Platform=ARM64

REM 建置通用安裝程序
deploy-installer.cmd
```

**輸出**：`DIME-Installer.exe`

**包含內容**：
- x86 DIME.dll
- x64 DIME.dll
- ARM64 DIME.dll
- DIMESettings.exe
- 23 個 .cin 字根表文件（約 7.22 MB）

## 驗證建置

### 建置前驗證

在運行 `deploy-installerx64.cmd` 之前，可以運行測試腳本驗證配置：

```powershell
cd D:\Github\DIME\installer
powershell -ExecutionPolicy Bypass -File test_deployment.ps1
```

**預期輸出**：
```
=== Testing Deployment Script ===

1. Checking Tables directory...
   [OK] Found 23 .cin file(s) in Tables/

2. Checking current directory before deployment...
   [OK] No .cin files present (clean state)

3. Checking deploy-installerx64.cmd...
   [OK] Script contains correct .cin copy command

4. Checking DIME-x64OnlyCleaned.nsi...
   [OK] NSIS script contains correct .cin file instruction

5. Checking check_install.ps1...
   [OK] Verification script includes .cin check

6. Simulating copy operation...
   Would copy the following files:
   - array-shortcode-20161018.cin (72.6 KB)
   - ... and 18 more files
   Total size: 7.22 MB

=== Pre-Deployment Test Complete ===
```

### 建置後驗證

運行 `deploy-installerx64.cmd` 後，檢查文件：

```batch
cd D:\Github\DIME\installer
dir *.cin
dir system32.x64\DIME.dll
dir DIMESettings.exe
dir DIME-x64Installer.exe
```

**預期結果**：
- 23 個 .cin 文件
- system32.x64\DIME.dll 存在
- DIMESettings.exe 存在
- DIME-x64Installer.exe 存在（安裝程序）

### 安裝後驗證

安裝 DIME 後，運行驗證腳本：

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
   [OK] Found 23 .cin file(s)

4. Checking Start Menu...
   [OK] Start Menu folder found

=== Check Complete ===
```

## 常見問題

### Q: 為什麼需要 .cin 文件？

**A**: .cin 文件是輸入法的字根表和詞庫。沒有這些文件，輸入法無法進行中文輸入。

### Q: 安裝程序會安裝哪些文件？

**A**:
- `C:\Windows\System32\DIME.dll` - 主要 IME DLL
- `C:\Program Files\DIME\*.cin` - 字根表文件（23 個）
- `C:\Program Files\DIME\DIMESettings.exe` - 設定程式
- `C:\Program Files\DIME\uninst.exe` - 解除安裝程式
- 開始功能表快捷方式

### Q: 如何清理建置文件？

**A**:
```batch
cd D:\Github\DIME\installer
del /Q *.cin 2>nul
del /Q DIMESettings.exe 2>nul
del /Q DIME-x64Installer.exe 2>nul
rd /S /Q system32.x64 2>nul
rd /S /Q system32.x86 2>nul
rd /S /Q system32.arm64 2>nul
```

### Q: 為什麼有兩個部署腳本？

**A**:
- `deploy-installerx64.cmd` - 僅建置 x64 版本，適合快速測試
- `deploy-installer.cmd` - 建置完整的通用版本（x86/x64/ARM64），適合正式發布

### Q: NSIS 找不到怎麼辦？

**A**:
1. 確認 NSIS 已安裝
2. 檢查 NSIS 安裝路徑
3. 修改 .cmd 腳本中的 NSIS 路徑：
   ```batch
   REM 預設路徑（x86 系統）
   "c:\Program Files (x86)\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi

   REM 或

   REM x64 系統路徑
   "c:\Program Files\NSIS\makensis.exe" DIME-x64OnlyCleaned.nsi
   ```

## 目錄結構

### 建置前

```
installer/
├── deploy-installerx64.cmd
├── deploy-installer.cmd
├── DIME-x64OnlyCleaned.nsi
├── DIME-x86armUniversal.nsi
├── check_install.ps1
├── test_deployment.ps1
├── INSTALLER_FIX_SUMMARY.md
└── README.md
```

### 建置後

```
installer/
├── deploy-installerx64.cmd
├── deploy-installer.cmd
├── DIME-x64OnlyCleaned.nsi
├── DIME-x86armUniversal.nsi
├── check_install.ps1
├── test_deployment.ps1
├── INSTALLER_FIX_SUMMARY.md
├── README.md
├── system32.x64/
│   └── DIME.dll                     (從 ..\Release\x64\ 複製)
├── DIMESettings.exe                 (從 ..\Release\ 複製)
├── array-shortcode-20161018.cin     (從 ..\Tables\ 複製)
├── array30_DIME_A.cin               (從 ..\Tables\ 複製)
├── ... (其他 21 個 .cin 文件)
└── DIME-x64Installer.exe            (建置輸出)
```

## 技術細節

### 部署流程

1. **準備階段**
   - 創建 system32.x64 目錄
   - 複製編譯好的 DIME.dll
   - 複製 DIMESettings.exe
   - 複製所有 .cin 字根表文件

2. **打包階段**
   - NSIS 讀取 .nsi 配置文件
   - 將所有文件打包成安裝程序
   - 生成 DIME-x64Installer.exe

3. **安裝階段**
   - 檢查並安裝 VC++ Redistributable
   - 註冊 DIME.dll 到 System32
   - 設定 AppContainer 權限（UWP 支援）
   - 複製 .cin 文件到 Program Files\DIME
   - 創建開始功能表快捷方式
   - 寫入登錄表

### NSIS 配置重點

```nsis
Section "MainSection" SEC01
  SetOutPath "$SYSDIR"
  File "system32.x64\DIME.dll"
  ExecWait '"$SYSDIR\regsvr32.exe" /s $SYSDIR\DIME.dll'

  CreateDirectory "$INSTDIR"
  SetOutPath "$INSTDIR"
  File "*.cin"                    ; 重要：包含所有 .cin 文件
  File "DIMESettings.exe"
SectionEnd
```

### 解除安裝

```nsis
Section Uninstall
  ExecWait '"$SYSDIR\regsvr32.exe" /u /s $SYSDIR\DIME.dll'
  Delete "$SYSDIR\DIME.dll"
  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.cin"         ; 重要：刪除所有 .cin 文件
  RMDir /r "$INSTDIR"
SectionEnd
```

## 修改歷史

詳細的修改記錄請參閱 [INSTALLER_FIX_SUMMARY.md](INSTALLER_FIX_SUMMARY.md)。

### 最近更新（2026-01-15）

- ✅ 修正 deploy-installerx64.cmd 缺少 .cin 複製的問題
- ✅ 統一目錄結構與通用版本一致
- ✅ 添加 check_install.ps1 的 .cin 驗證
- ✅ 添加 test_deployment.ps1 預先驗證工具
- ✅ 創建詳細的安裝程序建置文檔

## 支援

如有問題，請檢查：
1. [INSTALLER_FIX_SUMMARY.md](INSTALLER_FIX_SUMMARY.md) - 常見問題和修正記錄
2. [GitHub Issues](https://github.com/jrywu/DIME/issues) - 提交問題或查看已知問題
3. 運行 `test_deployment.ps1` 和 `check_install.ps1` 進行診斷

---

*文檔由 Claude Code 生成於 2026-01-15*
