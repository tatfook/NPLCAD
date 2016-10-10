@echo off 
if not exist "npl_packages" ( mkdir npl_packages )

pushd "npl_packages"

CALL :InstallPackage NplCadLibrary
<<<<<<< HEAD
=======
CALL :InstallPackage main
CALL :InstallPackage paracraft

>>>>>>> 128fa86db32da86415ab92b5a1b50a53c40b8a50
popd

EXIT /B %ERRORLEVEL%

rem install function here
:InstallPackage
if exist "%1\README.md" (
    pushd %1
    git pull
    popd
) else (
    rmdir /s /q "%CD%\%1"
    git clone https://github.com/NPLPackages/%1
)
EXIT /B 0