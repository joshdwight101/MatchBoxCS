<#
.SYNOPSIS
    MatchBoxCS by Joshua Dwight
    "Ignite any C# project instantly — from zero to production."
.DESCRIPTION
    A single PowerShell script that bootstraps a full C# environment,
    provides a rich C# GUI, and offers complete control over ALL .NET build 
    and publish modes. No external tools needed beyond the .NET SDK (which it can bootstrap).
.NOTES
    Version: 1.0.5
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$matchboxCode = @'
using System;
using System.Drawing;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;

namespace MatchBoxCS
{
    public class MainForm : Form
    {
        // UI Colors
        private Color bgColor = Color.FromArgb(30, 30, 30);
        private Color panelColor = Color.FromArgb(37, 37, 38);
        private Color textColor = Color.FromArgb(212, 212, 212);
        private Color accentColor = Color.FromArgb(14, 99, 156);
        private Color successColor = Color.FromArgb(78, 201, 176);
        private Color warnColor = Color.FromArgb(206, 145, 120);
        private Color errorColor = Color.FromArgb(244, 71, 71);

        // UI Controls
        private TextBox txtProjectPath;
        private ComboBox cmbTemplates;
        private TextBox txtNewProjectName;
        private ComboBox cmbPresets;
        private ComboBox cmbRuntimes;
        
        // Advanced Flags
        private CheckBox chkSelfContained;
        private CheckBox chkSingleFile;
        private CheckBox chkTrimmed;
        private CheckBox chkReadyToRun;
        private CheckBox chkCompress;
        private CheckBox chkNativeLibs;

        private RichTextBox rtbConsole;

        // Configuration
        private string configDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "MatchBoxCS");
        private string configFile;

        public MainForm()
        {
            configFile = Path.Combine(configDir, "config.txt");
            InitializeComponents();
            LoadConfig();
        }

        private void InitializeComponents()
        {
            this.Text = "MatchBoxCS Engine v1.0.5 - by Joshua Dwight";
            this.Size = new Size(1100, 750);
            this.BackColor = bgColor;
            this.ForeColor = textColor;
            this.Font = new Font("Segoe UI", 9.5f);
            this.StartPosition = FormStartPosition.CenterScreen;

            // --- HEADER ---
            Panel pnlHeader = new Panel();
            pnlHeader.BackColor = Color.FromArgb(0, 122, 204);
            pnlHeader.Height = 50;
            pnlHeader.Dock = DockStyle.Top;
            this.Controls.Add(pnlHeader);

            Label lblTitle = new Label();
            lblTitle.Text = "MATCHBOXCS";
            lblTitle.Font = new Font("Segoe UI", 14, FontStyle.Bold);
            lblTitle.ForeColor = Color.White;
            lblTitle.AutoSize = true;
            lblTitle.Location = new Point(15, 12);
            pnlHeader.Controls.Add(lblTitle);

            Button btnBootstrap = CreateButton("Initialize C# Environment", 220, 30);
            btnBootstrap.Location = new Point(this.Width - 260, 10);
            btnBootstrap.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            btnBootstrap.BackColor = Color.FromArgb(40, 40, 40);
            btnBootstrap.Click += async delegate { await BootstrapEnvironment(); };
            pnlHeader.Controls.Add(btnBootstrap);

            // --- PROJECT PANEL (LEFT) ---
            Panel pnlProject = new Panel();
            pnlProject.BackColor = panelColor;
            pnlProject.Location = new Point(15, 65);
            pnlProject.Size = new Size(350, 400);
            this.Controls.Add(pnlProject);

            Label lblProjTitle = new Label() { Text = "PROJECT CONTROL CENTER", Font = new Font("Segoe UI", 10, FontStyle.Bold), AutoSize = true, Location = new Point(15, 15) };
            pnlProject.Controls.Add(lblProjTitle);

            Label lblPath = new Label() { Text = "Project Directory:", AutoSize = true, Location = new Point(15, 50) };
            pnlProject.Controls.Add(lblPath);

            txtProjectPath = new TextBox() { Location = new Point(15, 75), Width = 240, BackColor = bgColor, ForeColor = textColor, BorderStyle = BorderStyle.FixedSingle };
            pnlProject.Controls.Add(txtProjectPath);

            Button btnBrowse = CreateButton("Browse", 70, 25);
            btnBrowse.Location = new Point(265, 74);
            btnBrowse.Click += BtnBrowse_Click;
            pnlProject.Controls.Add(btnBrowse);

            Label lblNewProj = new Label() { Text = "Create New Project:", AutoSize = true, Location = new Point(15, 120) };
            pnlProject.Controls.Add(lblNewProj);

            cmbTemplates = new ComboBox() { Location = new Point(15, 145), Width = 150, DropDownStyle = ComboBoxStyle.DropDownList, BackColor = bgColor, ForeColor = textColor };
            cmbTemplates.Items.AddRange(new object[] { "console", "webapi", "winforms", "wpf", "worker", "classlib" });
            cmbTemplates.SelectedIndex = 0;
            pnlProject.Controls.Add(cmbTemplates);

            txtNewProjectName = new TextBox() { Location = new Point(175, 145), Width = 160, BackColor = bgColor, ForeColor = textColor, Text = "MyNewApp" };
            pnlProject.Controls.Add(txtNewProjectName);

            Button btnCreate = CreateButton("Create & Load Project", 320, 35);
            btnCreate.Location = new Point(15, 180);
            btnCreate.BackColor = Color.FromArgb(70, 70, 70);
            btnCreate.Click += async delegate { await CreateProject(); };
            pnlProject.Controls.Add(btnCreate);

            // --- RAPID PROTOTYPING PANEL (MIDDLE) ---
            Panel pnlProto = new Panel();
            pnlProto.BackColor = panelColor;
            pnlProto.Location = new Point(380, 65);
            pnlProto.Size = new Size(250, 400);
            this.Controls.Add(pnlProto);

            Label lblProtoTitle = new Label() { Text = "RAPID PROTOTYPING", Font = new Font("Segoe UI", 10, FontStyle.Bold), AutoSize = true, Location = new Point(15, 15) };
            pnlProto.Controls.Add(lblProtoTitle);

            Button btnBuild = CreateButton("Build", 220, 45);
            btnBuild.Location = new Point(15, 50);
            btnBuild.Click += async delegate { await RunDotNetAsync("build"); };
            pnlProto.Controls.Add(btnBuild);

            Button btnRun = CreateButton("Run (Hot Rebuild)", 220, 45);
            btnRun.Location = new Point(15, 105);
            btnRun.BackColor = Color.FromArgb(19, 104, 46);
            btnRun.Click += async delegate { await RunDotNetAsync("run"); };
            pnlProto.Controls.Add(btnRun);

            Button btnClean = CreateButton("Clean", 220, 45);
            btnClean.Location = new Point(15, 160);
            btnClean.BackColor = Color.FromArgb(120, 50, 50);
            btnClean.Click += async delegate { await RunDotNetAsync("clean"); };
            pnlProto.Controls.Add(btnClean);

            // --- ADVANCED PUBLISH ENGINE (RIGHT) ---
            Panel pnlPublish = new Panel();
            pnlPublish.BackColor = panelColor;
            pnlPublish.Location = new Point(645, 65);
            pnlPublish.Size = new Size(420, 400);
            pnlPublish.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            this.Controls.Add(pnlPublish);

            Label lblPubTitle = new Label() { Text = "ADVANCED DEPLOYMENT ENGINE", Font = new Font("Segoe UI", 10, FontStyle.Bold), AutoSize = true, Location = new Point(15, 15) };
            pnlPublish.Controls.Add(lblPubTitle);

            Label lblPreset = new Label() { Text = "Build Presets:", AutoSize = true, Location = new Point(15, 50) };
            pnlPublish.Controls.Add(lblPreset);

            cmbPresets = new ComboBox() { Location = new Point(15, 75), Width = 385, DropDownStyle = ComboBoxStyle.DropDownList, BackColor = bgColor, ForeColor = textColor };
            cmbPresets.Items.AddRange(new object[] { 
                "Custom (Advanced Mode)", 
                "Dev Mode (Framework Dependent)", 
                "Portable EXE (Self-Contained + Single File)", 
                "Smallest Size (Single File + Trimmed)", 
                "Fast Startup (ReadyToRun)", 
                "Enterprise ULTRA (Single + Trimmed + ReadyToRun + Compressed)" 
            });
            cmbPresets.SelectedIndex = 2;
            cmbPresets.SelectedIndexChanged += CmbPresets_SelectedIndexChanged;
            pnlPublish.Controls.Add(cmbPresets);

            Label lblRuntime = new Label() { Text = "Target Runtime:", AutoSize = true, Location = new Point(15, 115) };
            pnlPublish.Controls.Add(lblRuntime);

            cmbRuntimes = new ComboBox() { Location = new Point(125, 112), Width = 275, DropDownStyle = ComboBoxStyle.DropDownList, BackColor = bgColor, ForeColor = textColor };
            cmbRuntimes.Items.AddRange(new object[] { "win-x64", "win-arm64", "linux-x64", "linux-arm64", "osx-x64", "osx-arm64", "Any / Default" });
            cmbRuntimes.SelectedIndex = 0;
            pnlPublish.Controls.Add(cmbRuntimes);

            // Flags
            int flagY = 150;
            chkSelfContained = CreateCheckBox("Self-Contained (Include Runtime)", 15, flagY);
            chkSingleFile = CreateCheckBox("Single-File Executable", 15, flagY += 25);
            chkTrimmed = CreateCheckBox("Trimmed Build (Size Optimization)", 15, flagY += 25);
            chkReadyToRun = CreateCheckBox("ReadyToRun (AOT Startup Optimization)", 15, flagY += 25);
            chkCompress = CreateCheckBox("Enable Compression in Single File", 15, flagY += 25);
            chkNativeLibs = CreateCheckBox("Include Native Libraries for Self-Extract", 15, flagY += 25);

            pnlPublish.Controls.Add(chkSelfContained);
            pnlPublish.Controls.Add(chkSingleFile);
            pnlPublish.Controls.Add(chkTrimmed);
            pnlPublish.Controls.Add(chkReadyToRun);
            pnlPublish.Controls.Add(chkCompress);
            pnlPublish.Controls.Add(chkNativeLibs);

            Button btnPublish = CreateButton("PUBLISH PROJECT", 385, 50);
            btnPublish.Location = new Point(15, flagY += 40);
            btnPublish.BackColor = Color.FromArgb(144, 40, 156);
            btnPublish.Font = new Font("Segoe UI", 11, FontStyle.Bold);
            btnPublish.Click += async delegate { await PublishProject(); };
            pnlPublish.Controls.Add(btnPublish);

            // --- CONSOLE ---
            rtbConsole = new RichTextBox();
            rtbConsole.BackColor = Color.FromArgb(10, 10, 10);
            rtbConsole.ForeColor = Color.LightGray;
            rtbConsole.Font = new Font("Consolas", 9.5f);
            rtbConsole.ReadOnly = true;
            rtbConsole.Location = new Point(15, 480);
            rtbConsole.Size = new Size(1050, 215);
            rtbConsole.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            this.Controls.Add(rtbConsole);

            // Initial Preset Setup
            CmbPresets_SelectedIndexChanged(null, null);
        }

        private Button CreateButton(string text, int w, int h)
        {
            Button b = new Button();
            b.Text = text;
            b.Size = new Size(w, h);
            b.FlatStyle = FlatStyle.Flat;
            b.FlatAppearance.BorderSize = 0;
            b.BackColor = accentColor;
            b.ForeColor = Color.White;
            b.Cursor = Cursors.Hand;
            return b;
        }

        private CheckBox CreateCheckBox(string text, int x, int y)
        {
            CheckBox cb = new CheckBox();
            cb.Text = text;
            cb.Location = new Point(x, y);
            cb.AutoSize = true;
            cb.Cursor = Cursors.Hand;
            return cb;
        }

        private void CmbPresets_SelectedIndexChanged(object sender, EventArgs e)
        {
            string preset = cmbPresets.SelectedItem.ToString();
            if (preset.StartsWith("Custom")) return;

            chkSelfContained.Checked = chkSingleFile.Checked = chkTrimmed.Checked = false;
            chkReadyToRun.Checked = chkCompress.Checked = chkNativeLibs.Checked = false;

            if (preset.StartsWith("Dev Mode"))
            {
                cmbRuntimes.SelectedIndex = cmbRuntimes.Items.IndexOf("Any / Default");
            }
            else if (preset.StartsWith("Portable EXE"))
            {
                chkSelfContained.Checked = true;
                chkSingleFile.Checked = true;
                if (cmbRuntimes.SelectedIndex == cmbRuntimes.Items.IndexOf("Any / Default")) cmbRuntimes.SelectedIndex = 0;
            }
            else if (preset.StartsWith("Smallest Size"))
            {
                chkSelfContained.Checked = true;
                chkSingleFile.Checked = true;
                chkTrimmed.Checked = true;
                if (cmbRuntimes.SelectedIndex == cmbRuntimes.Items.IndexOf("Any / Default")) cmbRuntimes.SelectedIndex = 0;
            }
            else if (preset.StartsWith("Fast Startup"))
            {
                chkSelfContained.Checked = true;
                chkReadyToRun.Checked = true;
                if (cmbRuntimes.SelectedIndex == cmbRuntimes.Items.IndexOf("Any / Default")) cmbRuntimes.SelectedIndex = 0;
            }
            else if (preset.StartsWith("Enterprise ULTRA"))
            {
                chkSelfContained.Checked = true;
                chkSingleFile.Checked = true;
                chkTrimmed.Checked = true;
                chkReadyToRun.Checked = true;
                chkCompress.Checked = true;
                chkNativeLibs.Checked = true;
                if (cmbRuntimes.SelectedIndex == cmbRuntimes.Items.IndexOf("Any / Default")) cmbRuntimes.SelectedIndex = 0;
            }
        }

        private void BtnBrowse_Click(object sender, EventArgs e)
        {
            using (FolderBrowserDialog fbd = new FolderBrowserDialog())
            {
                fbd.Description = "Select C# Project Folder";
                if (fbd.ShowDialog() == DialogResult.OK)
                {
                    txtProjectPath.Text = fbd.SelectedPath;
                    SaveConfig();
                    Log("Loaded project path: " + txtProjectPath.Text + "\n", successColor);
                }
            }
        }

        private async Task BootstrapEnvironment()
        {
            Log("Checking for .NET SDK...\n", Color.Cyan);
            bool sdkFound = false;
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "dotnet";
                psi.Arguments = "--version";
                psi.RedirectStandardOutput = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;

                Process p = Process.Start(psi);
                string version = p.StandardOutput.ReadToEnd().Trim();
                p.WaitForExit();

                if (p.ExitCode == 0)
                {
                    Log(string.Format("[OK] .NET SDK is fully installed! Version detected: {0}\n", version), successColor);
                    sdkFound = true;
                }
            }
            catch
            {
                // Silently catch the error, handled below to avoid C# 5.0 'await in catch' constraint
            }

            if (!sdkFound)
            {
                Log("[ERR] .NET SDK not found. Attempting to bootstrap via Winget...\n", warnColor);
                await RunCommandAsync("winget", "install Microsoft.DotNet.SDK.8 --accept-package-agreements --accept-source-agreements", null);
                Log("Please restart MatchBoxCS after installation completes.\n", Color.Yellow);
            }
        }

        private async Task CreateProject()
        {
            if (string.IsNullOrWhiteSpace(txtNewProjectName.Text))
            {
                Log("[ERR] Please enter a project name.\n", errorColor);
                return;
            }

            string baseDir = string.IsNullOrWhiteSpace(txtProjectPath.Text) ? Environment.GetFolderPath(Environment.SpecialFolder.UserProfile) : txtProjectPath.Text;
            
            // If the current path already has a .csproj, go up one level to create new
            if (Directory.GetFiles(baseDir, "*.csproj").Length > 0)
            {
                baseDir = Directory.GetParent(baseDir).FullName;
            }

            string targetDir = Path.Combine(baseDir, txtNewProjectName.Text);
            string tmpl = cmbTemplates.SelectedItem.ToString();
            
            Log(string.Format("Creating new {0} project '{1}'...\n", tmpl, txtNewProjectName.Text), Color.Cyan);
            
            await RunCommandAsync("dotnet", string.Format("new {0} -n {1} -o \"{2}\"", tmpl, txtNewProjectName.Text, targetDir), baseDir);
            
            txtProjectPath.Text = targetDir;
            SaveConfig();
            Log("[OK] Project created and loaded successfully.\n", successColor);
        }

        private async Task PublishProject()
        {
            string rt = cmbRuntimes.SelectedItem.ToString();
            string args = "publish -c Release";

            if (rt != "Any / Default")
            {
                args += " -r " + rt;
            }

            // Microsoft Learn / tjaddison.com Advanced Architecture Configurations
            if (chkSelfContained.Checked) args += " --self-contained true";
            else if (rt != "Any / Default") args += " --self-contained false"; // Required explicitly in .NET 8+ if Runtime is specified but you don't want self-contained

            if (chkSingleFile.Checked) args += " -p:PublishSingleFile=true";
            if (chkTrimmed.Checked) args += " -p:PublishTrimmed=true";
            if (chkReadyToRun.Checked) args += " -p:PublishReadyToRun=true";
            if (chkCompress.Checked) args += " -p:EnableCompressionInSingleFile=true";
            if (chkNativeLibs.Checked) args += " -p:IncludeNativeLibrariesForSelfExtract=true";

            string outDir = Path.Combine(txtProjectPath.Text, "MatchBoxCSPublish");
            args += " -o \"" + outDir + "\"";

            Log(string.Format("[INFO] Starting Advanced Publish Engine...\nTarget Output: {0}\n", outDir), Color.Magenta);
            
            await RunDotNetAsync(args);
            
            if (Directory.Exists(outDir))
            {
                Log("[OK] Publish Complete! Opening output directory...\n", successColor);
                Process.Start("explorer.exe", "\"" + outDir + "\"");
            }
        }

        private async Task RunDotNetAsync(string arguments)
        {
            string dir = txtProjectPath.Text;
            if (string.IsNullOrWhiteSpace(dir) || !Directory.Exists(dir))
            {
                Log("[ERR] Invalid Project Directory. Please browse or create a project first.\n", errorColor);
                return;
            }

            if (Directory.GetFiles(dir, "*.csproj").Length == 0 && Directory.GetFiles(dir, "*.sln").Length == 0)
            {
                Log("[WARN] Warning: No .csproj or .sln found in the directory. Command might fail.\n", warnColor);
            }

            await RunCommandAsync("dotnet", arguments, dir);
        }

        private async Task RunCommandAsync(string fileName, string arguments, string workingDir)
        {
            Log(string.Format("\n> {0} {1}\n", fileName, arguments), Color.Cyan);
            
            try
            {
                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = fileName;
                psi.Arguments = arguments;
                psi.WorkingDirectory = string.IsNullOrEmpty(workingDir) ? Environment.CurrentDirectory : workingDir;
                psi.RedirectStandardOutput = true;
                psi.RedirectStandardError = true;
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;

                using (Process p = new Process())
                {
                    p.StartInfo = psi;
                    p.OutputDataReceived += (s, e) => { if (e.Data != null) Log(e.Data + "\n", textColor); };
                    p.ErrorDataReceived += (s, e) => { if (e.Data != null) Log(e.Data + "\n", errorColor); };

                    p.Start();
                    p.BeginOutputReadLine();
                    p.BeginErrorReadLine();

                    await Task.Run(new Action(() => p.WaitForExit()));

                    Color exitColor = p.ExitCode == 0 ? successColor : errorColor;
                    Log(string.Format("[Process exited with code {0}]\n", p.ExitCode), exitColor);
                }
            }
            catch (Exception ex)
            {
                Log("[ERR] Execution Error: " + ex.Message + "\n", errorColor);
            }
        }

        private void Log(string message, Color color)
        {
            if (rtbConsole.InvokeRequired)
            {
                rtbConsole.Invoke(new Action<string, Color>(Log), new object[] { message, color });
                return;
            }

            rtbConsole.SelectionStart = rtbConsole.TextLength;
            rtbConsole.SelectionLength = 0;
            rtbConsole.SelectionColor = color;
            rtbConsole.AppendText(message);
            rtbConsole.SelectionColor = rtbConsole.ForeColor;
            rtbConsole.ScrollToCaret();
        }

        private void SaveConfig()
        {
            try
            {
                if (!Directory.Exists(configDir)) Directory.CreateDirectory(configDir);
                File.WriteAllText(configFile, txtProjectPath.Text);
            }
            catch { /* Silent fail for config */ }
        }

        private void LoadConfig()
        {
            try
            {
                if (File.Exists(configFile))
                {
                    string path = File.ReadAllText(configFile).Trim();
                    if (Directory.Exists(path))
                    {
                        txtProjectPath.Text = path;
                        Log("Loaded previous session: " + path + "\n", successColor);
                    }
                }
            }
            catch { }
        }
    }

    public static class Program
    {
        [STAThread]
        public static void Main()
        {
            // Wrapped in try/catch to prevent crashes in PowerShell 
            // if the session has already initialized WinForms visual styles previously.
            try { Application.EnableVisualStyles(); } catch { }
            try { Application.SetCompatibleTextRenderingDefault(false); } catch { }
            
            Application.Run(new MainForm());
        }
    }
}
'@

# Compile the C# engine directly in memory. 
# We explicitly suppress warnings and use default standard libraries.
if (-not ("MatchBoxCS.Program" -as [type])) {
    Write-Host "Igniting MatchBoxCS Engine..." -ForegroundColor Cyan

    try {
        Add-Type -TypeDefinition $matchboxCode -ReferencedAssemblies "System.Windows.Forms", "System.Drawing", "System.Data" -Language CSharp
    } catch {
        Write-Host "Failed to compile the embedded engine. Ensure you are running PowerShell 5.1 or newer." -ForegroundColor Red
        $error[0] | Format-List -Force
        Pause
        exit
    }
} else {
    Write-Host "MatchBoxCS Engine is already loaded in this PowerShell session. Launching..." -ForegroundColor Cyan
}

# Launch the Application
[MatchBoxCS.Program]::Main()
# SIG # Begin signature block
# MIIFiwYJKoZIhvcNAQcCoIIFfDCCBXgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbqJ904cWrnn9dHKRn42NSfuY
# HvOgggMcMIIDGDCCAgCgAwIBAgIQdTnGUb3fnrZCF1K2xTtGMjANBgkqhkiG9w0B
# AQsFADAkMSIwIAYDVQQDDBlDSEVTSS1KRENvZGUtU2lnbmluZy0yMDI2MB4XDTI2
# MDMwNjE0NDY0NVoXDTI3MDMwNjE0NDY0NVowJDEiMCAGA1UEAwwZQ0hFU0ktSkRD
# b2RlLVNpZ25pbmctMjAyNjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AMIvE+cjfWSthiMrydvmvgrd9ucGb77R+W5jS2EfE73xAMxLBjZBbfTdh8Ig1Oj2
# aZuTWPwXoETEdh4ocXbtyYX0WDXqnNwSzDGDLKNiMzQ2bJEgfeegSGazOCUXchya
# x82YR81WyxGd4sIqBBC3JpFxr+O6MZHHtqUHkkHyUY1Q8phH40X6UOH+l7AIB3yC
# zxqyEJ68RNQFh4UhD2dS4DneN0xyPlQ/VhXcMF4dONwQz7lSIIgD+iiJzXo9Ka7F
# ZOGm1jtq7i/p3XwLuq3zMxgeHh3VcVWh2QbO2PODgIxtchRMFBkW5BtiBjV5nSs7
# D879uPSkhTEGk2UAHDDsbKkCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQGI/EgF0UkEE5pOr6J/upQmqqo2jAN
# BgkqhkiG9w0BAQsFAAOCAQEABPRv9v2ibkmhWvzlXApwWNScLZ2c6r1ErdcIYEDf
# UHMPwiWV8ztOT9cK6NunF9VjPSb/dCxu2OU+F+HGl1utqoTtPMV+95p9ctwu12KR
# 20/JxfmfoGu1dTYQYZZeWapbBNOwwPg3GEti2PNHMCI+QBSN3MbnfABwVFs9T2X+
# 7tQaOdAhY1kqp8siaCoCpwcoGWlhDdO6+hCrI3Qz5oWN/hMCrL6Sm3afgDoh8xzB
# fxnNdcwQq2+etj+JM9Gcz+C8fUnlZmKPn+wEsMS+oZqfEUt5HEzEIe8LVuuub/Ah
# 8eTO2IA6ouL9V9TyN0aWtV2l0qoqyoY+odq6v1QPInnLfDGCAdkwggHVAgEBMDgw
# JDEiMCAGA1UEAwwZQ0hFU0ktSkRDb2RlLVNpZ25pbmctMjAyNgIQdTnGUb3fnrZC
# F1K2xTtGMjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZ
# BgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYB
# BAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUeUGhjm7vfAoPM3ByokQMPDYUJ7UwDQYJ
# KoZIhvcNAQEBBQAEggEAiou50baBjnwU800dl5fLX+P2N8G9T6w6g5dv8n1q/5Rx
# rxZi8Q8KezKjH7ZGvaaA3F7V7sFnScsNG/2P+IweXQe8RwNvZz7DHjk9f43moxmm
# r/CNzc7I+e/OGcvu1k1Fq4hM7hjSJa89qcGg5JWBqT3mGWcct2GBjuQ+rMHZphf7
# jzN7uJtSorVUAoPGYJItnH3LPPcuj85lY4riMLlTZTpuZFPicP8+EWWInnav48/D
# d8McmhSiLog25anDz1+otYno6EXTJzsFgsPa4lqjzTk2e366NXqjIpmniw/i3c3e
# +hqcfRhk20O96l9YprK3sm1iQurH5xFZgWWgaxopUQ==
# SIG # End signature block
