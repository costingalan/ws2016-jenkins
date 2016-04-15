$baseDir = "C:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "woit-$env:BUILD_NUMBER"
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
    $Params = @() #in this array we will add our parameters

    # Choosing to install the Microsoft-Hyper-V role
    If ($env:installHyperV -eq 'NO') {
        $ExtraFeatures = @()
    }
    Write-Host "Choosing the imageEdition"
    # Choosing the type of image
    If ($env:imageEdition -eq 'CORE') {
        $image = $images[0]
    } else {
        $image = $images[1]
    }

    If ($env:installVirtIODrivers -eq 'YES') {
        $Params += '-VirtIOISOPath $virtPath'
    }

    If ($env:purgeUpdates -eq '$true') {
        If ($env:installUpdates -eq '$false') {
            Write-Warning "You have purgeUpdates set to yes but installUpdates is set to no."
            Write-Warning "Will not purge the updates"
            $env:purgeUpdates = $false
        }
    }

    $finalParams = $Params -join ' '

    $finalParams

    Write-Host "Starting the image generation..."
    #New-WindowsOnlineImage -Type $env:imageType -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes 45GB -Memory 8GB -CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:$true -InstallUpdates:$true $finalParams
    New-WindowsOnlineImage -Type $env:imageType -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes $env:sizeBytes -Memory $env:memory -CpuCores $env:cpuCores -DiskLayout $env:diskLayout -RunSysprep:$env:runSysprep -PurgeUpdates:$env:purgeUpdates -InstallUpdates:$env:installUpdates -Force:$env:force -PersistDriverInstall:$env:persistDriver -SwitchName $env:switchName -VirtIOISOPath $env:virtPath -ProductKey $env:productKey

    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    Dismount-DiskImage $isoPath
}
