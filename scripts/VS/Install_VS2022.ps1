#
# The list of VS 2022 components: https://docs.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2022
#

Function InstallVS {
  Param
  (
    [String] $WorkLoads,
    [String] $Sku,
    [String] $VSBootstrapperURL,
    [String] $ChannelUri
  )

  $exitCode = -1

  try {
    Write-Host "Downloading Bootstrapper ..."
    Invoke-WebRequest -Uri $VSBootstrapperURL -OutFile "${env:Temp}\vs_$Sku.exe"

    $FilePath = "${env:Temp}\vs_$Sku.exe"
    $Arguments = ($WorkLoads, '--quite', '--norestart', '--wait', '--nocache')

    if ($ChannelUri) {
      $Arguments += (
        '--channelUri', $ChannelUri,
        '--installChannelUri', $ChannelUri
      )
    }

    Write-Host "Starting Install ..."
    $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -Wait
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0 -or $exitCode -eq 3010) {
      Write-Host -Object 'Installation successful'
      return $exitCode
    }
    else {
      Write-Host -Object "Non zero exit code returned by the installation process : $exitCode."

      # this wont work because of log size limitation in extension manager
      # Get-Content $customLogFilePath | Write-Host

      exit $exitCode
    }
  }
  catch {
    Write-Host -Object "Failed to install Visual Studio. Check the logs for details in $customLogFilePath"
    Write-Host -Object $_.Exception.Message
    exit -1
  }
}

$WorkLoads = '--add Microsoft.VisualStudio.Component.CoreEditor ' + `
  '--add Microsoft.VisualStudio.Workload.CoreEditor ' + `
  '--add Microsoft.Net.Component.4.8.SDK '

$Sku = 'Community'

$ChannelUri = $null

if ($env:install_vs2022_preview) {
  Write-Host "Installing from 'Preview' channel"
  $VSBootstrapperURL = 'https://aka.ms/vs/17/pre/vs_community.exe'
}
else {
  Write-Host "Installing from 'Release' channel"
  $VSBootstrapperURL = 'https://aka.ms/vs/17/release/vs_buildtools.exe'

  # This is how to know channelUri for previous versions of VS 2022
  # - Download previous bootstrapper for Professional edition: https://docs.microsoft.com/en-us/visualstudio/releases/2022/history#release-dates-and-build-numbers
  # - Run `.\vs_Professional.exe --layout .\VSLayout
  # - In the output log look for the first line with `/channel`, for example:
  #
  #      Download of 'https://aka.ms/vs/16/release/149189645_1152370582/channel' succeeded using engine 'WebClient'
  # https://aka.ms/vs/16/release/149189645_1152370582/channel is the url to `VisualStudio.16.Release.chman` file.

  # Pin VS 2019 16.5.5 for now because of issues with devenv.com: https://developercommunity.visualstudio.com/content/problem/1048804/cannot-build-project-with-devenvcom-in-visual-stud.html
  #$ChannelUri = 'https://aka.ms/vs/16/release/149189645_1152370582/channel'
	
  #$VSBootstrapperURL = 'https://download.visualstudio.microsoft.com/download/pr/68d6b204-9df0-4fcc-abcc-08ee0eff9cb2/b029547488a9383b0c8d8a9c813e246feb3ec19e0fe55020d4878fde5f0983fe/vs_Community.exe'
}

$ErrorActionPreference = 'Stop'

# Install VS
$exitCode = InstallVS -WorkLoads $WorkLoads -Sku $Sku -VSBootstrapperURL $VSBootstrapperURL -ChannelUri $ChannelUri

$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community"
if (-not (Test-Path $vsPath)) {
  $vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Preview"
}

Write-Host "Disabling VS-related services"
if (get-Service SQLWriterw -ErrorAction Ignore) {
  Stop-Service SQLWriter
  Set-Service SQLWriter -StartupType Manual
}
if (get-Service IpOverUsbSvc -ErrorAction Ignore) {
  Stop-Service IpOverUsbSvc
  Set-Service IpOverUsbSvc -StartupType Manual
}

Write-Host "Adding Visual Studio 2022 current MSBuild to PATH..." -ForegroundColor Cyan

Add-Path "$vsPath\MSBuild\Current\Bin"
Add-Path "$vsPath\Common7\IDE\Extensions\Microsoft\SQLDB\DAC"