# Moodle on Windows Vagrant box

A layer on top of my
[Vagrant Windows box factory](https://github.com/LukeCarrier/vagrant-windows)
for Moodle-specific images. Note that this is not a base box.

* * *

## Configuring your environment

1. Execute ```cache.sh``` to grab a bunch of dependencies. The file is really
   well commented -- we don't source any nefarious binaries
2. Install [Vagrant](https://www.vagrantup.com/)

## Launching a VM

1. Run ```vagrant up```. The first time will be fairly slow as we have to
   install SQL Server and IIS
