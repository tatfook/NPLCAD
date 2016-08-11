@echo off 
mkdir npl_packages
cd npl_packages
 git clone https://github.com/NPLPackages/main
 git clone https://github.com/NPLPackages/paracraft

pushd main
git pull 
popd

pushd paracraft
git pull 
popd
