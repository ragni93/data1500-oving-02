@echo off
REM ============================================================
REM Test script for DATA1500 Øving 2 - Webapplikasjoner
REM Kompatibel med: Windows Command Prompt
REM 
REM Bruk: test-local.bat
REM ============================================================

setlocal enabledelayedexpansion

set PASSED=0
set FAILED=0
set ABSOLUTE_PATH=%~dp0
set TESTDATA_DIR=%ABSOLUTE_PATH\testdata

echo.
echo ================================================
echo   DATA1500 Øving 2 - Webapplikasjoner
echo   Local Test Suite (Windows)
echo ================================================
echo.

REM ============================================================
REM OPPGAVE 1: Enkel READ-API
REM ============================================================
echo.
echo --- Oppgave 1: Enkel READ-API ---
if exist "oppgave1" (
    cd oppgave1
    
    echo Compiling StudentAPI.java...
    javac StudentAPI.java 2>nul
    if !ERRORLEVEL! equ 0 (
        echo   Compilation successful
        
        REM Start server in background
        start /B java StudentAPI 9001 %TESTDATA_DIR%\data\studenter.csv >nul 2>&1
        timeout /t 1 /nobreak >nul
        
        REM Test 1: Hent alle studenter
        echo   Testing: GET /api/students...
        for /f %%A in ('curl -s http://localhost:9001/api/students 2^>nul ^| find /c "Mickey"') do (
            if %%A gtr 0 (
                echo     ✓ PASSED
                set /a PASSED+=1
            ) else (
                echo     ✗ FAILED
                set /a FAILED+=1
            )
        )
        
        REM Kill server
        taskkill /FI "WINDOWTITLE eq java*" /T /F >nul 2>&1
        
    ) else (
        echo   Compilation failed
        set /a FAILED+=3
    )
    
    cd ..
) else (
    echo ⚠️  Oppgave 1 directory not found
)

REM ============================================================
REM OPPGAVE 2: API med Søk
REM ============================================================
echo.
echo --- Oppgave 2: API med Søk og SQL Injection-illustrasjon ---
if exist "oppgave2" (
    cd oppgave2
    
    echo Compiling UserSearchAPI.java...
    javac UserSearchAPI.java 2>nul
    if !ERRORLEVEL! equ 0 (
        echo   Compilation successful
        
        REM Start server in background
        start /B java UserSearchAPI 9002 %TESTDATA_DIR%\data\brukere.csv >nul 2>&1
        timeout /t 1 /nobreak >nul
        
        REM Test 1: Hent alle brukere
        echo   Testing: GET /api/users...
        for /f %%A in ('curl -s http://localhost:9002/api/users 2^>nul ^| find /c "bruker1"') do (
            if %%A gtr 0 (
                echo     ✓ PASSED
                set /a PASSED+=1
            ) else (
                echo     ✗ FAILED
                set /a FAILED+=1
            )
        )
        
        REM Kill server
        taskkill /FI "WINDOWTITLE eq java*" /T /F >nul 2>&1
        
    ) else (
        echo   Compilation failed
        set /a FAILED+=2
    )
    
    cd ..
) else (
    echo ⚠️  Oppgave 2 directory not found
)

REM ============================================================
REM OPPGAVE 3: CRUD-API med UPDATE
REM ============================================================
echo.
echo --- Oppgave 3: CRUD-API med UPDATE ---
if exist "oppgave3" (
    cd oppgave3
    
    REM Lag kopi av test-data
    copy %TESTDATA_DIR%\data\studenter.csv test_studenter.csv >nul 2>&1
    
    echo Compiling StudentCRUDAPI.java...
    javac StudentCRUDAPI.java 2>nul
    if !ERRORLEVEL! equ 0 (
        echo   Compilation successful
        
        REM Start server in background
        start /B java StudentCRUDAPI 9003 test_studenter.csv >nul 2>&1
        timeout /t 1 /nobreak >nul
        
        REM Test 1: GET student
        echo   Testing: GET /api/students/101...
        for /f %%A in ('curl -s http://localhost:9003/api/students/101 2^>nul ^| find /c "id"') do (
            if %%A gtr 0 (
                echo     ✓ PASSED
                set /a PASSED+=1
            ) else (
                echo     ✗ FAILED
                set /a FAILED+=1
            )
        )
        
        REM Kill server
        taskkill /FI "WINDOWTITLE eq java*" /T /F >nul 2>&1
        
    ) else (
        echo   Compilation failed
        set /a FAILED+=2
    )
    
    REM Cleanup
    del test_studenter.csv >nul 2>&1
    
    cd ..
) else (
    echo ⚠️  Oppgave 3 directory not found
)

REM ============================================================
REM OPPGAVE 4: CRUD-API med DELETE og Analytics
REM ============================================================
echo.
echo --- Oppgave 4: CRUD-API med DELETE og Analytics ---
if exist "oppgave4" (
    cd oppgave4
    
    REM Lag kopier av test-data
    copy %TESTDATA_DIR%\data\studenter.csv test_studenter.csv >nul 2>&1
    copy %TESTDATA_DIR%\data\quiz-res.csv test_quiz_res.csv >nul 2>&1
    
    echo Compiling QuizAnalyticsAPI.java...
    javac QuizAnalyticsAPI.java 2>nul
    if !ERRORLEVEL! equ 0 (
        echo   Compilation successful
        
        REM Start server in background
        start /B java QuizAnalyticsAPI 9004 test_studenter.csv test_quiz_res.csv >nul 2>&1
        timeout /t 1 /nobreak >nul
        
        REM Test 1: GET quiz stats
        echo   Testing: GET /api/analytics/quiz-stats...
        for /f %%A in ('curl -s http://localhost:9004/api/analytics/quiz-stats 2^>nul ^| find /c "average"') do (
            if %%A gtr 0 (
                echo     ✓ PASSED
                set /a PASSED+=1
            ) else (
                echo     ✗ FAILED
                set /a FAILED+=1
            )
        )
        
        REM Kill server
        taskkill /FI "WINDOWTITLE eq java*" /T /F >nul 2>&1
        
    ) else (
        echo   Compilation failed
        set /a FAILED+=2
    )
    
    REM Cleanup
    del test_studenter.csv >nul 2>&1
    del test_quiz_res.csv >nul 2>&1
    
    cd ..
) else (
    echo ⚠️  Oppgave 4 directory not found
)

REM ============================================================
REM Summary
REM ============================================================
echo.
echo ================================================
echo   Test Summary
echo ================================================
echo Passed: %PASSED%
echo Failed: %FAILED%
echo.

if %FAILED% equ 0 (
    echo 🎉 All tests passed! Your code is ready to submit.
    exit /b 0
) else (
    echo ⚠️  Some tests failed. Please review your code.
    exit /b 1
)
