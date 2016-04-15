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
    If (Get-Module WinImageBuilder) {
        Remove-Module WinImageBuilder
    }
    Import-Module "$woitDir\WinImageBuilder.psm1"

    #This is the content of your Windows ISO
    $driveLetter = (Mount-DiskImage $env:isoPath -PassThru | Get-Volume).DriveLetter 
    $wimFilePath = "${driveLetter}:\sources\install.wim"

    # Check what images are supported in this Windows ISO
    $images = Get-WimFileImagesInfo -WimFilePath $wimFilePath

    Write-Host "Choosing the imageEdition"
    # Choosing the type of image
    If ($env:imageEdition -eq 'CORE') {
        $image = $images[0]
    } else {
        $image = $images[1]
    }

    If ($env:runSysprep -eq 'YES') {
        [boolean]$env:runSysprep = 1
    } else {
        [boolean]$env:runSysprep = 0
    }

    If ($env:installUpdates -eq 'YES') {
        [boolean]$env:installUpdates = 1
    } else {
        [boolean]$env:installUpdates = 0
    }

    If ($env:purgeUpdates -eq 'YES') {
        [boolean]$env:purgeUpdates = 1
    } else {
        [boolean]$env:purgeUpdates = 0
    }

    If ($env:persistDrivers -eq 'YES') {
        [boolean]$env:persistDrivers = 1
    } else {
        [boolean]$env:persistDrivers = 0
    }

    If ($env:force -eq 'YES') {
        [boolean]$env:force = 1
    } else {
        [boolean]$env:force = 0
    }

    If ($env:purgeUpdates -eq '1') {
        If ([boolean]$env:installUpdates -eq '0') {
            Write-Warning "You have purgeUpdates set to yes but installUpdates is set to no."
            Write-Warning "Will not purge the updates"
            [boolean]$env:purgeUpdates = 0
        }
    }
    
    If ($env:installHyperV -eq 'NO') {
        $ExtraFeatures = @()
    }

    Write-Host "Writing all the environment variables"
    Get-ChildItem Env:
    Write-Host "Finished writing all environment variables"

    Write-Host "Starting the image generation..."
    #New-WindowsOnlineImage -Type $env:imageType -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes 45GB -Memory 8GB -CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:1 -InstallUpdates:1 $finalParams
    New-WindowsOnlineImage -Type $env:imageType -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes $env:sizeBytes -Memory $env:memory -CpuCores $env:cpuCores -DiskLayout $env:diskLayout -RunSysprep:$env:runSysprep -PurgeUpdates:$env:purgeUpdates -InstallUpdates:$env:installUpdates -Force:$env:force -PersistDriverInstall:$env:persistDriver -SwitchName $env:switchName -VirtIOISOPath $env:virtPath -ProductKey $env:productKey

    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    Dismount-DiskImage $isoPath
}
