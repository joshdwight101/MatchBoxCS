# **MatchBoxCS**

**Ignite any C\# project instantly — from zero to production.**

**Current Version:** v1.0.5

MatchBoxCS is a standalone, enterprise-grade .NET launch engine packed entirely into a **single PowerShell script**. Featuring a dynamically compiled embedded WinForms GUI, MatchBoxCS lets you instantly bootstrap the .NET SDK, rapidly prototype, and deploy highly optimized executables (Single-File, Trimmed, ReadyToRun) with zero command-line guesswork.

## **✨ Features**

* **📦 100% Portable:** The entire application is contained in a single matchbox.ps1 file.  
* **⚡ Visual UI:** Dynamic C\# UI that completely eliminates the need for CLI commands.  
* **🚀 Advanced Publish Engine:** Exposes the most complex dotnet publish flags visually, letting you compile Self-Contained, Trimmed, and AOT-optimized executables with one click.  
* **🛠️ Self-Healing:** Automatically bootstraps the .NET SDK via Winget if it is missing from the host machine.  
* **🏗️ Rapid Prototyping:** Create new projects (Console, WebAPI, WinForms, WPF), build, run, and clean instantly.

## **🚀 Quick Start**

1. Download matchbox.ps1.  
2. Right-click the file and select **Run with PowerShell** (or launch from a terminal: .\\matchbox.ps1).  
3. *If you don't have the .NET SDK installed*, click **Initialize C\# Environment** in the top right to download it.  
4. Use the **Project Control Center** to browse to an existing .csproj or create a new one.  
5. Hit **Run** to test, or head to the **Advanced Deployment Engine** to generate a single-file .exe.

## **⚙️ Advanced Publish Modes**

MatchBoxCS abstracts complex .NET command-line interfaces into simple dropdowns.

Available Presets:

* **Dev Mode:** Fast framework-dependent build.  
* **Portable EXE:** Self-Contained \+ Single File executable that runs anywhere.  
* **Smallest Size:** Trims unused assemblies to dramatically shrink executable size.  
* **Fast Startup:** Applies ReadyToRun (AOT) for immediate execution speeds.  
* **Enterprise ULTRA:** Single File \+ Trimmed \+ ReadyToRun \+ Compressed (The ultimate deployment config).

## **💻 Requirements**

* Windows 10/11  
* PowerShell 5.1 or newer (ISE, Command Prompt, VS Code Terminal, or Windows Terminal)  
* (Optional) .NET SDK \- *MatchBoxCS will install this for you if missing.*

## **📜 License**

GPL-3.0 License. Created by Joshua Dwight.