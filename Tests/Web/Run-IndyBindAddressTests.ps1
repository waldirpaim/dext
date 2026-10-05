#Requires -Version 5.1
# Builds and runs IndyBindAddressTests.dpr against the Sources tree (not the
# prebuilt Output), so it always tests the TDextIndyWebServer being changed.
param([string]$StudioPath = $env:STUDIO_PATH)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $StudioPath) {
    $StudioPath = Get-ChildItem (Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio') -Directory |
        Sort-Object { [Version]$_.Name } -Descending |
        Select-Object -ExpandProperty FullName -First 1
}
$DextRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$SourcesRoot = Join-Path $DextRoot 'Sources'
$SearchPaths = @($SourcesRoot) + @(Get-ChildItem $SourcesRoot -Directory -Recurse |
    Select-Object -ExpandProperty FullName)
$TestOutput = Join-Path $env:TEMP ('dext-indy-bind-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory (Join-Path $TestOutput 'dcu') -Force | Out-Null
$CompilerArgs = @('-B', '-Q', '-TX.exe', '-NSSystem;System.Win;Winapi;Vcl;Data;Web;Soap')
foreach ($SearchPath in $SearchPaths) {
    $CompilerArgs += ('-U"{0}"' -f $SearchPath)
}
$CompilerArgs += ('-I"{0}\Sources\Common"' -f $DextRoot)
$CompilerArgs += ('-E"{0}"' -f $TestOutput)
$CompilerArgs += ('-NU"{0}\dcu"' -f $TestOutput)
$CompilerArgs += 'IndyBindAddressTests.dpr'
$ResponseFile = Join-Path $TestOutput 'build.rsp'
$CompilerArgs | Set-Content -LiteralPath $ResponseFile -Encoding Ascii
$RsVars = Join-Path $StudioPath 'bin\rsvars.bat'
$Dcc64 = Join-Path $StudioPath 'bin\dcc64.exe'
Push-Location $PSScriptRoot
try {
    cmd /c "`"$RsVars`" >nul && `"$Dcc64`" @`"$ResponseFile`""
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $LASTEXITCODE" }
    & (Join-Path $TestOutput 'IndyBindAddressTests.exe')
    if ($LASTEXITCODE -ne 0) { throw "Tests failed: $LASTEXITCODE" }
} finally {
    Pop-Location
    Remove-Item -LiteralPath $TestOutput -Recurse -Force -ErrorAction SilentlyContinue
}
