# Moodle on Windows Vagrant box

A (rather opinionated) layer on top of my
[Vagrant Windows box factory](https://github.com/LukeCarrier/vagrant-windows)
for Moodle-specific images. Note that this is not a base box, but rather a
collection of configuration and automation scripts that convert a base box into
a server capable of hosting Moodle.

* * *

## Configuring your environment

1. Ensure Ruby is on your path
2. Execute ```make-cache.rb``` to grab a bunch of dependencies. The file is
   really well commented -- we don't source any nefarious binaries
3. Install [Vagrant](https://www.vagrantup.com/)
4. Generate and install a base box image from the Windows box factory linked to
   above
5. To enable us to reboot the virtual machine during provisioning, install the
   [Vagrant Reload Provisioner](https://github.com/aidanns/vagrant-reload)
   plugin
6. We'll need to be able to configure SMB shares on your host machine and mount
   them on the guest. To allow us to do this, install my
   [Vagrant Better SMB](https://github.com/LukeCarrier/vagrant-better-smb)
   plugin
7. Clone this repository alongside the Moodle site you want to run. Note that
   both the Moodle source and data directories must be below the directory you
   clone this repository to. See the recommended configuration below

### Recommended configuration

Structure your directories as follows:

    Moodle
    ├── data
    │   └── master
    ├── src
    ├── plugins
    └── src-vagrant-windows-moodle

Then just copy our ```Vagrantfile.dist``` to ```Vagrantfile``` in the
```Moodle``` directory and edit the shared folder configuration to suit your
configuration.

## Launching a VM

1. ```cd``` to your Moodle directory (you're looking for the one which contains
   your shiny new ```Vagrantfile```
2. Run ```vagrant up```. The first time will be fairly slow as we have to
   install SQL Server and IIS, but subsequent launches should be relatively fast
