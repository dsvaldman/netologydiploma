terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
  }
}
required_version = ">= 0.13"

}
provider "yandex" {
  token     = var.token1
  cloud_id  = "b1gmlv5uskcpsgd73uql"
  folder_id = "b1gr9q05mhtjbo7gmsie"
  zone      = "ru-central1-a"
}
resource "yandex_compute_instance" "webserver1" {
  name = "webserver1"

  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-5.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.webservers.id}"]
    
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}

resource "yandex_compute_instance" "webserver2" {
  name = "webserver2"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.webservers.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}
resource "yandex_compute_instance" "prometheus" {
  name = "prometheus"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.webservers.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}
resource "yandex_compute_instance" "grafana" {
  name = "grafana"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.services.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}
resource "yandex_compute_instance" "elasticsearch" {
  name = "elasticsearch"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
    security_group_ids = ["${yandex_vpc_security_group.webservers.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}
resource "yandex_compute_instance" "kibana" {
  name = "kibana"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 15
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.services.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}
resource "yandex_compute_instance" "bastion" {
  name = "bastion"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk"
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-4.id
    nat       = true
    security_group_ids = ["${yandex_vpc_security_group.bastion.id}"]
  }

  metadata = {
    user-data = "${file("/home/daniil/test/meta.txt")}"
  }
}


resource "yandex_vpc_network" "network-1" {
  name = "diploma"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "private1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.24.0/24"]
}


resource "yandex_vpc_subnet" "subnet-3" {
  name           = "webserver2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-4" {
  name           = "bastion-network"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.50.0/24"]
}

resource "yandex_vpc_subnet" "subnet-5" {
  name           = "webserver1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.51.0/24"]
}
resource "yandex_alb_target_group" "foo" {
  name           = "webservers"

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-5.id}"
    ip_address   = "${yandex_compute_instance.webserver1.network_interface.0.ip_address}"
  }

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-3.id}"
    ip_address   = "${yandex_compute_instance.webserver2.network_interface.0.ip_address}"
  }
}
resource "yandex_alb_backend_group" "backend-group" {
  name      = "backend-group"

  http_backend {
    name = "http-backend"
    weight = 1
    port = 80
    target_group_ids = ["${yandex_alb_target_group.foo.id}"]
    load_balancing_config {
      panic_threshold = 50
    }    
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "false"
  }
}
resource "yandex_alb_http_router" "router" {
  name   = "router"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}	 
resource "yandex_alb_virtual_host" "virtual-host" {
  name           = "virtual-host"
  http_router_id = "${yandex_alb_http_router.router.id}"
  route {
    name = "route66"
    http_route {
      http_route_action {
        backend_group_id = "${yandex_alb_backend_group.backend-group.id}"
        timeout          = "3s"
      }
    }
  }
}
resource "yandex_alb_load_balancer" "balancer" {
  name        = "balancer"
  network_id  = "${yandex_vpc_network.network-1.id}"

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
     
    }
}
  listener {
    name = "sentinel"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.router.id}"
      }
    }
  }
}

resource "yandex_vpc_security_group" "webservers" {
  name        = "webservers"
  description = "ports for webservers"
  network_id  = "${yandex_vpc_network.network-1.id}"

   ingress {
    protocol       = "ANY"
    description    = "bastion in"
    port           = 22
    security_group_id = "${yandex_vpc_security_group.bastion.id}"
  }

  ingress {
    protocol       = "ANY"
    description    = "nginx in"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 80
  }

 ingress {
    protocol       = "ANY"
    description    = "logexporter in"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 4040
  }
  egress {
    protocol       = "ANY"
    description    = "logexporter out"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 4040
  }


  egress {
    protocol       = "ANY"
    description    = "nginx out"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 80
  }

  ingress {
    protocol       = "ANY"
    description    = "prometheus in"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 9100
  }


  ingress {
    protocol       = "ANY"
    description    = "prometheus in"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 9090
  }


    egress {
    protocol       = "ANY"
    description    = "prometheus out"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 9100
  }

    egress {
    protocol       = "ANY"
    description    = "prometheus out"
    v4_cidr_blocks = ["192.168.30.18/32", "192.168.50.24/32"]
    port           = 9090
  }
    ingress {
    protocol       = "ANY"
    description    = "elastic in"
    v4_cidr_blocks = ["192.168.30.28/32", "192.168.50.24/32"]
    port           = 9200
  }
    egress {
    protocol       = "ANY"
    description    = "elastic out"
    v4_cidr_blocks = ["192.168.30.28/32", "192.168.50.24/32"]
    port           = 9200
  }
}

resource "yandex_vpc_security_group" "services" {
  name        = "services"
  description = "ports for services"
  network_id  = "${yandex_vpc_network.network-1.id}"

    ingress {
    protocol       = "ANY"
    description    = "bastion in"
    port           = 22
    security_group_id = "${yandex_vpc_security_group.bastion.id}"
  }

  ingress {
    protocol       = "ANY"
    description    = "kibana in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
    ingress {
    protocol       = "ANY"
    description    = "grafana in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3000
  }
    ingress {
    protocol       = "ANY"
    description    = "grafana in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9090
  }
  ingress {
   protocol       = "ANY"
    description    = "kibana in"
   v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9200
  }
    egress {
    protocol       = "ANY"
    description    = "kibana out"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
    egress {
    protocol       = "ANY"
    description    = "kibana out"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9200
 }

  egress {
   protocol       = "ANY"
   description    = "grafana out"
   v4_cidr_blocks = ["0.0.0.0/0"]
   port           = 3000
  }
   egress {
    protocol       = "ANY"
    description    = "grafana out"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9090
  }
}
resource "yandex_vpc_security_group" "bastion" {
  name        = "bastion"
  description = "port for bastion"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "ANY"
    description    = "bastion in"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

   egress {
   protocol       = "ANY"
   description    = "bastion out"
   v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.webserver1.network_interface.0.ip_address
}
output "external_ip_address_vm_1" {
  value = yandex_compute_instance.webserver1.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.webserver2.network_interface.0.ip_address
}
output "external_ip_address_vm_2" {
  value = yandex_compute_instance.webserver2.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_3" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
}
output "external_ip_address_vm_3" {
  value = yandex_compute_instance.prometheus.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_4" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
}
output "external_ip_address_vm_4" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_5" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
}
output "external_ip_address_vm_5" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_6" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}
output "external_ip_address_vm_6" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
output "internal_ip_address_vm_7" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}
output "external_ip_address_vm_7" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}