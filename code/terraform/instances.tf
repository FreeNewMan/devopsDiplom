module "master-node" {
  source = "./modules/instance"
 
  depends_on = [yandex_vpc_network.diplom-network,
                yandex_vpc_subnet.diplom-subnet-a]

  subnet_id     = "${yandex_vpc_subnet.diplom-subnet-a.id}"
  zone          = "${yandex_vpc_subnet.diplom-subnet-a.zone}"
  image_id      = "fd8kdq6d0p8sij7h5qe3"  # Ubuntu 20.04 LTS
  platform_id   = "standard-v2"
  name          = "master-node"
  description   = "master-node"
  users         = "devuser"
  cores         = "4"
  boot_disk     = "network-ssd"
  disk_size     = "20"
  nat           = "true"
  memory        = "4"
  core_fraction = "100"
}



module "worker-node1" {
  source = "./modules/instance"

  depends_on = [yandex_vpc_network.diplom-network,
                yandex_vpc_subnet.diplom-subnet-a]

  subnet_id     = "${yandex_vpc_subnet.diplom-subnet-a.id}"
  zone          = "${yandex_vpc_subnet.diplom-subnet-a.zone}"
  image_id      = "fd8kdq6d0p8sij7h5qe3"  # Ubuntu 20.04 LTS
  platform_id   = "standard-v2"
  name          = "worker-node1"
  description   = "worker-node1"
  users         = "devuser"
  cores         = "4"
  boot_disk     = "network-ssd"
  disk_size     = "40"
  nat           = "true"
  memory        = "4"
  core_fraction = "100"
}

module "worker-node2" {
  source = "./modules/instance"

  depends_on = [yandex_vpc_network.diplom-network,
                yandex_vpc_subnet.diplom-subnet-a]

  subnet_id     = "${yandex_vpc_subnet.diplom-subnet-b.id}"
  zone          = "${yandex_vpc_subnet.diplom-subnet-b.zone}"  
  image_id      = "fd8kdq6d0p8sij7h5qe3"  # Ubuntu 20.04 LTS
  platform_id   = "standard-v2"
  name          = "worker-node2"
  description   = "worker-node2"
  users         = "devuser"
  cores         = "2"
  boot_disk     = "network-ssd"
  disk_size     = "40"
  nat           = "true"
  memory        = "4"
  core_fraction = "100"
}


