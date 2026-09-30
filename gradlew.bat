@echo off
setlocal
set "GRADLE_VERSION=8.8"
set "GRADLE_HOME=%~dp0.gradle-wrapper\gradle-%GRADLE_VERSION%"
set "GRADLE_ZIP=%~dp0.gradle-wrapper\gradle-%GRADLE_VERSION%-bin.zip"
set "GRADLE_URL=https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip"

if not exist "%GRADLE_HOME%\bin\gradle.bat" (
    echo Gradle %GRADLE_VERSION% not found. Downloading...
    if not exist "%~dp0.gradle-wrapper" mkdir "%~dp0.gradle-wrapper"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri '%GRADLE_URL%' -OutFile '%GRADLE_ZIP%'"
    if errorlevel 1 (
        echo Failed to download Gradle.
        exit /b 1
    )
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%GRADLE_ZIP%' -DestinationPath '%~dp0.gradle-wrapper' -Force"
    if errorlevel 1 (
        echo Failed to extract Gradle.
        exit /b 1
    )
)

call "%GRADLE_HOME%\bin\gradle.bat" %*
exit /b %ERRORLEVEL%
