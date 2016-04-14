$baseDir = "C:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "woit-$env:BUILD_NUMBER"
try {
    pushd "$woitDir"
    
    If (Get-Module WinImageBuilder) {
        Remove-Module WinImageBuilder
    }
    Import-Module .\WinImageBuilder.psm1
    Write-Host "Imported Module"
    #This is the content of your Windows ISO
    $driveLetter = (Mount-DiskImage $isoPath -PassThru | Get-Volume).DriveLetter 
    $wimFilePath = "${driveLetter}:\sources\install.wim"
    Write-Host "Mounted iso"
    # Check what images are supported in this Windows ISO
    $images = Get-WimFileImagesInfo -WimFilePath $wimFilePath
    Write-Host "Get-WimFileImage"
    $Params = @() #in this array we will add our parameters
    $Function = @(New-WindowsOnlineImage ) #this will be the switch where we choose which type of image we generate
     
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
    Write-Host "Showing the params"
    $Params
    If ($env:installUpdates -eq 'YES') {
        $Params += '-InstallUpdates:$true'
    }
    
    If ($env:purgeUpdates -eq 'YES') {
        If ($env:installUpdates -eq 'YES') {
            $Params += '-PurgeUpdates:$true'
        } else {
            Write-Warning "You have added purgeUpdates to yes but installUpdates is no."
            Write-Warning "Will not purge the updates"
        }
    }
    
    If ($env:persistDriver -eq 'YES') {
        $PersistDriverInstall = $true
    }
    
    If ($env:imageType -eq 'MAAS') {
        $Function += '-Type "MAAS"'
    } Elseif ($env:imageType -eq 'KVM') {
          $Function += '-Type "KVM"'
      } Elseif ($env:imageType -eq 'Hyper-V') {
            $Function += '-Type "HYPER-V"'
        }
    $finalFunction = $Function -join ' '
    $finalParams = $Params -join ' '
    
    $finalFunction
    $finalParams

    Write-Host "Starting the image generation..."
    $finalFunction += "-WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes 45GB -Memory 8GB -CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:$true -InstallUpdates:$true $finalParams" 
    & $finalFunction
    popd
    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    pushd "$baseDir" 
    Dismount-DiskImage $isoPath
}
