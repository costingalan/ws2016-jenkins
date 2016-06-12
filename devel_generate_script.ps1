$baseDir = "G:\generate_windows_images"
$buildArea = Join-Path -Path "$baseDir" -ChildPath "build_area"
$logDir = Join-Path -Path "$buildArea" -ChildPath "logs"
$woitDir = Join-Path -Path "$buildArea" -ChildPath "devel-woit-$env:BUILD_NUMBER"
$scriptDir = Join-Path -Path "$buildArea" -ChildPath "devel-ws2016-jenkins-$env:BUILD_NUMBER"
$logName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-devel.txt'
$logPath = Join-Path -Path "$logDir" -ChildPath "$logName"
$imageName = (Get-Date).ToString('ddMMyyy') + '-' + "$env:BUILD_NUMBER" + '-devel-dd'
$isoDir = Join-Path -Path "$baseDir" -ChildPath "generated_images"
$targetPath = Join-Path -Path "$isoDir" -ChildPath "$imageName"
$virtPath = Join-Path -Path "$baseDir" -ChildPath "optional_images\virtio-win-0.1.102.iso"

try {
    if (Get-Module WinImageBuilder) {
        Remove-Module WinImageBuilder
    }
    ls $woitDir
    Import-Module "$woitDir\WinImageBuilder.psm1"

    #This is the content of your Windows ISO
    $driveLetter = (Mount-DiskImage $finalISO -PassThru | Get-Volume).DriveLetter 
    $wimFilePath = "${driveLetter}:\sources\install.wim"

    # Check what images are supported in this Windows ISO
    $images = Get-WimFileImagesInfo -WimFilePath $wimFilePath

    $COMMAND = "New-WindowsOnlineImage -Type $env:imageType -WimFilePath $wimFilePath -ImageName $image.ImageName -WindowsImagePath $targetPath -SizeBytes $sizeBytes -Memory $memory -CpuCores $cpuCores -DiskLayout $env:diskLayout"

    Write-Host "Setting the runSysprep variable..."
    switch -regex ($env:runSysprep)
         {
             "YES|yes" {"$COMMAND += '-RunSysprep:$true'"; break}
             "NO|no"   {"$COMMAND += '-RunSysprep:$false'"; break}
             default   {"$COMMAND += '-RunSysprep:$true'"; break}
         }

    Write-Host "Setting the installUpdates variable..."
    switch -regex ($env:installUpdates)
         {
             "YES|yes" {"$COMMAND += '-InstallUpdates:$true'"; break}
             "NO|no"   {"$COMMAND += '-InstallUpdates:$false'"; break}
             default   {"$COMMAND += '-InstallUpdaites:$true'"; break}
         }


    Write-Host "Setting purgeUpdates variable..."
    switch -regex ($env:purgeUpdates)
         {
             "YES|yes" {"$COMMAND += '-PurgeUpdates:$true'"; break}
             "NO|no"   {"$COMMAND += '-PurgeUpdates:$false'"; break}
             default   {"$COMMAND += '-PurgeUpdates:$true'"; break}
         }

    Write-Host "Setting the persistDrivers variable..."
    switch -regex ($env:persistDrivers)
         {
             "YES|yes" {"$COMMAND += '-PersistDriverInstall:$true'"; break}
             "NO|no"   {"$COMMAND += '-PersistDriversnstall:$false'"; break}
             default   {"$COMMAND += '-PersistDriversnstall:false'"; break}
         }

    Write-Host "Setting the force variable"
    switch -regex ($env:force)
         {
             "YES|yes" {"$COMMAND += '-Force:$true'"; break}
             "NO|no"   {"$COMMAND += '-Force:$false'"; break}
             default   {"$COMMAND += '-Force:$false'"; break}
         }

    #If ([boolean]$purgeUpdates -eq '$true') {
    #    If ([boolean]$installUpdates -eq '$false') {
    #        Write-Warning "You have purgeUpdates set to yes but installUpdates is set to no."
    #        Write-Warning "Will not purge the updates"
    #        [boolean]$purgeUpdates = $false
    #    }
    #}
    #Write-Host "purgeUpdates are set to $purgeUpdates"

    Write-Host "Setting the installHyperv variable..."
    if ($env:installHyperV -eq 'NO') {
        $ExtraFeatures = @()
    }

    Write-Host "Writing all the environment variables"
    Get-ChildItem Env:
    Write-Host "Finished writing all environment variables"

    Write-Host "Writing all the variables"
    Get-Variable | Out-String
    Write-Host "Finished writing all variables"

    Write-Host "Setting sizeBytes..."
    [uint64]$sizeBytes = $env:sizeBytes
    $sizeBytes = $sizeBytes * 1GB 

    Write-Host "Setting memory..."
    [uint64]$memory = $env:memory
    $memory = $memory * 1GB

    Write-Host "Setting CpuCores"
    [uint64]$cpuCores = $env:CpuCores

    Write-Host "Setting the imageType"
    $env:imageType = $env:imageType.ToUpper()

    Write-Host "Starting the image generation..."

    if ($env:virtPath) {
        $COMMAND += " -VirtIOISOPath ${env:virtPath}"
    }
    if ($env:productKey) {
        $COMMAND += " -ProductKey ${env:productKey}"
    }
    if ($env:ExtraDriversPath) {
        $COMMAND += " -ExtraDriversPath ${env:ExtraDriversPath}"
    }
    if ($env:switchName) {
        $COMMAND += " -SwitchName ${env:switchName}"
    }
    $COMMAND
    Invoke-Expression $COMMAND

    Write-Host "Finished the image generation."
} catch {
    Write-Host "Image generation has failed."
    Write-Host $_
} finally {
    Write-Host "Dismounting the iso: $finalISO"
    Dismount-DiskImage $finalISO
}
