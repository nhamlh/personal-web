
# Personal web project

Deploy some services for a personal web project:
- A front page
- A blog
- An email server

## General

This project is organized in 2 parts:
- Infrastructure. Currently support AWS2 or Vultr for provisioning a Linux box, Gandi for DNS registry. To use other VPS service or DNS registry, you can configure it manually and apply application stack to deploy services.
- Application stack. Use Ansible to configure services.

## Demo
This project is deployed at vultr.nhamlh.me. You can access services at:
- https://vult.nhamlh.me - front pageg
- https://blog.vultr.nhamlh.me - Wordpress blog
- hi@vultr.nhamlh.me - default mailbox. You can reach out to me and send a greeting email to this address and I'll reply you back.

Utilized tools:
- Terraform - provisioning cloud resources
- Ansible - managing the linux server configuration
- Docker Swarm - running applications in containers
- Caddy - reversed proxy with automic TLS support
- Stalwart - modern all-in-one mail server with TLS, DKIM, SPF and DMARC support out of the box

### Sending mail out
Most cloud providers block outgoing 25 port so I can't get approriate host which has port 25 open on time. AWS support ticket to unblock port 25 didn't got reply yet; registered for DigitalOcean and Linode and couldn't activate my account (SMS OTP code didn't come, heck). Therefore, sending email isn't functioning even though I've set all DKIM, SPF and DMARC for the domain and pretty sure it will work.

## Installation

### Infrastructure
The infrastructure is provisioned via Terraform.

In this setup, I used AWS for server and gandi.net for DNS, so to deploy your own stack, you'll need AWS and gandi.net accounts. Also make sure to setup awscli profile and export AWS_PROFILE=<your profile> if you're not using default profile.

Generate key pair for DKIM:
```sh
openssl genrsa -out rsa_private.key 2048
openssl rsa -in rsa_private.key -pubout -out rsa_public.key
```

Encode public to use as DKIM public key (put this value to dkim_public_key in next step):
```sh
openssl rsa -in rsa_private.key -pubout -outform der 2>/dev/null | openssl base64 -A

```

Create default.auto.tfvars to provide required vars:
```txt
gandi_api_key  = "<Gandi.net API KEY>"
domain_name = "nhamlh.me"
ec2_public_key = "<Key used to SSH to EC2 instance>"
vpc_id         = "<VPC to spawn EC2 into>"
dkim_public_key = "<public key in previous step>"

```

Trigger terraform commands to provision the infrastructure:
```sh
terraform init
terraform plan
terraform apply -auto-approve
```

After terraform applying the infrastructure successfully, it will output server's public IP


### Application stack
The application stack - web, blog and mail - is configured and managed by Ansible.

Create ansible inventory:
```sh
echo <public ip> > inventory
```

Create ansible_vars:
```yaml
dkim_private_key: |
  Paste rsa_private.key content

base_domain: nhamlh
```
This is default vars file specified in playbook.yaml. We can create arbitrary files, then edit playbook.yml's vars_file attribute.

Apply the stack:
```sh
ansible-playbook playbook.yml -i inventory -u ubuntu
```

stalwart mail server needs some manual steps after launched:
```sh
# Generate password for mailbox
MAILBOX_PASSWD=$(pwgen -n 20 -1)

# Get stalwart container
sudo docker ps | grep mail

# Execute into the container
sudo docker exec -it <mail container name> bash

# Get admin password
grep password /opt/stalwart-mail/logs/*

# Create domain for mailboxes
stalwart-cli --url https://localhost:8080 domain create nhamlh.me

# Create mailbox named hi
stalwart-cli --url https://localhost:8080 account create --addresses hi@nhamlh.me hi $MAILBOX_PASSWD
```

### Email setup
While services are spawned automatically using Ansible, the email server need some manual steps to function.


### DNS

#### Reverse DNS
We need reverse DNS for our public IP. However, Terraform provider doesn't support such setting yet thus we'll need to configure it manually. For AWS, go to EC2 service, select Elastic IP tab, search for our EIP  then click Update reversed DNS to update.

## TODO
- Glue Terraform and Ansible together to provide end-to-end automation
- Enable Github Actions to trigger the whole stack by CI
- Static web by Hugo
- Ansible task to create user with attached email
  stalwart-cli --url https://localhost:8080 account create --address hi@nhamlh.me hi password
