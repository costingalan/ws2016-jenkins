pushd "$woitDir"

if (Get-Module WinImageBuilder) {
    Remove-Module WinImageBuilder
}
Import-Module .\WinImageBuilder.psm1

#This is the content of your Windows ISO
$driveLetter = (Mount-DiskImage $isoPath -PassThru | Get-Volume).DriveLetter 
$wimFilePath = "${driveLetter}:\sources\install.wim"

# Check what images are supported in this Windows ISO
$images = Get-WimFileImagesInfo -WimFilePath $wimFilePath

# Choosing the standard edition
$image = $images[1]
try {
    Write-Host "Starting the image generation..."
    New-MaaSImage -WimFilePath $wimFilePath -ImageName $image.ImageName`
    -MaaSImagePath $targetPath -SizeBytes 45GB -Memory 8GB `
    -CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:$true `
    -InstallUpdates:$true 
    popd
    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally { 
    Dismount-DiskImage $isoPath
}
