Remove-Module WinImageBuilder.psm1
Import-Module .\WinImageBuilder.psm1

#This is the content of your Windows ISO
$wimFilePath = "D:\sources\install.wim"

# Check what images are supported in this Windows ISO
$images = Get-WimFileImagesInfo -WimFilePath $wimFilePath

$MaaSImagePath = "$buildArea\"

# Choosing the standard edition
$image = $images[1]

New-MaaSImage -WimFilePath $wimFilePath -ImageName $image.ImageName`
-MaaSImagePath C:\images\win2012hvr2-dd -SizeBytes 16GB -Memory 4GB `
-CpuCores 2 -DiskLayout BIOS -RunSysprep
