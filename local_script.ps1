try {
    If (Get-Module WinImageBuilder) {
        Remove-Module WinImageBuilder
    }
    Import-Module WinImageBuilder.psm1

    #This is the content of your Windows ISO
    $driveLetter = (Mount-DiskImage $ISO -PassThru | Get-Volume).DriveLetter 
    $wimFilePath = "${driveLetter}:\sources\install.wim"

    $virtISOPath = 
    # Check what images are supported in this Windows ISO
    $images = Get-WimFileImagesInfo -WimFilePath $wimFilePath
    $image = $images[1]

    New-WindowsOnlineImage -Type KVM -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath `
    -SizeBytes 45GB -Memory 4GB -CpuCores 2 -DiskLayout BIOS -RunSysprep:$true -PurgeUpdates:$true `
    -InstallUpdates:$true -VirtIOISOPath $virtISOPath

    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    Write-Host "Dismounting the iso: $ISO"
    Dismount-DiskImage $ISO
}
