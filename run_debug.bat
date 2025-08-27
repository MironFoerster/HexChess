@echo off
setlocal

:: Path to your project
set PROJECT="."

:: Start server (headless, in new terminal)
start "Server" godot4console --server --headless --path %PROJECT%

:: Start client (normal, in new terminal)
start "Client" godot4console --path %PROJECT%

endlocal
