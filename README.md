# DIME 輸入法

DIME 是一個適用於 Windows 7/8/10/11 的中文輸入法編輯器（IME），基於 Text Services Framework (TSF) 實作。

本專案 fork 自 [jrywu/DIME](https://github.com/jrywu/DIME)，僅供個人使用。

## 支援的輸入法

- 行列 30/40
- 注音（ㄅㄆㄇㄈ）
- 大易
- 其他通用輸入法

## 建置方式

使用 Visual Studio 2025 編譯：

```bash
# 建置 x64 Release 版本
msbuild DIME.sln /p:Configuration=Release /p:Platform=x64

```

## 安裝

```bash
# 建立 x64 安裝程式
cd installer
deploy-installerx64.cmd

```

## 系統需求

- Windows 7/8/10/11
- 支援平台：x64

## 授權

請參考原專案授權條款。
