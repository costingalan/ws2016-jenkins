# Author: Costin Galan <cgalan@cloudbasesolutions.com>
# License: Apache 2.0
# Description: Script for gathering and executing the jenkins job
# for generating latest windows images.

$baseDir = "C:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$logDir = Join-Path -Path "$buildArea" -ChildPath "logs"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "windows-openstack-imaging-tools"
$scriptDir = Join-Path -Path "$buildArea" -ChildPath "ws2016-jenkins"
$isoDir = Join-Path -Path "$baseDir" -ChildPath "generated_images" 

$logName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER"
$logPath = Join-Path -Path "$logDir" -ChildPath "$logName"
$imageName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-dd'
$targetPath = Join-Path -Path "$isoDir" -ChildPath "$imageName"

Write-Host "START VARIABLES"
$logName
$logPath
$imageNa
$targetPath
$baseDir
$logDirr
$woitDir
$scriptDir
$buildArea
$isoDir
Write-Host "END VARIABLES"
pushd "$buildArea"
if (Test-Path "$woitDir") {
    Remove-Item -Recurse -Force "$woitDir"
}
git clone -b devel https://github.com/costingalan/windows-openstack-imaging-tools 
pushd "$woitDir"
git checkout devel
git submodule update --init #for the curtin and update modules
popd

if (Test-Path "$scriptDir") {
    Remove-Item -Force -Recurse "$scriptDir"
}
git clone https://github.com/costingalan/ws2016-jenkins 
pushd "$scriptDir"
pwd
& generate_script.ps1 | Tee-Object -FilePath "$logPath"
popd

popd
