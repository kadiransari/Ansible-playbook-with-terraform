# Ansible-playbook-with-terraform
Added Terraform configuration for AWS EC2 provisioning with Ansible integration. Includes SSH setup, security groups, and automated provisioning.

Prerequisites:
Ensure you have the following installed:
Terraform (>= 1.0.0)
AWS CLI (configured with appropriate credentials)
Ansible
Git

Project Structure

.
├── terraform.tf          # Terraform configuration file

├── play.yml              # Ansible playbook

├── dev                   # SSH private key (not to be committed)

├── README.md             # Documentation

Setup and Usage

1. Initialize Terraform
 
#terraform init

2. Plan the Infrastructure
   
#terraform plan

This command will show the changes that Terraform will apply.

3. Apply the Configuration
   
#terraform apply -auto-approve

Terraform will provision an EC2 instance and security groups.

4. Run Ansible Playbook (if given any error you can try run this command on your local machine)
Once Terraform completes, you can use Ansible to configure the instance:

#ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i 54.218.35.67, --private-key dev play.yml


Outputs

After a successful deployment, Terraform will output the public IP of the created instance.

terraform output (web_ip)

Cleaning Up

To destroy the resources created by Terraform:
#terraform destroy
