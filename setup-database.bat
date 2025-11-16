@echo off
echo Setting up E-Commerce Database...
echo.
echo Please enter your MySQL root password when prompted.
echo.

mysql -u root -p -e "source database/schema.sql"

if %errorlevel% equ 0 (
    echo.
    echo Database setup completed successfully!
    echo.
) else (
    echo.
    echo Error setting up database. Please check your MySQL credentials.
    echo.
)

pause
