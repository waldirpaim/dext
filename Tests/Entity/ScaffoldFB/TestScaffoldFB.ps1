# TestScaffoldFB.ps1 - Manual test for Firebird scaffolding
$DextExe = ".\Apps\dext.exe"
$DbPath = ".\Tests\Output\EMPLOYEE.FDB"
$OutputDir = ".\Tests\ScaffoldFB"

if (-not (Test-Path $OutputDir)) { mkdir $OutputDir }

$OutputFile = Join-Path $OutputDir "Entities.pas"
$Connection = "Database=$DbPath;User_Name=SYSDBA;Password=masterkey;Protocol=TCPIP;Server=localhost"

Write-Host "Running Scaffolding for Firebird..." -ForegroundColor Cyan
& $DextExe scaffold --driver firebird --connection $Connection --output $OutputFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSUCCESS: Scaffolding completed!" -ForegroundColor Green
    Write-Host "Output file: $OutputFile" -ForegroundColor Yellow
    
    # Check for User2 duplication
    $Content = Get-Content $OutputFile -Raw
    if ($Content -match "property User2") {
        Write-Host "CRITICAL FAILURE: 'User2' property still found in output!" -ForegroundColor Red
    } else {
        Write-Host "VERIFIED: No duplicate 'User2' properties found." -ForegroundColor Green
    }
} else {
    Write-Host "`nERROR: Scaffolding failed!" -ForegroundColor Red
}
