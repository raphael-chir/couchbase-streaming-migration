# From RDBMS to Couchbase with Kafka

Thanks to Elio Salvatore and David Quintas from Couchbase. This setup is based on https://github.com/Belio/SQLstreamingtoNoSQL

Everything can be launched through docker on your laptop, but as it take place and memory usage, it can be useful to deploy the stack on a server.

The architecture is composed by :

- SQL Server : it plays the role of a legacy RDBMS to migrate
- Confluent : full stack with zookeeper, kafka, control center, ... it is the streaming platform
- Couchbase : NoSQL Data platform

## Run it

To run directly a full environment we use codesandbox. Click on this link : https://codesandbox.io/s/github/raphael-chir/couchbase-streaming-migration

You need to fork this template to set up your own workspace. For instance modify Readme.md and then save.

Wait while the sandbox starts and install all the tools needed.

## First check

Please check that everything is alright. Open a terminal in your sandbox and test environment

### Open a terminal and check terraform cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ terraform version
Terraform v1.1.9
on linux_amd64
```

### Check aws cli

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws --version
aws-cli/2.6.1 Python/3.9.11 Linux/5.13.0-40-generic exe/x86_64.debian.10 prompt/off
```

You need to configure your AWS access key. **Don't forget to delete or deactivate your access key in IAM, once you have finished this demo !**

```bash
sandbox@sse-sandbox-457lgm:/sandbox$ aws configure
AWS Access Key ID [None]: XXXXXXXXXXXXXX
AWS Secret Access Key [None]: XXXxxxxxxxxxxxxxxxxxXXXxxxxxxxxxXXxxxxxxx
Default region name [None]: eu-north-1
Default output format [None]:
```

## Terraform backend

All terraform state files are stored and shared in a dedicated S3 bucket. Create if needed your own bucket.

```bash
aws s3api create-bucket --bucket a-tfstate-rch --create-bucket-configuration LocationConstraint=eu-north-1 --region eu-north-1
aws s3api put-bucket-tagging --bucket a-tfstate-rch --tagging 'TagSet=[{Key=Owner,Value=raphael.chir@couchbase.com},{Key=Name,Value=terraform state set}]'
```

Refer your bucket in your terraform backend configuration, go to main.tf
**Specify a key for your project !**

```bash
terraform {
  backend "s3" {
    region  = "eu-north-1"
    key     = "myproject-tfstate"
    bucket  = "a-tfstate-rch"
  }
}
```

## Tag tag tag, ..

More than a best practice, it is essential for inventory resources, cost explorer, etc .. Open terraform.tfvars and update these values

```bash
resource_tags = {
  project     = "myproject"
  environment = "staging-rch"
  owner       = "raphael.chir@couchbase.com"
}
```

## SSH Keys

We need to generate key pair in order to ssh into instances. Create a .ssh folder in tf-playground. Open a terminal and paste this default command

```bash
mkdir /sandbox/tf-playground/.ssh
ssh-keygen -q -t rsa -b 4096 -f /sandbox/tf-playground/.ssh/zkey -N ''
```

## Choose your OS AMI

You can just copy from aws console the **ami-id** needed in the region targeted  
e.g : '_Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-04-20_' is **ami-01ded35841bc93d7f**

## Ready to terraform ?

When all the steps has been performed you can execute these commands inside /sandbox/tf-playground folder.

Terraform initialisation

```bash
sandbox@sse-sandbox-zp6o6o:/sandbox/tf-playground$ tf init
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v4.12.1

Terraform has been successfully initialized!
```

Terraform validation

```bash
sandbox@sse-sandbox-zp6o6o:/sandbox/tf-playground$ tf validate
Success! The configuration is valid.
```

Terraform plan

```bash
sandbox@sse-sandbox-zp6o6o:/sandbox/tf-playground$ tf plan
Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:
.................
.................
```

Terraform apply

```bash
sandbox@sse-sandbox-zp6o6o:/sandbox/tf-playground$ tf apply -auto-approve
.................
.................
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

instance01-ssh = "ssh -i /sandbox/tf-playground/.ssh/zkey ubuntu@13.48.45.243"
instance01_confluent_public_dns = "ec2-13-48-45-243.eu-north-1.compute.amazonaws.com:9021"
instance01_couchbase_public_dns = "ec2-13-48-45-243.eu-north-1.compute.amazonaws.com:8091"
```

## Wait while all installation are ready !!

Because almost 10Go of binaries will be load and installed, you can take a coffee.
The installation can take more than 6 minutes ..

## Play

Access thes different dns urls : check all the configuration, and objects created. In Couchbase bucket test has a store scope with empty collections
Then copy ssh command from terraform outputs and paste it into a new terminal.
execute this command to stream the data from SQL Server to Couchbase

```bash
ubuntu@ec2-ip:/home/ubuntu/deploy_ksql ksqldb.sql
```

## Destroy when finished

Because t3.xlarge, destroy everything :

```bash
sandbox@sse-sandbox-zp6o6o:/sandbox/tf-playground$ tf destroy -auto-approve
```
