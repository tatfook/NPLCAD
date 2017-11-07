@echo off 
if exist "%~dp0../../redist/ParaEngineClient.exe" (
pushd "%~dp0../../redist/" 
) else (
pushd "%~dp0../../" 
)
call "ParaEngineClient.exe" single="false" mc="true" noupdate="true" dev="%~dp0" mod="NPLCAD" isDevEnv="true" world="worlds/DesignHouse/test"
popd 
