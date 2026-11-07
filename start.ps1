$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Test-Path '.venv\Scripts\python.exe')) { throw 'Virtual environment missing. Run .\setup.ps1 first.' }
& .\.venv\Scripts\python.exe -m uvicorn app:app --host 127.0.0.1 --port 8080
