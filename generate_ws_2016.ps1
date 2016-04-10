# Author: Costin Galan <cgalan@cloudbasesolutions.com>
# License: Apache 2.0
# Description: Script for gathering and executing the jenkins job
# for generating latest windows images.

$buildArea="C:\generate_windows_images\build_area"


pushd "$buildArea"
if (Test-Path "windows-openstack-imaging-tools") {
    Remove-Item -Recurse -Force "windows-openstack-imaging-tools"
}
git clone -b devel https://github.com/costingalan/windows-openstack-imaging-tools .
pushd "windows-openstack-imaging-tools"
git checkout devel
git submodule update --init
popd
popd
