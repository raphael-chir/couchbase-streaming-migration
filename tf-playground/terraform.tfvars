# ----------------------------------------
#    Default main config - Staging env
# ----------------------------------------

region_target = "eu-north-1"

resource_tags = {
  project     = "couchbase-streaming-migration"
  environment = "staging-rch"
  owner       = "raphael.chir@couchbase.com"
}

ssh_keys_path = "/sandbox/tf-playground/.ssh/zkey"