# Moodle on Windows Vagrant box

A layer on top of my
[Vagrant Windows box factory](https://github.com/LukeCarrier/vagrant-windows)
for Moodle-specific images. Note that this is not a base box.

* * *

## Configuring your environment

1. Execute ```cache.sh``` to grab a bunch of dependencies. The file is really
   well commented -- we don't source any nefarious binaries
2. Install [Vagrant](https://www.vagrantup.com/)
3. Generate and install a base box image from the Windows box factory linked to
   above
4. To enable us to reboot the virtual machine during provisioning, install the
   [Vagrant Reload Provisioner](https://github.com/aidanns/vagrant-reload)
   plugin
5. Clone this repository alongside the Moodle site you want to run. Note that
   both the Moodle source and data directories must be below the directory you
   clone this repository to. See the recommended configuration below

### Recommended configuration

Structure your directories as follows:

    Moodle
    ├── data
    │   └── moodle-master
    ├── distributions
    │   └── moodle
    │   └── totaralms
    ├── plugins
    └── vagrant-windows

Then just copy our ```Vagrantfile.dist``` to ```Vagrantfile``` in the
```Moodle``` directory.

## Launching a VM

1. ```cd``` to your Moodle directory which contains your shiny new
   ```Vagrantfile```
2. Run ```vagrant up```. The first time will be fairly slow as we have to
   install SQL Server and IIS, but subsequent launches should be relatively fast
   (as far as Windows goes... ;-))
