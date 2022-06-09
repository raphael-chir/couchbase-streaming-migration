# ---------------------------------------------
#    Root Module Output return variables
# ---------------------------------------------

output "instance01-ssh" {
  value = join("",["ssh -i ", var.ssh_keys_path, " ubuntu@", module.node01.public_ip])
}

output "instance01_confluent_public_dns" {
  value = join(":",[module.node01.public_dns,"9021"])
}

output "instance01_couchbase_public_dns" {
  value = join(":",[module.node01.public_dns,"8091"])
}