pushd "$woitDir"

if (Get-Module WinImageBuilder) {
    Remove-Module WinImageBuilder
}
Import-Module .\WinImageBuilder.psm1

#This is the content of your Windows ISO
$isoPath = Join-Date -ChildPath $env:isoName -Path $env:folder
$driveLetter = (Mount-DiskImage $isoPath -PassThru | Get-Volume).DriveLetter 
$wimFilePath = "${driveLetter}:\sources\install.wim"

# Check what images are supported in this Windows ISO
$images = Get-WimFileImagesInfo -WimFilePath $wimFilePath

# Choosing the standard edition
$image = $images[1]

New-MaaSImage -WimFilePath $wimFilePath -ImageName $image.ImageName`
-MaaSImagePath $targetPath -SizeBytes 45GB -Memory 8GB `
-CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:$true `
-InstallUpdates:$true -ExtraFeatures:@()
popd
