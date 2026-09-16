#Requires -Version 5.1
param([string]$StudioPath = $env:STUDIO_PATH)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if (-not $StudioPath) {
    $StudioPath = Get-ChildItem (Join-Path ${env:ProgramFiles(x86)} 'Embarcadero\Studio') -Directory |
        Sort-Object { [Version]$_.Name } -Descending |
        Select-Object -ExpandProperty FullName -First 1
}
$DextRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$OutputRoot = Join-Path $DextRoot 'Output'
$ReleasePaths = @(Get-ChildItem $OutputRoot -Directory -Recurse |
    Where-Object { $_.FullName -match 'Win64_Release' } |
    Select-Object -ExpandProperty FullName)
if (-not $ReleasePaths.Count) { throw 'Compile o Output Win64 Release do Dext primeiro.' }
$TestOutput = Join-Path $env:TEMP ('dext-webbroker-tests-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory (Join-Path $TestOutput 'dcu') -Force | Out-Null
$CompilerArgs = @('-B', '-Q', '-TX.exe', '-NSSystem;System.Win;Winapi;Vcl;Data;Web;Soap')
foreach ($SearchPath in $ReleasePaths) {
    $CompilerArgs += ('-U"{0}"' -f $SearchPath)
    $CompilerArgs += ('-I"{0}"' -f $SearchPath)
}
$CompilerArgs += ('-I"{0}\Sources\Common"' -f $DextRoot)
$CompilerArgs += ('-E"{0}"' -f $TestOutput)
$CompilerArgs += ('-NU"{0}\dcu"' -f $TestOutput)
$CompilerArgs += 'WebBrokerEmptyResponseTests.dpr'
$ResponseFile = Join-Path $TestOutput 'build.rsp'
$CompilerArgs | Set-Content -LiteralPath $ResponseFile -Encoding Ascii
$RsVars = Join-Path $StudioPath 'bin\rsvars.bat'
$Dcc64 = Join-Path $StudioPath 'bin\dcc64.exe'
Push-Location $PSScriptRoot
try {
    cmd /c "`"$RsVars`" >nul && `"$Dcc64`" @`"$ResponseFile`""
    if ($LASTEXITCODE -ne 0) { throw "Build falhou: $LASTEXITCODE" }
    & (Join-Path $TestOutput 'WebBrokerEmptyResponseTests.exe')
    if ($LASTEXITCODE -ne 0) { throw "Testes falharam: $LASTEXITCODE" }
} finally {
    Pop-Location
}
