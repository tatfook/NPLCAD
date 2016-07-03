@echo off 
mkdir npl_packages
cd npl_packages
rem git clone https://github.com/NPLPackages/main
rem git clone https://github.com/NPLPackages/paracraft

pushd main
git pull 
popd

pushd paracraft
git pull 
popd
