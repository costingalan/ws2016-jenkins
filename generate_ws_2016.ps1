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
$isoPath = Join-Path -ChildPath "$env:isoName" -Path "$env:folder"
$logName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '.txt'
$logPath = Join-Path -Path "$logDir" -ChildPath "$logName"
$imageName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-dd'
$targetPath = Join-Path -Path "$isoDir" -ChildPath "$imageName"
$virtPath = Join-Path -Path "$baseDir" -ChildPath "optional_images\virtio-win-0.1.102.iso"

pushd "$buildArea"
if (Test-Path "$woitDir") {
    Remove-Item -Recurse -Force "$woitDir"
}
git clone -b devel_jenkins https://github.com/costingalan/windows-openstack-imaging-tools 
ls
pushd "$woitDir"
git checkout devel_jenkins
git submodule update --init #for the curtin and update modules
popd

if (Test-Path "$scriptDir") {
    Remove-Item -Force -Recurse "$scriptDir"
}
git clone https://github.com/costingalan/ws2016-jenkins 
pushd "$scriptDir"
.\generate_script.ps1 | Tee-Object -FilePath "$logPath"
popd

popd
