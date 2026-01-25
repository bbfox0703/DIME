# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DIME 是一個適用於 Windows 7/8/10/11 的中文輸入法編輯器（IME），基於 Text Services Framework (TSF) 實作。Fork 自 jrywu/DIME。

**支援的輸入法**: 行列 30/40、注音、大易、其他通用輸入法

**平台**: x64 (主要), Win32, ARM64, ARM64EC

## Build Commands

```batch
# 產生版本資訊（編譯前執行）
buildInfo.cmd

# 建置 x64 Release
msbuild DIME.sln /p:Configuration=Release /p:Platform=x64

# 建置所有平台
msbuild DIME.sln /p:Configuration=Release /p:Platform=Win32
msbuild DIME.sln /p:Configuration=Release /p:Platform=x64
msbuild DIME.sln /p:Configuration=Release /p:Platform=ARM64
```

## Installer

需要先安裝 NSIS (https://nsis.sourceforge.io/)

```batch
# x64 安裝程式
cd installer
deploy-installerx64.cmd

# 通用安裝程式 (x86/x64/ARM64)
deploy-installer.cmd
```

**驗證腳本**:
- `installer/test_deployment.ps1` - 建置前驗證
- `installer/check_install.ps1` - 安裝後驗證

## Architecture

### TSF 核心架構

DIME 實作完整的 TSF Text Input Processor，支援雙模式架構：
- **UI-less 模式**: DirectX 12 應用自行渲染候選視窗
- **GDI 模式**: IME 使用 CCandidateWindow 顯示候選視窗

**主要類別**:
- `CDIME` (DIME.cpp) - 主 IME 類別，實作 ITfTextInputProcessorEx 等 TSF 介面
- `CCompositionProcessorEngine` - 輸入組字邏輯
- `CUIPresenter` - UI 元素管理，處理 UI-less/GDI 模式切換
- `CCandidateWindow` - GDI 候選視窗渲染
- `CTableDictionaryEngine` - .cin 字根表載入與查詢

### 輸入處理流程

1. `CKeyEventSink` 接收鍵盤事件
2. `KeyProcesser.cpp` 分類按鍵類型
3. `CKeyHandlerEditSession` 處理按鍵
4. `CCompositionProcessorEngine` 查詢字根表產生候選字
5. `CUIPresenter` 顯示候選視窗或透過 TSF UI-less 介面提供資料

### 字根表 (.cin)

位於 `Tables/` 目錄，共 23 個 .cin 檔案，包含行列、注音、大易等輸入法字根表。執行時期載入，無需重新編譯即可更新。

## Key Files

| 檔案 | 說明 |
|------|------|
| `DIME.cpp`, `DIME.h` | 主 IME 類別，TSF 介面實作 |
| `KeyEventSink.cpp` | 鍵盤事件處理 |
| `KeyHandlerEditSession.h` | 按鍵處理實作 |
| `CompositionProcessorEngine.cpp` | 組字引擎 |
| `UIPresenter.cpp` | UI 元素管理 (UI-less/GDI 模式) |
| `CandidateWindow.cpp` | GDI 候選視窗 |
| `TableDictionaryEngine.cpp` | 字根表引擎 |
| `Config.cpp` | 設定管理 |
| `Register.cpp` | TSF 類別註冊 |
| `Define.h` | 常數定義 (顏色、尺寸、字型) |

## Solution Structure

- `DIME.vcxproj` - 主 IME DLL
- `DIMESettings/DIMESettings.vcxproj` - 設定程式 GUI

## TSF 能力註冊

在 `Register.cpp` 中註冊的重要能力：
- `GUID_TFCAT_TIPCAP_UILESSMODE` - UI-less 模式支援 (DirectX 12)
- `GUID_TFCAT_TIPCAP_IMMERSIVESUPPORT` - UWP/Store 應用支援
- `GUID_TFCAT_TIPCAP_UIELEMENTENABLED` - UI 元素支援

## 安裝位置

- DLL: `C:\Windows\System32\DIME.dll`
- 設定程式: `C:\Program Files\DIME\DIMESettings.exe`
- 字根表: `C:\Program Files\DIME\*.cin`
