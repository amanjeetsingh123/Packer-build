#
# The list of VS 2019 components: https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community?vs-2019&view=vs-2019
#

Function InstallVS
{
  Param
  (
    [String] $WorkLoads,
    [String] $Sku,
    [String] $VSBootstrapperURL,
    [String] $ChannelUri
  )

  $exitCode = -1

  try
  {
    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ($WorkLoads, '--quiet', '--norestart', '--wait', '--nocache')

    if ($ChannelUri) {
        $Arguments += (
            '--channelUri', $ChannelUri,
            '--installChannelUri', $ChannelUri
        )
    }

    Write-Host "Starting Install ..."
    $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -Wait -PassThru
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010)
    {
      Write-Host -Object 'Installation successful'
      return $exitCode
    }
    else
    {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch
  {
    Write-Host -Object "Failed to install Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$WorkLoads = '--add Microsoft.Net.Component.4.8.SDK ' + `
    '--add Microsoft.Net.Component.4.8.TargetingPack '+ `
    '--add Microsoft.Net.Component.4.7.2.TargetingPack ' + `
    '--add Microsoft.Net.ComponentGroup.DevelopmentPrerequisites ' + `
    '--add Microsoft.VisualStudio.Component.TypeScript.TSServer ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.WebToolsExtensions ' + `
    '--add Microsoft.VisualStudio.Component.JavaScript.TypeScript ' + `
    '--add Microsoft.VisualStudio.Component.JavaScript.Diagnostics ' + `
    '--add Microsoft.VisualStudio.Component.Roslyn.Compiler ' + `
    '--add Microsoft.Component.MSBuild ' + `
    '--add Microsoft.VisualStudio.Component.Roslyn.LanguageServices ' + `
    '--add Microsoft.VisualStudio.Component.TextTemplating ' + `
    '--add Component.Microsoft.VisualStudio.RazorExtension ' + `
    '--add Microsoft.VisualStudio.Component.IISExpress ' + `
    '--add Microsoft.VisualStudio.Component.NuGet ' + `
    '--add Microsoft.VisualStudio.Component.MSODBC.SQL ' + `
    '--add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime ' + `
    '--add Microsoft.VisualStudio.Component.Common.Azure.Tools ' + `
    '--add Microsoft.VisualStudio.Component.SQL.CLR ' + `
    '--add Microsoft.VisualStudio.Component.MSSQL.CMDLnUtils ' + `
    '--add Microsoft.Component.ClickOnce ' + `
    '--add Microsoft.VisualStudio.Component.ManagedDesktop.Core ' + `
    '--add Microsoft.VisualStudio.Component.SQL.SSDT ' + `
    '--add Microsoft.VisualStudio.Component.SQL.DataSources ' + `
    '--add Component.Microsoft.Web.LibraryManager ' + `
    '--add Component.Microsoft.WebTools.BrowserLink.WebLivePreview ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.Web ' + `
    '--add Microsoft.NetCore.Component.Runtime.6.0 ' + `
    '--add Microsoft.NetCore.Component.SDK ' + `
    '--add Microsoft.VisualStudio.Component.FSharp ' + `
    '--add Microsoft.ComponentGroup.ClickOnce.Publish ' + `
    '--add Microsoft.NetCore.Component.DevelopmentTools ' + `
    '--add Microsoft.VisualStudio.Component.FSharp.WebTemplates ' + `
    '--add Microsoft.VisualStudio.Component.DockerTools ' + `
    '--add Microsoft.NetCore.Component.Web ' + `
    '--add Microsoft.VisualStudio.Component.WebDeploy ' + `
    '--add Microsoft.VisualStudio.Component.AppInsights.Tools ' + `
    '--add Microsoft.VisualStudio.Component.Web ' + `
    '--add Microsoft.Net.Component.4.8.TargetingPack ' + `
    '--add Microsoft.Net.ComponentGroup.4.8.DeveloperTools ' + `
    '--add Component.Microsoft.VisualStudio.Web.AzureFunctions ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.AzureFunctions ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.Web.CloudTools ' + `
    '--add Microsoft.VisualStudio.Component.DiagnosticTools ' + `
    '--add Microsoft.VisualStudio.Component.EntityFramework ' + `
    '--add Microsoft.VisualStudio.Component.Debugger.JustInTime ' + `
    '--add Component.Microsoft.VisualStudio.LiveShare.2022 ' + `
    '--add Microsoft.VisualStudio.Component.WslDebugging ' + `
    '--add Microsoft.VisualStudio.Component.IntelliCode ' + `
    '--add Microsoft.VisualStudio.Workload.NetWeb ' + `
    '--add Microsoft.VisualStudio.Component.Azure.ClientLibs ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.Azure.Prerequisites ' + `
    '--add Microsoft.Component.Azure.DataLake.Tools ' + `
    '--add Microsoft.VisualStudio.Component.Azure.ResourceManager.Tools ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.Azure.ResourceManager.Tools ' + `
    '--add Microsoft.VisualStudio.Component.Azure.AuthoringTools ' + `
    '--add Microsoft.VisualStudio.Component.Azure.Waverton.BuildTools ' + `
    '--add Microsoft.VisualStudio.Component.Azure.Compute.Emulator ' + `
    '--add Microsoft.VisualStudio.Component.Azure.Waverton ' + `
    '--add Microsoft.VisualStudio.ComponentGroup.Azure.CloudServices ' + `
    '--add Microsoft.VisualStudio.Component.Azure.ServiceFabric.Tools ' + `
    '--add Microsoft.VisualStudio.Component.Azure.Powershell ' + `
    '--add Microsoft.VisualStudio.Workload.Azure ' + `
    '--add Microsoft.Component.PythonTools ' + `
    '--add Microsoft.VisualStudio.Component.Windows10SDK.19041 ' + `
    '--add Microsoft.VisualStudio.Workload.Python ' + `
    '--add Microsoft.VisualStudio.Component.Windows10SDK.18362 ' + `
    '--add Microsoft.Component.HelpViewer '

$Sku = 'Community'

$ChannelUri = $null

if ($env:install_vs2019_preview) {
    Write-Host "Installing from 'Preview' channel"
    $VSBootstrapperURL = 'https://aka.ms/vs/17/pre/vs_community.exe'
} else {
    Write-Host "Installing from 'Release' channel"
    $VSBootstrapperURL = 'https://aka.ms/vs/17/release/vs_community.exe'
}

$ErrorActionPreference = 'Stop'

# Install VS
$exitCode = InstallVS -WorkLoads $WorkLoads -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL -ChannelUri $ChannelUri

$vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community"
if (-not (Test-Path $vsPath)) {
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Preview"
}
