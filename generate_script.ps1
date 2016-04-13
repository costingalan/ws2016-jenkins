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

$Params = @() #in this array we will add our parameters
$Function = @('New-WindowsOnlineImage -Type') #this will be the switch where we choose which type of image we generate
 
# Choosing to install the Microsoft-Hyper-V role
if ($env:installHyperV -eq 'NO') {
    $ExtraFeatures = @()
}

# Choosing the type of image
if ($env:imageEdition -eq 'CORE') {
    $image = $images[0]
} else {
    $image = $images[1]
}

if ($env:installVirtIODrivers -eq 'YES') {
    $Params += '-VirtIOISOPath $virtPath'
}

if ($env:installUpdates -eq 'YES') {
    $Params += '-InstallUpdates:$true'
}

if ($env:purgeUpdates -eq 'YES') {
    if ($env:installUpdates -eq 'YES') {
        $Params += '-PurgeUpdates:$true'
    } else {
        Write-Warning "You have added purgeUpdates to yes but installUpdates is no."
        Write-Warning "Will not purge the updates"
    }
}

if ($env:persistDriver -eq 'YES') {
    $PersistDriverInstall = $true
}

If ($env:imageType -eq 'MAAS') {
    $Function += '"MAAS"'
} Elseif ($env:imageType -eq 'KVM') {
      $Function += '"KVM"'
  } Elseif ($env:imageType -eq 'Hyper-V') {
        $Function += '"HYPER-V"'
    }
$finalFunction = $Function -join ' '
$finalParams = $Params -join ' '

try {
    $finalParams
    Write-Host "Starting the image generation..."
    $finalFunction -WimFilePath $wimFilePath -ImageName $image.ImageName`
    -MaaSImagePath $targetPath -SizeBytes 45GB -Memory 8GB `
    -CpuCores 4 -DiskLayout BIOS -RunSysprep -PurgeUpdates:$true `
    -InstallUpdates:$true $finalParams
    popd
    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    pushd "$baseDir" 
    Dismount-DiskImage $isoPath
}
