@echo off
setlocal EnableExtensions DisableDelayedExpansion
title InsightOS - GitHub Publisher

rem Exact project identifiers: repository InsightOS; local folder InsightOS-App.
set "REPO_URL=https://github.com/articwhisper895/InsightOS.git"
set "REPO_WEB=https://github.com/articwhisper895/InsightOS"
set "LOG_FILE=%TEMP%\InsightOS-publish.log"
set "FAILED=0"
set "STAGE_DIR="

>"%LOG_FILE%" echo InsightOS Publisher - %DATE% %TIME%
>>"%LOG_FILE%" echo Repository: %REPO_URL%

echo.
echo  ================================================================
echo   INSIGHTOS - WINDOWS GITHUB PUBLISHER
echo  ================================================================
echo.
echo  Exact GitHub repository: articwhisper895/InsightOS
echo  Exact desktop folder:   InsightOS-App
echo  Diagnostic log:         %LOG_FILE%
echo.

set "SOURCE_DIR="
if not "%~1"=="" set "SOURCE_DIR=%~1"

if defined SOURCE_DIR goto :source_selected

echo [1/6] Locating the exact Desktop folder name...
for /f "usebackq delims=" %%I in (\`powershell -NoProfile -ExecutionPolicy Bypass -Command "$roots = @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:USERPROFILE 'Desktop'), (Join-Path $env:USERPROFILE 'OneDrive\Desktop')); foreach ($root in $roots) { if (Test-Path -LiteralPath $root -PathType Container) { $candidate = Join-Path $root 'InsightOS-App'; if (Test-Path -LiteralPath $candidate -PathType Container) { $item = Get-Item -LiteralPath $candidate; if ($item.Name -ceq 'InsightOS-App') { $item.FullName; exit } } } }; 'NOT_FOUND'"\`) do set "SOURCE_DIR=%%I"
if /i "%SOURCE_DIR%"=="NOT_FOUND" (
    echo [ERROR] Exact folder name not found.
    echo Expected: Desktop\InsightOS-App
    echo Capitalization matters: use exactly InsightOS-App, all lowercase.
    >>"%LOG_FILE%" echo ERROR: Exact Desktop folder Desktop\InsightOS-App not found.
    set "SOURCE_DIR="
    goto :fail
)

:source_selected

for %%I in ("%SOURCE_DIR%") do (
    set "SOURCE_NAME=%%~nxI"
    set "SOURCE_DIR=%%~fI"
)
if not "%SOURCE_NAME%"=="InsightOS-App" (
    echo [ERROR] Folder-name capitalization does not match.
    echo Found:    %SOURCE_NAME%
    echo Required: InsightOS-App
    >>"%LOG_FILE%" echo ERROR: Folder case mismatch. Found "%SOURCE_NAME%"; expected "InsightOS-App".
    goto :fail
)
if not exist "%SOURCE_DIR%\" (
    echo [ERROR] Folder does not exist: %SOURCE_DIR%
    >>"%LOG_FILE%" echo ERROR: Source path missing: %SOURCE_DIR%
    goto :fail
)
echo Source folder: %SOURCE_DIR%
echo Source folder: %SOURCE_DIR%>>"%LOG_FILE%"

where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git for Windows is not installed or not on PATH.
    echo Install it from https://git-scm.com/download/win and reopen this CMD.
    >>"%LOG_FILE%" echo ERROR: git executable not found on PATH.
    goto :fail
)
git --version
git --version >>"%LOG_FILE%" 2>&1

echo.
echo [2/6] Checking the exact GitHub repository and main branch...
git ls-remote --exit-code --heads "%REPO_URL%" refs/heads/main >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot access articwhisper895/InsightOS main.
    echo Check internet access and GitHub sign-in, then run this CMD again.
    goto :fail
)

echo.
echo Select where to publish:
echo   1. Review branch (recommended - opens a pull request comparison)
echo   2. Directly to main
set "PUBLISH_CHOICE="
set /p "PUBLISH_CHOICE=Type 1 or 2, then press Enter: "
if not "%PUBLISH_CHOICE%"=="1" if not "%PUBLISH_CHOICE%"=="2" (
    echo [ERROR] Choose exactly 1 or 2.
    goto :fail
)

for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss" 2^>nul') do set "STAMP=%%T"
if not defined STAMP set "STAMP=%RANDOM%-%RANDOM%"
if "%PUBLISH_CHOICE%"=="1" (set "TARGET_BRANCH=application-import-%STAMP%") else (set "TARGET_BRANCH=main")
set "STAGE_DIR=%TEMP%\InsightOS-publish-%STAMP%-%RANDOM%"
echo Target branch: %TARGET_BRANCH%
>>"%LOG_FILE%" echo Target branch: %TARGET_BRANCH%

echo.
echo [3/6] Cloning the current repository into a temporary workspace...
git clone --branch main --single-branch "%REPO_URL%" "%STAGE_DIR%" >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    echo [ERROR] Git clone failed. The diagnostic log contains the Git output.
    goto :fail
)

if "%PUBLISH_CHOICE%"=="1" (
    pushd "%STAGE_DIR%"
    git switch -c "%TARGET_BRANCH%" origin/main >>"%LOG_FILE%" 2>&1
    if errorlevel 1 (
        popd
        echo [ERROR] Could not create the review branch.
        goto :fail
    )
    popd
)

echo.
echo [4/6] Copying app files while preserving repository documentation...
>>"%LOG_FILE%" echo Copying source files from %SOURCE_DIR%
robocopy "%SOURCE_DIR%" "%STAGE_DIR%" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
    /XD .git .github docs .ssh .aws .wrangler .freebuff node_modules .next .nuxt .output dist build out coverage .cache .turbo .vercel .netlify vendor __pycache__ .venv venv playwright-report test-results ^
    /XF README.md CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md .gitignore .editorconfig .gitattributes ^
        .env .env.* .dev.vars .env.local .env.development .env.development.local .env.production .env.production.local .env.test .env.test.local ^
        *.pem *.key *.p12 *.pfx *.log *.sqlite *.sqlite3 *.db id_rsa id_ed25519 credentials.json service-account.json >>"%LOG_FILE%" 2>&1
if errorlevel 8 (
    echo [ERROR] Copying the application failed. See the log.
    goto :fail
)

rem Keep app documentation separate from the repository's root documentation.
if exist "%SOURCE_DIR%\docs\" (
    robocopy "%SOURCE_DIR%\docs" "%STAGE_DIR%\docs\application" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
        /XD .git node_modules .next dist build coverage .cache ^
        /XF .env .env.* .dev.vars *.pem *.key *.p12 *.pfx *.log *.sqlite *.sqlite3 *.db credentials.json service-account.json >>"%LOG_FILE%" 2>&1
    if errorlevel 8 goto :copyfail
)

rem Preserve the existing issue templates; copy only application workflows.
if exist "%SOURCE_DIR%\.github\workflows\" (
    if not exist "%STAGE_DIR%\.github\workflows\" mkdir "%STAGE_DIR%\.github\workflows"
    robocopy "%SOURCE_DIR%\.github\workflows" "%STAGE_DIR%\.github\workflows" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
        /XD node_modules .cache ^
        /XF .env .env.* .dev.vars *.pem *.key *.p12 *.pfx *.log credentials.json service-account.json >>"%LOG_FILE%" 2>&1
    if errorlevel 8 goto :copyfail
)

echo.
echo [5/6] Preparing and displaying the changes...
pushd "%STAGE_DIR%"
git add -A >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    popd
    echo [ERROR] git add failed.
    goto :fail
)
git diff --cached --quiet
if not errorlevel 1 (
    popd
    echo [INFO] No new changes were found. Nothing needed to be pushed.
    >>"%LOG_FILE%" echo INFO: No staged changes.
    rmdir /s /q "%STAGE_DIR%"
    goto :success
)
echo.
echo ---------------- STAGED FILES ----------------
git status --short
echo.
git diff --cached --stat
git status --short >>"%LOG_FILE%" 2>&1
git diff --cached --stat >>"%LOG_FILE%" 2>&1
echo ------------------------------------------------
echo.
echo SECURITY CHECK: inspect the staged files for API keys, passwords,
echo private data, or assets you do not have permission to publish.
echo Common .env files, private keys, local databases, and logs are excluded.
echo The script cannot detect secrets hard-coded inside source files.

set "AUTHOR_NAME="
set "AUTHOR_EMAIL="
for /f "delims=" %%A in ('git -C "%SOURCE_DIR%" config user.name 2^>nul') do set "AUTHOR_NAME=%%A"
for /f "delims=" %%A in ('git -C "%SOURCE_DIR%" config user.email 2^>nul') do set "AUTHOR_EMAIL=%%A"
if not defined AUTHOR_NAME for /f "delims=" %%A in ('git config --global user.name 2^>nul') do set "AUTHOR_NAME=%%A"
if not defined AUTHOR_EMAIL for /f "delims=" %%A in ('git config --global user.email 2^>nul') do set "AUTHOR_EMAIL=%%A"
if not defined AUTHOR_NAME set /p "AUTHOR_NAME=Git commit author name: "
if not defined AUTHOR_EMAIL set /p "AUTHOR_EMAIL=Git commit author email: "
if not defined AUTHOR_NAME (
    popd
    echo [ERROR] Git author name is required.
    goto :fail
)
if not defined AUTHOR_EMAIL (
    popd
    echo [ERROR] Git author email is required.
    goto :fail
)
git config user.name "%AUTHOR_NAME%"
git config user.email "%AUTHOR_EMAIL%"

echo.
echo Exact destination: articwhisper895/InsightOS - %TARGET_BRANCH%
set "CONFIRM="
set /p "CONFIRM=Type YES in capital letters to publish: "
if not "%CONFIRM%"=="YES" (
    popd
    echo [CANCELLED] Nothing was pushed.
    rmdir /s /q "%STAGE_DIR%"
    goto :success
)

echo.
echo [6/6] Committing and pushing to GitHub...
git commit -m "feat: import InsightOS application source" >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    popd
    echo [ERROR] Git commit failed. See the diagnostic log.
    goto :fail
)
git push -u origin "%TARGET_BRANCH%" >>"%LOG_FILE%" 2>&1
if errorlevel 1 (
    popd
    echo [ERROR] Git push failed. Check GitHub authentication and branch permissions.
    goto :fail
)
popd
if "%PUBLISH_CHOICE%"=="1" (
    echo [SUCCESS] App uploaded to review branch: %TARGET_BRANCH%
    start "" "%REPO_WEB%/compare/main...%TARGET_BRANCH%?expand=1"
) else (
    echo [SUCCESS] App uploaded directly to main.
    start "" "%REPO_WEB%"
)
rmdir /s /q "%STAGE_DIR%"
goto :success

:copyfail
echo [ERROR] A copy operation failed. See the diagnostic log.
goto :fail

:fail
echo.
echo [FAILED] The publisher stopped. Your original application folder was not modified.
echo Diagnostic log: %LOG_FILE%
>>"%LOG_FILE%" echo Publisher stopped with an error.
if exist "%LOG_FILE%" (
    echo.
    echo ---------------- DIAGNOSTIC LOG ----------------
    type "%LOG_FILE%"
    echo -------------------------------------------------
)
set "FAILED=1"
goto :end

:success
echo.
echo [DONE] Publisher finished.
echo Diagnostic log: %LOG_FILE%
goto :end

:end
echo.
pause
exit /b %FAILED%
