# Manual MySQL Setup Script - Finds MySQL automatically
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  E-Commerce Database Setup Tool" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Common MySQL installation paths
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe",
    "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\mysql\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.x\bin\mysql.exe"
)

# Try to find MySQL
$mysqlExe = $null
Write-Host "Searching for MySQL installation..." -ForegroundColor Yellow

foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqlExe = $path
        Write-Host "Found MySQL at: $path" -ForegroundColor Green
        break
    }
}

# Also check if mysql is in PATH
if ($null -eq $mysqlExe) {
    try {
        $mysqlVersion = & mysql --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $mysqlExe = "mysql"
            Write-Host "MySQL found in PATH" -ForegroundColor Green
        }
    } catch {
        # MySQL not in PATH
    }
}

if ($null -eq $mysqlExe) {
    Write-Host ""
    Write-Host "ERROR: MySQL not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please do one of the following:" -ForegroundColor Yellow
    Write-Host "1. Install MySQL from https://dev.mysql.com/downloads/mysql/" -ForegroundColor White
    Write-Host "2. Install XAMPP from https://www.apachefriends.org/" -ForegroundColor White
    Write-Host "3. Add MySQL to your PATH (see setup-mysql-path.md)" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if schema file exists
$schemaFile = "database\schema.sql"
if (-Not (Test-Path $schemaFile)) {
    Write-Host "ERROR: Schema file not found at $schemaFile" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "MySQL found! Proceeding with database setup..." -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: You will be prompted for your MySQL root password" -ForegroundColor Yellow
Write-Host ""

# Read the SQL file and pipe to MySQL
try {
    Get-Content $schemaFile | & $mysqlExe -u root -p

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host "  Database setup SUCCESS!" -ForegroundColor Green
        Write-Host "=====================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Configure your .env file:" -ForegroundColor White
        Write-Host "   Copy-Item .env.example .env" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Edit .env and set your MySQL password" -ForegroundColor White
        Write-Host ""
        Write-Host "3. Install Node.js dependencies:" -ForegroundColor White
        Write-Host "   npm install" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4. Start the server:" -ForegroundColor White
        Write-Host "   npm start" -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERROR: Database setup failed!" -ForegroundColor Red
        Write-Host "Please check:" -ForegroundColor Yellow
        Write-Host "- Your MySQL password is correct" -ForegroundColor White
        Write-Host "- MySQL service is running" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

Write-Host ""
Read-Host "Press Enter to exit"
