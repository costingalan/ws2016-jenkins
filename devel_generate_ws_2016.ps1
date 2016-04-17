# Author: Costin Galan <cgalan@cloudbasesolutions.com>
# License: Apache 2.0
# Description: Script for gathering and executing the jenkins job
# for generating latest windows images.

$baseDir = "C:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$logDir = Join-Path -Path "$buildArea" -ChildPath "logs"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "woit-$env:BUILD_NUMBER"
$scriptDir = Join-Path -Path "$buildArea" -ChildPath "ws2016-jenkins-$env:BUILD_NUMBER"
$logName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '.txt'
$logPath = Join-Path -Path "$logDir" -ChildPath "$logName"
$imageName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-dd'
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
        scp $remoteISO .
        $finalISO = Join-Path -Path $buildArea -ChildPath $env:remoteISOName
        $finalISO
        popd
    }

    If ($env:localISO) {
        $finalISO = $env:localISO
    }

    Write-Host "Printing the parameters"
    Write-Host "Printing the remoteiso: $remoteISO"
    Write-Host "Printing the remoteisoName $env:remoteISOName"
    Write-Host "Printing the remoteisoDir $env:remoteISODir"
    Write-Host "Printing the localIso $env:localISO "
    Write-Host "Printing the finalIso $finalISO "
    Write-Host "Finished showing the parameters"

    pushd "$buildArea"
    if (Test-Path "$woitDir") {
        Remove-Item -Recurse -Force "$woitDir"
    }
    git clone -b devel_jenkins https://github.com/costingalan/windows-openstack-imaging-tools "woit-$env:BUILD_NUMBER" 
    pushd "$woitDir"
    git checkout devel_jenkins
    git submodule update --init #for the curtin and update modules
    popd
    ls
    if (Test-Path "$scriptDir") {
        Write-Host "Removing $scriptDir"
        Remove-Item -Force -Recurse "$scriptDir"
    }
    git clone https://github.com/costingalan/ws2016-jenkins "ws2016-jenkins-$env:BUILD_NUMBER"
    pushd "$scriptDir"
    .\generate_script.ps1 | Tee-Object -FilePath "$logPath"
    popd

    popd
} catch {
    Write-Host "Pre-Image failed"
    Write-Host $_
} finally {
    Write-Host "Cleaning up woitDir and scriptDir"
   # cd "C:\"
   # Remove-Item -Recurse -Force $woitDir
   # Remove-Item -Recurse -Force $scriptDir
}
