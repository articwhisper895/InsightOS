@echo off
setlocal EnableExtensions DisableDelayedExpansion
title InsightOS - Publish desktop application to GitHub

rem Safely imports Desktop\insightos-app into the existing InsightOS repository.
rem Uses a temporary clone: the source folder's Git history and remotes are untouched.
set "REPO_URL=https://github.com/articwhisper895/InsightOS.git"
set "REPO_WEB=https://github.com/articwhisper895/InsightOS"
set "SOURCE_DIR=%USERPROFILE%\Desktop\insightos-app"
if not "%~1"=="" set "SOURCE_DIR=%~1"
if not exist "%SOURCE_DIR%\" if "%~1"=="" if exist "%USERPROFILE%\OneDrive\Desktop\insightos-app\" set "SOURCE_DIR=%USERPROFILE%\OneDrive\Desktop\insightos-app"
for %%I in ("%SOURCE_DIR%") do set "SOURCE_DIR=%%~fI"

echo.
echo  ================================================================
echo   InsightOS - Safe GitHub Publisher
echo  ================================================================
echo.
echo  Source : %SOURCE_DIR%
echo  Target : %REPO_WEB%
echo.

if not exist "%SOURCE_DIR%\" (
    echo [ERROR] Source folder not found.
    echo Expected: %SOURCE_DIR%
    echo You may also drag the folder onto this CMD file.
    goto :fail
)
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git for Windows is required: https://git-scm.com/download/win
    goto :fail
)
git --version
git ls-remote --exit-code --heads "%REPO_URL%" main >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Could not reach the repository's main branch.
    goto :fail
)

echo.
echo   1. Create a review branch (recommended)
echo   2. Push directly to main
set "PUBLISH_CHOICE="
set /p "PUBLISH_CHOICE=Choose 1 or 2: "
if not "%PUBLISH_CHOICE%"=="1" if not "%PUBLISH_CHOICE%"=="2" goto :fail

for /f %%T in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss" 2^>nul') do set "STAMP=%%T"
if not defined STAMP set "STAMP=%RANDOM%-%RANDOM%"
if "%PUBLISH_CHOICE%"=="1" (set "TARGET_BRANCH=application-import-%STAMP%") else (set "TARGET_BRANCH=main")
set "STAGE_DIR=%TEMP%\InsightOS-publish-%STAMP%-%RANDOM%"

echo.
echo [1/5] Cloning the current GitHub main branch...
git clone --branch main --single-branch "%REPO_URL%" "%STAGE_DIR%"
if errorlevel 1 goto :fail

if "%PUBLISH_CHOICE%"=="1" (
    pushd "%STAGE_DIR%"
    git switch -c "%TARGET_BRANCH%" origin/main
    if errorlevel 1 (
        popd
        goto :fail
    )
    popd
)

echo.
echo [2/5] Copying application files...
echo Repository documentation and issue templates are preserved.
robocopy "%SOURCE_DIR%" "%STAGE_DIR%" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
    /XD .git .github docs .ssh .aws node_modules .next .nuxt .output dist build out coverage .cache .turbo .vercel .netlify vendor __pycache__ .venv venv playwright-report test-results ^
    /XF README.md CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md .gitignore .editorconfig .gitattributes ^
        .env .env.* .env.local .env.development .env.development.local .env.production .env.production.local .env.test .env.test.local ^
        *.pem *.key *.p12 *.pfx *.log *.sqlite *.sqlite3 *.db id_rsa id_ed25519 credentials.json service-account.json
if errorlevel 8 (
    echo [ERROR] Application copy failed.
    goto :fail
)

rem Keep local application documentation without overwriting repository foundation docs.
if exist "%SOURCE_DIR%\docs\" (
    robocopy "%SOURCE_DIR%\docs" "%STAGE_DIR%\docs\application" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
        /XD .git node_modules .next dist build coverage .cache ^
        /XF .env .env.* .env.local *.pem *.key *.p12 *.pfx *.log *.sqlite *.sqlite3 *.db credentials.json service-account.json
    if errorlevel 8 goto :fail
)

rem Copy app-specific GitHub Actions workflows but preserve repository issue templates.
if exist "%SOURCE_DIR%\.github\workflows\" (
    if not exist "%STAGE_DIR%\.github\workflows\" mkdir "%STAGE_DIR%\.github\workflows"
    robocopy "%SOURCE_DIR%\.github\workflows" "%STAGE_DIR%\.github\workflows" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /XJ /NP /NFL /NDL ^
        /XD node_modules .cache ^
        /XF .env *.pem *.key *.p12 *.pfx *.log credentials.json service-account.json
    if errorlevel 8 goto :fail
)

echo.
echo [3/5] Staging changes...
pushd "%STAGE_DIR%"
git add -A
if errorlevel 1 (
    popd
    goto :fail
)
git diff --cached --quiet
if not errorlevel 1 (
    popd
    echo [INFO] No changes to publish.
    if exist "%STAGE_DIR%\" rmdir /s /q "%STAGE_DIR%"
    goto :finish
)

echo.
echo ---------------- Staged changes ----------------
git status --short
echo.
git diff --cached --stat
echo -------------------------------------------------
echo.
echo SECURITY REVIEW:
echo - Common local environment files, private keys, logs, and databases were excluded.
echo - Check staged filenames and source content for secrets or private data.
echo - The script cannot detect credentials hard-coded inside ordinary source files.
echo.

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
    goto :fail
)
if not defined AUTHOR_EMAIL (
    popd
    goto :fail
)
git config user.name "%AUTHOR_NAME%"
git config user.email "%AUTHOR_EMAIL%"

echo.
echo Destination branch: %TARGET_BRANCH%
set "CONFIRM="
set /p "CONFIRM=Publish these files? Type YES to continue: "
if /I not "%CONFIRM%"=="YES" (
    popd
    echo [CANCELLED] Nothing was pushed.
    if exist "%STAGE_DIR%\" rmdir /s /q "%STAGE_DIR%"
    goto :finish
)

echo.
echo [4/5] Creating commit...
git commit -m "feat: import InsightOS application source"
if errorlevel 1 (
    popd
    goto :fail
)

echo.
echo [5/5] Pushing to GitHub...
git push -u origin "%TARGET_BRANCH%"
if errorlevel 1 (
    popd
    echo [ERROR] Push failed. Sign in through Git Credential Manager and retry.
    goto :fail
)
popd

if "%PUBLISH_CHOICE%"=="1" (
    echo [SUCCESS] Uploaded to branch %TARGET_BRANCH%.
    start "" "%REPO_WEB%/compare/main...%TARGET_BRANCH%?expand=1"
) else (
    echo [SUCCESS] Updated the main branch.
    start "" "%REPO_WEB%"
)
if exist "%STAGE_DIR%\" rmdir /s /q "%STAGE_DIR%"
echo Your original Desktop\insightos-app folder and its Git history were not modified.
goto :finish

:fail
echo.
echo [FAILED] No destructive changes were made to your source folder.
if defined STAGE_DIR if exist "%STAGE_DIR%\" echo Temporary workspace retained: %STAGE_DIR%

:finish
echo.
pause
endlocal
