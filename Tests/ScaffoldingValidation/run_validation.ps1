# Dext Scaffolding Validation Script (Win64)
$ErrorActionPreference = "Stop"

$RootPath = Get-Location
$ToolProject = "..\..\Apps\CLI\DextTool.dproj"
$ValidatorProject = "ScaffoldingValidator.dproj"
$OutputPath = ".\Output"

if (!(Test-Path $OutputPath)) { New-Item -ItemType Directory -Path $OutputPath }

$DcuPath = ".\dcu"
$SrcDirs = Get-ChildItem -Path "..\..\Sources", "..\..\External" -Recurse | Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName
$SrcPath = ($SrcDirs -join ";") + ";..\..\Sources;..\..\External"
$IncPath = "..\..\Sources"

# Ensure libmariadb.dll is available in the current directory
if (Test-Path "C:\Program Files\MariaDB 12.1\lib\libmariadb.dll") {
    Copy-Item "C:\Program Files\MariaDB 12.1\lib\libmariadb.dll" . -Force -ErrorAction SilentlyContinue
}

Write-Host "--- Compiling DextTool (Win64) using existing DCUs ---" -ForegroundColor Cyan
& cmd /c "call `"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat`" && msbuild `"../../Apps/CLI/DextTool.dproj`" /t:Build /p:Config=Debug /p:Platform=Win64 /p:DCC_UnitSearchPath=`"$SrcPath`" /v:minimal /nologo"

Write-Host "--- Compiling ScaffoldingValidator (Win64) using existing DCUs ---" -ForegroundColor Cyan
& cmd /c "call `"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat`" && msbuild ScaffoldingValidator.dproj /t:Build /p:Config=Debug /p:Platform=Win64 /p:DCC_UnitSearchPath=`"$SrcPath`" /v:minimal /nologo"

# EXE is in the root based on previous dir listing
$ValidatorExe = "ScaffoldingValidator.exe"

if (Test-Path $ValidatorExe) {
    Write-Host "--- Running ScaffoldingValidator (Schema Creation) ---" -ForegroundColor Green
    $FullValidatorPath = Resolve-Path $ValidatorExe
    & $FullValidatorPath
} else {
    Write-Host "Failed to compile ScaffoldingValidator.exe" -ForegroundColor Red
    exit 1
}

$DextTool = "C:\dev\Dext\DextRepository\Output\Win64\DextTool.exe"
if (!(Test-Path $DextTool)) { $DextTool = "C:\dev\Dext\DextRepository\Output\DextTool.exe" }

# Scaffold from each DB
$Connections = @{
    "SQLite"     = @{ driver="sqlite"; conn="Database=test.db" };
    "Firebird"   = @{ driver="fb";     conn="Database=C:\temp\dext_test.fdb;User_Name=SYSDBA;Password=masterkey" };
    "MySQL"      = @{ driver="mysql";  conn="Server=localhost;Database=dext_test;User_Name=root;Password=root;VendorLib=libmariadb.dll" };
    "SQLServer"  = @{ driver="mssql";  conn="Server=localhost;Database=dext_test;User_Name=sa;Password=SQL@d3veloper;Encrypt=No;TrustServerCertificate=Yes" }
}

Write-Host "--- Running Scaffolding for each Provider ---" -ForegroundColor Cyan
foreach ($Prov in $Connections.Keys) {
    $Cfg = $Connections[$Prov]
    $OutFile = "Generated.$Prov.pas"
    Write-Host "Scaffolding $Prov..."
    & $DextTool scaffold -d $($Cfg.driver) -c "$($Cfg.conn)" -o "$OutFile" --with-metadata --poco
}

Write-Host "--- Validating Generated Units (Win64) ---" -ForegroundColor Cyan
$GeneratedFiles = Get-ChildItem "Generated.*.pas"
foreach ($File in $GeneratedFiles) {
    Write-Host "Compiling $($File.Name)..."
    $TestDpr = "TestComp.$($File.BaseName).dpr"
    $Content = @"
program TestComp;
uses 
  System.SysUtils, 
  Dext.Entity,
  $($File.BaseName) in '$($File.Name)';
begin
  Writeln('Compilation successful for $($File.Name)');
end.
"@
    Set-Content -Path $TestDpr -Value $Content
    
    # Use pre-compiled DCUs for validation
    $Result = & cmd /c "call `"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat`" && dcc64 $TestDpr -I`"$IncPath`" -U`"$SrcPath;$IncPath`" -NH`"$DcuPath`""
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] $($File.Name) compiled correctly (Win64)." -ForegroundColor Green
    } else {
        Write-Host "[FAILED] $($File.Name) failed to compile (Win64)." -ForegroundColor Red
    }
    Remove-Item $TestDpr -ErrorAction SilentlyContinue
    # Clean up generated artifacts to keep it clean
    Remove-Item "TestComp.exe" -ErrorAction SilentlyContinue
    Remove-Item "TestComp.res" -ErrorAction SilentlyContinue
    Remove-Item "TestComp.dcu" -ErrorAction SilentlyContinue
}

Write-Host "Validation complete (Win64)." -ForegroundColor Cyan
