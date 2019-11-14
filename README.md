# Rakam-API Terraform Installation
---
![Screen Recording 2019-11-14 at 06 18 PM](https://user-images.githubusercontent.com/6921843/68870025-3563f780-070b-11ea-84cd-c2fef8534b27.gif)
---
This script will run on your cloud provider, we support only AWS at the moment. The following dependencies assumed to be already installed.

* Terraform cli: >= 0.12.13
* Kubectl: Preferably latest
* aws-iam-authenticator: Preferably latest
* aws-cli: >= 1.16.xxx
* The private Terraform repository for Rakam API (We will add you to the repo in POC period)

The script consists of several deployments as follows;

* ACM certificate provisioning.
* VPC, subnet, routing table and gateway provisioning.
* EKS cluster provisioning.
* EKS worker node group and nodes provisioning.
* IAM policies and security groups for the EKS cluster and worker nodes
* MySQL RDS provisioning. (Metadata store)
* Kinesis provisioning.


Post Installations:

* Kubectl configuration and assigning worker nodes to the EKS cluster via kubectl.
* Setting up the optional Kubernetes web UI.

---
### STEP 1: Open `provider.tf` and make the following changes:

* Create a programmatic access IAM account, with preferable access to all resources. Note that after the creation of resources you can revoke its access.

* If you use `aws-cli`, terraform will select the `default` profile. Otherwise, you can hard-code your programmatic IAM account credentials as follows;

```
provider "aws" {
  region     = "${var.aws_region}"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```
---
### STEP 2: Open `variables.tf` and make the following changes if needed:

* `aws_region`: The resources will be provisioned from the given location.

* `instance-type`: What should be the node templates instance type for EKS cluster to use.

* `instance-capacity`: The default number of nodes to be provisioned. Defaults to 2

* `instance-capacity-min`: What is the minimum number of nodes that have to stay alive all the time. Upon node upgrades and AWS maintains. Minimum capacity will always be kept. For instance, If you specify this to `2`, AWS will provide the third node before upgrading your second node. This also affects the minimum number of nodes that autoscaling can downgrade.

* `instance-capacity-max`: What is the maximum number of nodes that the autoscaling group can provision. Upon high loads, the node group will scale up and down with respect to `instance-capacity-max` and `instance-capacity-min`

* `instance-cpu-count`: Enter the number of vCPU's of your instance, and available memory in GB's to `instance-ram-in-gb`. These variables helps setting appropiate resource requests and limits to daemonset and deployment pods.

* `certificate-domain`: The alt domain name of your API. e.g `rakam-api-prod.yourdomain.com`

* `certificate-email`: A valid e-mail address for ACM validation.

* `rakam-rds-username` and `rakam-rds-password` Will set username and password MySQL instance. You may select any random strings for them since this instance is not publicly available. Access to this instance is only possible over the worker nodes running for the EKS cluster.

* `rakam-api-lock-key`: Choose a secure random lock-key for your rakam-api. You need this to create projects in rakam-api.

* `rakam-collector-license-key-name` your license key name given by us.

### Step 3: Put your license key to the same folder.
This project uses a private container registry of rakam. Copy the `license.json` to the same directory where the `.tf` files are.


### STEP 4: terraform init: Download the required modules
Change your directory to the terraform scripts folder and execute `terraform init`: This will install the required official terraform modules.

### (OPTIONAL) STEP: terraform plan: See what will happen
Execute `terraform plan`, this will show you the detailed resources to be created on the next step.


### STEP 5: terraform apply: Provisioning phase.
Provisioning will start on your `terraform apply` command. You will see the same planning results as on `terraform plan` but this time asked to confirm. Upon completion which will take about ~30 minutes, two-state files as `terraform.tfstate` and `terraform.tfstate.backup` will be created.

⚠️⚠️⚠️: **Store .tfstate files on a secure location. Upon update, If state files are lost, all resources have to be mapped manually or provisioned again.**


### STEP 6: Validate your ACM certificate.
`terraform apply` command will output various information. `cert-dns` shows you the required DNS validation for a valid certificate provisioning.

```
cert-dns = [
  {
    "domain_name" = "testelb.rakam.io"
    "resource_record_name" = "_a1aa2b7b49c946d1485999c517cfd45c.testelb.rakam.io."
    "resource_record_type" = "CNAME"
    "resource_record_value" = "_a921985328036837a7a63a1e66d10d4b.kirrbxfjtw.acm-validations.aws."
  },
]
```

For the example given above, create a `CNAME` record from `_a1aa2b7b49c946d1485999c517cfd45c.testelb.rakam.io` to `_a921985328036837a7a63a1e66d10d4b.kirrbxfjtw.acm-validations.aws` Grab a freshly ground coffee ☕️, this might take few minutes depending on DNS propagation. 


### STEP 7: Connect worker nodes to EKS cluster.
run `./configure` script located on the main directory. You may need to execute `chmod +x ./configure` to make the file executable. This script will set the kube config file located at `~/.kube/config`. Second step of the script is to assign the worker pools to the EKS cluster.

---
### (OPTIONAL) STEP: Install Kubernetes Dashboard UI
Run the following command in main directory to install the kubernetes web UI;
`cd ./kubernetes-web-ui && chmod +x ./configure.sh && ./configure.sh`

To connect your cluster you can execute the connect script as follows:

`chmod +x ./connect.sh && ./connect.sh`

This will output a temporary service-account-token to log in the UI:

```
Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      RANDOM_TOKEN...
Starting to serve on 127.0.0.1:8001
```

The connect.sh script will create a local-port forwarding on port: 8001. Navigate to: 
`http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login` and log in using the token.

---
### Scaling up/Down, Changing instance-type
By altering the `instance-capacity` variables you can manually scale up or down the cluster. If you change the `instance-type` variable and perform `terraform apply` command, the autoscaling groups default instance type will change. However, it will not roll-up new nodes.

You have to go to your AWS console, navigate to EC2 -> Auto Scaling Groups -> `terraform-eks-rakam` and choose the `Instances` tab. Select your old instance and `detach` from the group. Also, select `Add a new instance to the Auto Scaling group to balance the load` (do this step one-by-one per node)

![Screen Shot 2019-11-13 at 21 19 24](https://user-images.githubusercontent.com/6921843/68791914-5d941d80-065b-11ea-9a1c-4bca4395c74b.png)

Note that, while changing the `instance-type` old nodes will not be terminated automatically. After completing the same step for each node. You may terminate the old instances. However, while only changing the `instance-capacity` you don't have to drain/terminate any instance. This will be done automatically by the autoscaling group policies.

![Screen Shot 2019-11-13 at 18 42 30](https://user-images.githubusercontent.com/6921843/68791966-7d2b4600-065b-11ea-8eb9-d1da0b73fee4.png)
