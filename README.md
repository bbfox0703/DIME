# DIME 輸入法 (Custom Fork)

[![License](https://img.shields.io/badge/License-BSD_3--Clause-blue.svg)](LICENSE.md)
[![Windows](https://img.shields.io/badge/Windows-8%20%7C%2010%20%7C%2011-blue)](https://github.com/bbfox0703/DIME)

基於 [jrywu/DIME](https://github.com/jrywu/DIME) 的自訂分支，基本上就是我選字時不想按 Shift 鍵的修正。

## 與上游的差異

- **直接數字鍵選字**：候選字視窗中直接按數字鍵即可選字，**不需搭配 Shift 鍵**
- **移除 Shift 切換英文模式**：避免與直接數字鍵選字衝突
- **多螢幕 DPI 修正**：修正候選字視窗與提示視窗在不同 DPI 螢幕間移動時的顯示問題
- **聯想字詞修正**：修正聯想字詞視窗在特定應用程式（如 Notepad++）中跳位的問題
- **候選字視窗渲染修正**：修正 GDI 雙緩衝繪製導致視窗全黑的問題
- **自訂版本標記**：版本號自動加上 `custom` 後綴以區別上游版本

## 安裝

### 下載

   <!-- RELEASE_DOWNLOAD_START -->
   **最新穩定發行版本 DIME v.1.3.610（更新日期: 2026-04-07）**
   <!-- RELEASE_DOWNLOAD_END -->

   [DIME-Universal.zip](https://github.com/bbfox0703/DIME/releases/latest/download/DIME-Universal.zip)
   （單一安裝檔支援 x86/x64/ARM64，安裝程式自動偵測平台）

   | 檔案 | 支援平台 |
   |------|----------|
   | [DIME-64bit.msi](https://github.com/bbfox0703/DIME/releases/latest/download/DIME-64bit.msi) | Windows x64/ARM64 (64位元) |
   | [DIME-32bit.msi](https://github.com/bbfox0703/DIME/releases/latest/download/DIME-32bit.msi) | Windows x86（32位元） |

   ---
   <!-- DOWNLOAD_START -->     
     <details>
     <summary><b>最新開發版本 DIME v1.3.688 (更新日期: 2026-04-10)</b></summary>
   <!-- DOWNLOAD_END -->
       
   [DIME-Universal.zip](https://github.com/bbfox0703/DIME/raw/refs/heads/master/installer/DIME-Universal.zip)

   | 檔案 | 支援平台 |
   |------|----------|
   | [DIME-64bit.msi](https://github.com/bbfox0703/DIME/raw/refs/heads/master/installer/DIME-64bit.msi) | Windows x64/ARM64 (64位元) |
   | [DIME-32bit.msi](https://github.com/bbfox0703/DIME/raw/refs/heads/master/installer/DIME-32bit.msi) | Windows x86（32位元） |

   </details>

### 驗證檔案完整性

   **最新穩定發行版本 SHA-256 CHECKSUM:**
   <!-- RELEASE_CHECKSUM_START -->    
    | 檔案 | SHA-256 CHECKSUM |
    |------|----------------|
    | DIME-Universal.exe | `C8550646B1DA860E88E8297CDD737B900663FFEE689870808F87354C3AFEE8D0` |
    | DIME-Universal.zip | `B6FE18BCFC32984D3964D99CAD4F14A60CA4D399B070E9446DAF56E7A5D8AC9C` |
    | DIME-64bit.msi | `4DA89896746DF4C645D329936074E4FB0F644D2199A2F523C124F8BAB347BBA9` |
    | DIME-32bit.msi | `256AF8429A76AB934B31B751066D420780C3CED275B93BE35DA0C4A5EEA39BE9` |
   <!-- RELEASE_CHECKSUM_END -->   

   <!-- CHECKSUM_START -->
     <details>     
     <summary><b>最新開發版本 DIME v1.3.688 SHA-256 CHECKSUM (更新日期: 2026-04-10)</b></summary>
   
    | 檔案 | SHA-256 CHECKSUM |
    |------|----------------|
    | DIME-Universal.exe | `D5A051748D2B49EC2F6469899DD48898B68BD100CABF6AA0C415F27912FB39A3` |
    | DIME-Universal.zip | `9012762CC9FF809CCCE4983BA7162D153685C87F31E53EF187BA1B32099BE2DE` |
    | DIME-64bit.msi | `420F633B83235FF900D6669274A81A413180D781A2A37F2961DD8CB585280849` |
    | DIME-32bit.msi | `07D34668D14A9BB297384755A52B498A82D73E112EBACFB70DEF84A6A26F68C2` |
   <!-- CHECKSUM_END -->
     </details>

   ```powershell
   Get-FileHash DIME-Universal.exe -Algorithm SHA256
   Get-FileHash DIME-64bit.msi -Algorithm SHA256
   ```

### 安裝步驟

1. 下載並解壓縮 `DIME-Universal.zip`
2. 執行 `DIME-Universal.exe`，安裝後自動新增四種輸入法：DIME大易、DIME行列、DIME傳統注音、DIME自建
3. 不需要的輸入法可在「設定」→「時間與語言」→「語言」→「中文(台灣)」→「選項」中移除

### 移除

在「設定」→「應用程式」→「已安裝的應用程式」中搜尋 DIME 並移除。

## 上游專案

本專案 fork 自 [jrywu/DIME](https://github.com/jrywu/DIME)，完整功能說明請參閱上游 README。

## 授權

[BSD 3-Clause License](LICENSE.md)
