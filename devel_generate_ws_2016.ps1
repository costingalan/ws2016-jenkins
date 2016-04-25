# Author: Costin Galan <cgalan@cloudbasesolutions.com>
# License: Apache 2.0
# Description: Script for gathering and executing the jenkins job
# for generating latest windows images.

$baseDir = "C:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$logDir = Join-Path -Path "$buildArea" -ChildPath "logs"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "devel-woit-$env:BUILD_NUMBER"
$scriptDir = Join-Path -Path "$buildArea" -ChildPath "devel-ws2016-jenkins-$env:BUILD_NUMBER"
$logName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-devel' + '.txt'
$logPath = Join-Path -Path "$logDir" -ChildPath "$logName"
$imageName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-devel-dd'
$isoDir = Join-Path -Path "$baseDir" -ChildPath "generated_images"
$targetPath = Join-Path -Path "$isoDir" -ChildPath "$imageName"
$virtPath = Join-Path -Path "$baseDir" -ChildPath "optional_images\virtio-win-0.1.102.iso"
try {

    If ((!$env:remoteISOName) -and (!$env:localISO)) {
        Write-Warning "No remote or local ISO specified. Exiting..."
        exit 1
    }

    If (($env:remoteISOName) -and ($env:localISO)) {
        Write-Warning "Both remote and local ISO specified. Exiting..."
        exit 1
    }

    If ($env:remoteISOName) {
        $remoteISO = $env:remoteISODir + '/' + $env:remoteISOName
        pushd $build_area
        $remoteISO
        scp -o 'StrictHostKeyChecking no' $remoteISO ($env:BUILD_NUMBER + '-' + $env:remoteISOName)
        $finalISO = Join-Path -Path $buildArea -ChildPath ($env:BUILD_NUMBER + '-' + $env:remoteISOName)
        $finalISO
        popd
    }

    If ($env:localISO) {
        $finalISO = $env:localISO
    }

    pushd "$buildArea"
    if (Test-Path "$woitDir") {
        Remove-Item -Recurse -Force "$woitDir"
    }
    git clone -b devel_jenkins https://github.com/costingalan/windows-openstack-imaging-tools "devel-woit-$env:BUILD_NUMBER" 
    pushd "$woitDir"
    git checkout devel_jenkins
    git submodule update --init #for the curtin and update modules
    popd
    ls
    if (Test-Path "$scriptDir") {
        Write-Host "Removing $scriptDir"
        Remove-Item -Force -Recurse "$scriptDir"
    }
    git clone https://github.com/costingalan/ws2016-jenkins "devel-ws2016-jenkins-$env:BUILD_NUMBER"
    pushd "$scriptDir"
    .\devel_generate_script.ps1 | Tee-Object -FilePath "$logPath"
    popd

    popd
} catch {
    Write-Host "Pre-Image failed"
    Write-Host $_
} finally {
    Write-Host "Cleaning up woitDir and scriptDir"
    cd "C:\"
    Start-Sleep -s 10
    Remove-Item -Recurse -Force $woitDir
    If ((!$env:localISO) -and (Test-Path $finalISO)) { Remove-Item -Force "$finalISO" }

}
