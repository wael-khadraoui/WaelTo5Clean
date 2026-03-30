@echo off
setlocal
cd /d "%~dp0\.."

if not exist "docker\.env" (
  echo Creating docker\.env from docker\.env.example ...
  copy /Y "docker\.env.example" "docker\.env"
  echo Edit docker\.env if you need to change passwords or secrets.
  echo.
)

echo Starting stack (Postgres + API + web on http://localhost:8080, Adminer on http://localhost:5050^) ...
docker compose -f docker/docker-compose.yml --env-file docker/.env up --build -d

if errorlevel 1 (
  echo.
  echo Docker command failed. Is Docker Desktop running?
  pause
  exit /b 1
)

echo.
echo Done. Open http://localhost:8080  ^|  Adminer: http://localhost:5050
echo To stop: docker compose -f docker/docker-compose.yml --env-file docker/.env down
pause
