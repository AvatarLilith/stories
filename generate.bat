@echo off
:: generate.bat — run this after adding new stories
:: place this file in the same folder as index.html

set STORIES_DIR=stories
set INDEX=index.html
set TMPFILE=%TEMP%\stories_files.txt
set OUTFILE=%TEMP%\stories_out.txt

if not exist "%STORIES_DIR%" (
  echo No 'stories' folder found. Make sure your Instagram stories folder is here.
  pause
  exit /b 1
)

:: collect all media files
(for /r "%STORIES_DIR%" %%F in (*.jpg *.jpeg *.png *.webp *.mp4 *.mov *.webm) do (
  echo %%F
)) > "%TMPFILE%"

:: check we got something
for %%A in ("%TMPFILE%") do if %%~zA==0 (
  echo No media files found in '%STORIES_DIR%'.
  pause
  exit /b 1
)

:: build replacement block using PowerShell (handles the regex reliably)
powershell -NoProfile -Command ^
  "$idx = Get-Content '%INDEX%' -Raw;" ^
  "$files = Get-Content '%TMPFILE%';" ^
  "$lines = ($files | ForEach-Object { '  \"' + $_.Replace('\','/') + '\",' }) -join \"`n\";" ^
  "$block = '// FILES_START' + \"`n\" + $lines + \"`n\" + '  // FILES_END';" ^
  "$new = $idx -replace '(?s)// FILES_START.*?// FILES_END', $block;" ^
  "Set-Content '%INDEX%' $new -NoNewline;" ^
  "Write-Host ('Done — ' + $files.Count + ' files written to index.html')"

pause
