# Deployment of a FortiGate-VM (BYOL/PAYG)  on the AWS

## GitHub Actions Deployment

This deployment can be automated using GitHub Actions workflow. Follow these steps:

### Prerequisites
1. Fork this repository to your GitHub account
2. Configure AWS credentials in repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Deployment Steps
1. Go to **Actions** tab in your GitHub repository
2. Select **"Deploy FortiGate to AWS"** workflow
3. Click **"Run workflow"** and configure:
   - **FortiGate Version**: Select the version (matches this folder)
   - **Deployment Type**: Select the deployment type (matches this folder)
   - **AWS Region**: Choose your target region
   - **Environment**: Select environment (dev/staging/prod)
4. Click **"Run workflow"** to start deployment

The workflow will automatically:
- Validate the deployment path exists
- Initialize Terraform
- Plan the deployment
- Apply the configuration
- Provide deployment summary

### Manual Deployment
For manual deployment, continue with the instructions below.


## Introduction
A Terraform script to deploy a FortiGate-VM on AWS

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.0.0
* Terraform Provider AWS >= 3.63.0
* Terraform Provider Template >= 2.2.0


## Deployment overview
Terraform deploys the following components:
   - AWS VPC with 2 subnets
   - One FortiGate-VM instance with 2 NICs
   - Two Network Security Group rules: one for external, one for internal.
   - Two Route tables: one for internal subnet and one for external subnet.

![single-architecture](./aws-topology-single.png?raw=true "GWLB Architecture")

## Deployment
To deploy the FortiGate-VM to AWS:
1. Clone the repository.
2. Customize variables in the `terraform.tfvars.example` and `variables.tf` file as needed.  And rename `terraform.tfvars.example` to `terraform.tfvars`.
3. Initialize the providers and modules:
   ```sh
   $ cd XXXXX
   $ terraform init
    ```
4. Submit the Terraform plan:
   ```sh
   $ terraform plan
   ```
5. Verify output.
6. Confirm and apply the plan:
   ```sh
   $ terraform apply
   ```
7. If output is satisfactory, type `yes`.

Output will include the information necessary to log in to the FortiGate-VM instances:
```sh
FGTPublicIP = <FGT Public IP>
Password = <FGT Password>
Username = <FGT Username>
```

## Destroy the instance
To destroy the instance, use the command:
```sh
$ terraform destroy
```

# Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/fortigate-terraform-deploy/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](https://github.com/fortinet/fortigate-terraform-deploy/blob/master/LICENSE) © Fortinet Technologies. All rights reserved.



