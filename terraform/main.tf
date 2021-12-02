terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}


resource "libvirt_pool" "tfpool" {
  name = "tfpool"
  type = "dir"
  path = "/var/lib/libvirt/terraform/pool"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "focal-base" {
  name   = "focal-base"
  pool   = libvirt_pool.tfpool.name
  #source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  source = "/var/lib/libvirt/terraform/base_images/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "tfvm" {
  count = 2
  name           = "tfvm${count.index}.qcow2"
  base_volume_id = libvirt_volume.focal-base.id
  size           = 30000000000 
  pool           = libvirt_pool.tfpool.name
}

#data "template_file" "user_data" {
#  template = file("${path.module}/cloud_init.cfg" )
#}

#data "template_file" "network_config" {
#  template = file("${path.module}/network_config.cfg")
#}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = 2
  name           = "commoninit${count.index}.iso"
  #user_data      = data.template_file.user_data.rendered
  user_data      = templatefile("${path.module}/cloud_init.cfg", {instance = count.index} )
  #network_config = data.template_file.network_config.rendered
  network_config = file("${path.module}/network_config.cfg")
  pool           = libvirt_pool.tfpool.name
}

resource "libvirt_domain" "tfvm" {
  count = 2
  name   = "tfvm${count.index}.domain.com"
  memory = "512"
  vcpu   = "1"
  machine = "q35"
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  xml {
    xslt = file("cdrom-model.xsl")
  }

  disk {
    volume_id = libvirt_volume.tfvm[count.index].id
  }

  network_interface {
    network_name = "default"
    bridge = "eth0"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }


  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}

