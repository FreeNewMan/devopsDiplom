resource "yandex_vpc_network" "diplom-network" {
  name = "diplom-network"
}

resource "yandex_vpc_subnet" "diplom-subnet-a" {
  name = "diplom-subnet-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.diplom-network.id}"
}

resource "yandex_vpc_subnet" "diplom-subnet-b" {
  name = "diplom-subnet-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.diplom-network.id}"
}
