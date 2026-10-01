@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion

:: Явно задаем базовую директорию
set "BASE_DIR=C:\works\git-repos"

echo ===================================================
echo [СТАРТ] Базовая директория: "%BASE_DIR%"
echo ===================================================

:: Список корневых папок репозиториев
set "repos=ts4-targets skf-ha skf-alarms skf-devs skf-legacy skf-general skt-vetrol skt-sitrol mcc vetrol-ci cp-gbh cp-gwp cp-mmk cp-val cp-vetrol-bkn cp-sitrol-nm cp-vetrol-si cp-vetrol-vdm"

:: Перебираем каждый репозиторий
for %%R in (%repos%) do (
    set "REPO_PATH=%BASE_DIR%\%%R"
    
    if exist "!REPO_PATH!" (
        echo.
        echo Сканирование репозитория: "!REPO_PATH!"
        
        :: Заходим в корень репозитория
        cd /d "!REPO_PATH!"
        
        :: Рекурсивно ищем все папки в этом репозитории
        for /f "delims=" %%D in ('dir /b /s /ad 2^>nul') do (
            set "folder_name=%%~nxD"
            
            set "is_target="
            if /i "!folder_name!"=="lib" set "is_target=1"
            if /i "!folder_name!"=="plugins" set "is_target=1"
            if /i "!folder_name!"=="deploy" set "is_target=1"
            if /i "!folder_name!"=="deploy-local" set "is_target=1"
            if /i "!folder_name!"=="rap" set "is_target=1"
            if /i "!folder_name!"=="rcp" set "is_target=1"
            
            if defined is_target (
                :: Получаем путь к найденной папке относительно корня репозитория
                set "full_path=%%D"
                set "rel_path=!full_path:%BASE_DIR%\%%R\=!"
                
                :: Заменяем обратные слэши \ на прямые / для Git
                set "git_path=!rel_path:\=/!"
                
                echo   -[НАЙДЕНО]: !git_path!
                
                :: 1. Удаляем .jar файлы физически, если они там есть
                if exist "%%D\*.jar" (
                    del /q "%%D\*.jar" 2>nul
                )
                
                :: 2. Восстанавливаем файлы через git
                git restore --source=HEAD "!git_path!" 2>nul
                
                :: 3. Вычищаем новые/лишние файлы
                git clean -fd "!git_path!" 2>nul
            )
        )
    )
)

echo.
echo ===================================================
echo [ГОТОВО] Все операции завершены успешно.
echo ===================================================
pause
