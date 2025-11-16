# PowerShell script to setup the database
Write-Host "Setting up E-Commerce Database..." -ForegroundColor Green
Write-Host ""

$mysqlUser = "root"
$dbFile = "database/schema.sql"

# Check if mysql is available
try {
    $mysqlVersion = mysql --version
    Write-Host "MySQL found: $mysqlVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: MySQL not found in PATH" -ForegroundColor Red
    Write-Host "Please install MySQL or add it to your PATH" -ForegroundColor Yellow
    exit 1
}

# Check if schema file exists
if (-Not (Test-Path $dbFile)) {
    Write-Host "ERROR: Schema file not found at $dbFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Please enter your MySQL root password when prompted." -ForegroundColor Yellow
Write-Host ""

# Run the SQL file
Get-Content $dbFile | mysql -u $mysqlUser -p

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Database setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: npm start" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Error setting up database. Please check your MySQL credentials." -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Read-Host "Press Enter to continue"
