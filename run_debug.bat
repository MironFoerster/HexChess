@echo off
setlocal

:: Path to your project
set PROJECT="."

:: Number of clients (default 1)
set NCLIENTS=1

:: Check if --n-clients argument was passed
for %%A in (%*) do (
    if "%%~A"=="--n-clients" (
        set NEXT_IS_N=1
    ) else if defined NEXT_IS_N (
        set NCLIENTS=%%~A
        set NEXT_IS_N=
    )
)

:: Start server (headless, in new terminal)
start "Server" godot4console --server --headless --path %PROJECT%

:: Start clients
set /a COUNTER=1
:client_loop
if %COUNTER% leq %NCLIENTS% (
    start "Client %COUNTER%" godot4console --path %PROJECT%
    set /a COUNTER+=1
    goto client_loop
)

endlocal
