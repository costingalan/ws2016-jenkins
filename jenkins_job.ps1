Set-PSDebug -Trace 1
pushd "C:\generate_windows_images\build_area"
if (Test-Path "generate_ws_2016.ps1") {
        Remove-Item "generate_ws_2016.ps1"
}
wget https://raw.githubusercontent.com/costingalan/ws2016-jenkins/master/generate_ws_2016.ps1 -OutFile generate_ws_2016.ps1
.\generate_ws_2016.ps1
popd
