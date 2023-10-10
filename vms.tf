module "vm" {
  for_each = {
    foo = {}
    bar = {}
  }

  source = "./modules/vm"

  name                = each.key
  location            = local.location
  resource_group_name = azurerm_resource_group.eon.name
  subnet_id           = module.net.subnet_ids["10.250.0.0/24"]
  public_ip_enabled   = true
  admin_username      = "default"
  admin_password      = "asdfA1.."
  user_data           = <<EOF
#cloud-config
ssh_pwauth: yes
chpasswd:
  expire: false
runcmd:
  - |
    curl -fsSL https://raw.githubusercontent.com/sikalabs/slu/master/install.sh | sh
  - |
    curl -fsSL https://ins.oxs.cz/docker.sh | sudo sh
  - docker run --name hello -d -p 80:8000 -e TEXT="Hello EON" sikalabs/hello-world-server
EOF
}

output "ips" {
  value = {
    for name, vm in module.vm : name => {
      public_ip  = vm.public_ip
      private_ip = vm.private_ip
    }
  }
}

output "see" {
  value = {
    for name, vm in module.vm :
    name => "http://${vm.public_ip}"
  }
}
