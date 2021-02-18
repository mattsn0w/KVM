
# A RaspberryPi 4 Hypervisor Host
##  Disclaimer
You should ensure that you have a fan and cooling setup with sufficient power to your Raspberry Pi4. I am not responsible if you have overheating/theremal issues.

### RaspberryPi Requirments
* One (or more) RaspberryPi 4 with 8GB of RAM
* An ethernet wired network with a DHCP server. This demo was setup with a docker containerized ISC-dhcpd server to handle MAC address ip mapping.
* Base OS install of Ubuntu 20.04 LTS ARM64 - [Download the SDCard image here](https://cdimage.ubuntu.com/releases/20.04.2/release/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz) and install to an SDCard per the install instructions.

### Packages to install
The following packages should be installed on the RaspberryPi KVM host. These package namesare specific to Ubuntu, but you should be able to find equivalents on CentOS. 

* cloud-utils
* cpu-checker
* libguestfs-tools
* libosinfo-bin
* libvirt-clients
* libvirt-daemon
* libvirt-daemon-system
* net-tools
* network-manager
* qemu-kvm
* virtinst
* virt-manager

###  Networking
#### Base OS bridge configuration.
I had trouble trying to bridgfe the wlan0 interface to the KVM network so I suggest using only the  ethernet interface.
Do not try to have eth0 and wlan0 up and running at the same time unless you really know your way around Linux networking.
See the [Netplan yaml configuration example](https://github.com/mattsn0w/KVM/blob/master/arm64_template/etc/netplan/50-cloud-init.yaml) for an example that relies on DHCP just like the guest VMs.
If you have a static IPto use then just make sure that you assign it to the bridge interface ( `br0` ).

#### KVM default network
After you have successfully configured the bridge at the OS level you can configure KVM network. Below is the output of the default bridge configuration.
Use `virsh net-edit --network default` to edit this setting in your environment.

```
virsh net-dumpxml --network default 
<network connections='3'>
  <name>default</name>
  <uuid>ff39aa43-662b-4c60-8230-27e3dba53c25</uuid>
  <forward mode='bridge'/>
  <bridge name='br0'/>
</network>
```

## VM Cloud Images
The Cloud-init enabled image for kvm deployment [can be downloaded here](https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-arm64.img) .
Place the downloaded image in `/var/lib/libvirt/images` or whereever you would like to store them but you must modify the respective scripts.

### useful commands
* The OS varient usedby virt-install is found in the output of `osinfo-query os`
* `virsh` and the numerous sub-commands

## Creating a VM
Make the appropriate modifications to `make-new-vm.sh` for the variables defined at the top of the script, then run it. 
You should see the boot up screen followed grub then kernel, then a bunch of the modifications defined in the `config.yaml` file for cloud-init.

##  Final steps
After install and update is successful, run `poweroff` in the guest OS, then `virsh autostart armvm0N &&  virsh start armvm0N` to restart the VM.


##### References
* https://cloudinit.readthedocs.io/en/latest
* https://cloudinit.readthedocs.io/en/latest/topics/network-config-format-v1.html#network-config-v1
* https://www.cyberciti.biz/faq/how-to-install-kvm-on-ubuntu-20-04-lts-headless-server/
* https://www.cyberciti.biz/faq/howto-linux-delete-a-running-vm-guest-on-kvm/
* https://stafwag.github.io/blog/blog/2020/07/23/howto-use-cloud-images-on-rpi4/

