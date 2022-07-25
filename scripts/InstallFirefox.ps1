$workdir = "c:\installer\"

If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }

$source = "https://download.microsoft.com/download/6/4/6/64677D6E-06EA-4DBB-AF05-B92403BB6CB9/ENU/x64/adalsql.msi"
$destination = "$workdir\adalsql.msi"

if (Get-Command 'Invoke-Webrequest')
{
     Invoke-WebRequest $source -OutFile $destination
}
else
{
    $WebClient = New-Object System.Net.WebClient
    $webclient.DownloadFile($source, $destination)
}

Start-Process -FilePath "$workdir\adalsql.msi" -ArgumentList "/quiet /passive"

Start-Sleep -s 35

rm -Force $workdir -Recurse -Confirm:$false