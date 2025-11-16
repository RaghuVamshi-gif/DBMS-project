# Adding MySQL to Windows PATH

## Quick Fix - Find MySQL Installation

MySQL is typically installed in one of these locations:
- `C:\Program Files\MySQL\MySQL Server 8.0\bin`
- `C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin`
- `C:\mysql\bin`
- `C:\xampp\mysql\bin` (if using XAMPP)
- `C:\wamp64\bin\mysql\mysql8.0.x\bin` (if using WAMP)

## Method 1: Add MySQL to PATH Permanently

1. **Find your MySQL bin folder:**
   - Open File Explorer
   - Check the locations above
   - Look for `mysql.exe` in the `bin` folder

2. **Add to System PATH:**
   - Press `Win + X` and select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find and select "Path"
   - Click "Edit"
   - Click "New"
   - Paste your MySQL bin path (e.g., `C:\Program Files\MySQL\MySQL Server 8.0\bin`)
   - Click "OK" on all dialogs
   - **Restart PowerShell** for changes to take effect

## Method 2: Use Full Path (Temporary)

If you don't want to modify PATH, use the full path to mysql:

```powershell
# Replace with your actual MySQL path
& "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p
```

## Method 3: Create PowerShell Alias (Session-only)

```powershell
# Find MySQL (example paths)
Set-Alias mysql "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

# Then you can use mysql normally
mysql -u root -p
```

## Verify Installation

After adding to PATH, verify with:
```powershell
mysql --version
```

You should see output like: `mysql  Ver 8.0.x for Win64 on x86_64`
