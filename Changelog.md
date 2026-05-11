# **Changelog**

All notable changes to **MatchBoxCS** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),

and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## **\[1.0.5\] \- 2026-05-11**

### **Changed**

* Renamed the application from "Matchbox C\#" to "MatchBoxCS" across the entire script, UI components, namespaces, publish directories, and configuration folders.

## **\[1.0.4\] \- 2026-05-11**

### **Fixed**

* Fixed an encoding issue where emojis caused display anomalies (Mojibake) on Windows systems where PowerShell interprets .ps1 files with legacy ANSI/Windows-1252 encodings. Removed all emojis from the C\# UI controls to maintain a clean, professional aesthetic regardless of script encoding. Replaced console log emojis with robust tag indicators (e.g., \[OK\], \[ERR\], \[INFO\]).

## **\[1.0.3\] \- 2026-05-11**

### **Fixed**

* Fixed an Add-Type exception (The type name 'MatchboxCSharp.MainForm' already exists) that occurs when running the script multiple times within the same persistent PowerShell session. Added a type-existence check to bypass compilation if the Matchbox engine is already loaded in memory.

## **\[1.0.2\] \- 2026-05-11**

### **Fixed**

* Fixed an initialization crash in PowerShell (SetCompatibleTextRenderingDefault must be called before the first IWin32Window object is created in the application). When executing within a persistent PowerShell session or IDE, prior handles could cause .SetCompatibleTextRenderingDefault(false) to throw exceptions. Visual style initializations are now cleanly wrapped in try/catch to ignore AppDomain collisions.

## **\[1.0.1\] \- 2026-05-11**

### **Fixed**

* Fixed an Add-Type compilation error (Cannot await in the body of a catch clause) that occurred on Windows machines running legacy PowerShell 5.1 / C\# 5.0 compilers. Refactored BootstrapEnvironment() to use a boolean evaluation flag outside of the catch block to handle missing .NET SDK scenarios cleanly.

### **Added**

* Added README.md containing project documentation, features, and startup instructions.  
* Added CHANGELOG.md to track version history.  
* Added version tracking to the matchbox.ps1 script notes and the UI Window Title.

## **\[1.0.0\] \- Initial MVP Release**

### **Added**

* Single-file PowerShell script architecture (matchbox.ps1).  
* Embedded, dynamically compiled WinForms C\# GUI.  
* "Initialize C\# Environment" one-click Winget bootstrapper for .NET SDK.  
* Project Control Center (Create, load, and browse C\# projects).  
* Rapid Prototyping Engine (Build, Run, Clean).  
* Advanced Deployment Engine (Exposing all dotnet publish flags visually).  
* Preset build configurations (Dev Mode, Portable EXE, Smallest Size, Fast Startup, Enterprise ULTRA).  
* Persistent UI settings engine saving to %APPDATA%\\MatchBoxCS\\config.txt.