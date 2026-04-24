packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

source "docker" "nginx" {
  image  = "nginx:alpine"
  commit = true

  changes = [
    "EXPOSE 80"
  ]
}

build {
  name    = "nginx-custom"
  sources = ["source.docker.nginx"]

  provisioner "file" {
    source      = "index.html"
    destination = "/usr/share/nginx/html/index.html"
  }

  post-processor "docker-tag" {
    repository = "nginx-custom"
    tags       = ["1.0"]
  }
}