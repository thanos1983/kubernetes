# Project KITN

## Caution, if this is first deployment and the user has not being created prerequisites yet, the user must first navigate to prerequisites directory and apply the code there first.

### List active subscription(s)

The user should list his active subscription(s) and make sure that the default subscription is the one that we want to
use. Sample:

````bash
$ az account list --output table --all
Name                           CloudName    SubscriptionId                        TenantId                              State    IsDefault
---------------------------- ---------- ----------------------------------- ----------------------------------- ------ -----------
LSAC-Digital-Solutions         AzureCloud   <SubscriptionId>                      <TenantId>                            Enabled  True
````

### Change the active subscription

Because it might not be the default subscription the one that the user wants to use we need to change the subscription.
Sample:

````bash
# change the active subscription using the subscription name
$ az account set --subscription "LSAC-Digital-Solutions"

# change the active subscription using the subscription ID
$ az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# verify the default active subscription by using list
$ az account list --query "[?isDefault]"
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "<homeTenantId>",
    "id": "<id>",
    "isDefault": true,
    "managedByTenants": [],
    "name": "LSAC-Digital-Solutions",
    "state": "Enabled",
    "tenantId": "<tenantId>",
    "user": {
      "name": "<user>@NNIT.COM",
      "type": "user"
    }
  }
]
````

Now the user can use the associated subscription to query, create, update, destroy resources etc etc.

### WSL with terraform

If the user is using WSL(1/2) with terraform, because of the Multi Factor Authenticator (MFA) procedure the following
steps need to be applied. Sample:

````bash
# install python required packages
sudo apt get install -y python3-kubernetes python3-passlib python3-hvac python3-k8sclient python3-openshift
# install wslu on e.g. Ubuntu WSL
sudo apt install wslu -y
# add these two lines to your shell's RC file, e.g. .bashrc or .zshrc.
export DISPLAY=:0
export BROWSER=/usr/bin/wslview
````

Then the user will be able to log in to Azure via terminal e.g. Sample:

````bash
az login --use-device-code

# or directly to a specific tenant (if desired)
az login --use-device-code --tenant <TenantId>
````

### The following steps will assume that prerequisites have being already met.

#### terraform init

Because we want to use different containers in Storage Account per stage (environment) we need to use different init
version file. Sample of code for dev (replace per stage):

````bash
$ tofu -chdir=IaC/k8s/tf init -upgrade -reconfigure -backend-config=initVersion/version-test.hcl
````

#### terraform plan

Next step the user should plan the infrastructure to be added / created on the desired Resource Group (RG). Since we
want to use different variables per stage we need to have different tfvars files. Sample of code:

````bash
$ tofu -chdir=IaC/k8s/tf plan -out=planOutput -var-file=tfvars/test.tfvars
````

#### terraform apply

The user needs to review the previous steps in the screen before applying. It is highly important to understand that
terraform will modify the infrastructure based on the plan. Assuming that the resources are according to the desired
output the user can apply the modifications. Sample of code:

````bash
$ tofu -chdir=IaC/k8s/tf apply "planOutput"
````

#### terraform destroy

In case that the user wants to **completely destroy all** resources (based on the existing `main.tf` file) it can be
accomplished with the following sample of code:

_First plan (so the user can view what resources will be affected)._

````bash
$ tofu -chdir=IaC/k8s/tf plan -destroy -out destroyPlan -var-file=tfvars/test.tfvars
````

_Then apply (no return after this step)._

````bash
$ tofu -chdir=IaC/k8s/tf apply "destroyPlan"
````

In case the user decides to destroy a specific resource it can be accomplished by using the ``-target`` flag. Sample:

````bash
$ tofu -chdir=IaC/k8s/tf plan -destroy -target module.da_projektet_df -out destroyPlan -var-file=tfvars/test.tfvars
````

#### terraform import

If the user needs to import (already existing resources) please follow the example code below on how to do that:

Sample of error:

````bash
$ tofu -chdir=IaC/k8s/tf apply "planOutput"
Acquiring state lock. This may take a few moments...
module.kitn_projekt_resource_group.azurerm_resource_group.resource_group: Creating...
╷
│ Error: A resource with the ID "/subscriptions/<subscription-id>/resourceGroups/devkitnrg" already exists to be managed via Terraform this resource needs to be imported numbero the State. Please see the resource documentation for "azurerm_resource_group" for more information.
│
│   with module.kitn_projekt_resource_group.azurerm_resource_group.resource_group,
│   on .terraform/modules/kitn_projekt_resource_group/tf/modules/ResourceGroup/main.tf line 1, in resource "azurerm_resource_group" "resource_group":
│    1: resource "azurerm_resource_group" "resource_group" {
│
╵
Releasing state lock. This may take a few moments...
````

On this example the error is coming from module (
resource) `module.kitn_projekt_resource_group.azurerm_resource_group.resource_group`

So the user needs to import the resource(s) at this ponumber. For every resource the user needs to read the official
documentation. On this
example [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).

Sample of process:

````bash
$ tofu -chdir=IaC/k8s/tf import -var-file=tfvars/test.tfvars module.kitn_projekt_resource_group.azurerm_resource_group.resource_group "/subscriptions/5dd4eb6a-9fc8-4def-82e8-625f1852e5de/resourceGroups/devkitnrg"
Acquiring state lock. This may take a few moments...
module.kitn_projekt_resource_group.azurerm_resource_group.resource_group: Importing from ID "/subscriptions/<subscription-id>/resourceGroups/devkitnrg"...
module.kitn_projekt_resource_group.azurerm_resource_group.resource_group: Import prepared!
  Prepared azurerm_resource_group for import
module.kitn_projekt_resource_group.azurerm_resource_group.resource_group: Refreshing state... [id=/subscriptions/<subscription-id>/resourceGroups/devkitnrg]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

Releasing state lock. This may take a few moments...
````

#### Qdrant Cloud

The user in order to be able to validate against the Cloud he / she needs to export the following terraform ENV variables:

````bash
# Rancher configurations
# The user need to create manually a cluster in order to retrieve the API KEY.
export TF_VAR_QDRANT_API_KEY="<API Key>"
# Can be found once the user has logged in to the Qrdant Cloud UI. The ID can also be found on the url.
export TF_VAR_QDRANT_ACCOUNT_ID="<Account ID>"
````

#### Ansible Debugging modules
If the user desires to debug a module (Ansible role) for testing purposes the syntax should be the following:

````bash
ansible-playbook -i <remote node IP>, IaC/k8s/tf/playbook.yml --tags ping
````

The user needs to have the role included in ``IaC/k8s/tf/playbook.yml`` file before using the tags.

#### Important Requirements

The requirements are the following:

- TF installed
- docker daemon running
- The user which will be used to create the resources should have enough permissions (sample as owner or custom RBAC
  role) to create / assign README access on the Subscription level and also Resource Group level. More information can
  be found on the Microsoft
  forum [Can't deploy Azure Open AI models due "No quota is available for this deployment. You can request for more quota."](https://learn.microsoft.com/en-us/answers/questions/1339528/cant-deploy-azure-open-ai-models-due-no-quota-is-a)
