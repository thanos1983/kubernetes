# Project

## Caution, if this is first deployment and the user has not being created prerequisites yet, the user must first navigate to prerequisites directory and apply the code there first.

### List active subscription(s)

The user should list his active subscription(s) and make sure that the default subscription is the one that we want to
use. Sample:

````bash
$ az account list --output table --all
Name                           CloudName    SubscriptionId                        TenantId                              State    IsDefault
---------------------------- ---------- ----------------------------------- ----------------------------------- ------ -----------
<tenant-name>                  AzureCloud   <SubscriptionId>                      <TenantId>                            Enabled  True
````

### Change the active subscription

Because it might not be the default subscription the one that the user wants to use we need to change the subscription.
Sample:

````bash
# change the active subscription using the subscription name
$ az account set --subscription "<subscription-name>"

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
    "name": "<tenant-name>",
    "state": "Enabled",
    "tenantId": "<tenantId>",
    "user": {
      "name": "<user>@DOMAIN.COM",
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
sudo apt-get install -y python3-kubernetes python3-passlib python3-hvac python3-k8sclient python3-openshift jq
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

### WSL Kubernetes

If the user is using WSL(1/2) planning to use Kubernetes (example version 1.33), the following packages need to be
installed:

````bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm kubectl
````

### The following steps will assume that prerequisites have being already met.

#### terraform init

Because we want to use different containers in Storage Account per stage (environment) we need to use different init
version file. Sample of code for dev (replace per stage):

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf init -upgrade -reconfigure -backend-config=initVersion/version-version-dev.hcl
````

#### terraform plan

Next step the user should plan the infrastructure to be added / created on the desired Resource Group (RG). Since we
want to use different variables per stage we need to have different tfvars files. Sample of code:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf plan -out planOutput -var-file=tfvars/dev.tfvars
````

#### terraform apply

The user needs to review the previous steps in the screen before applying. It is highly important to understand that
terraform will modify the infrastructure based on the plan. Assuming that the resources are according to the desired
output the user can apply the modifications. Sample of code:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf apply "planOutput"
````

#### terraform destroy

In case that the user wants to **completely destroy all** resources (based on the existing `main.tf` file) it can be
accomplished with the following sample of code:

_First plan (so the user can view what resources will be affected)._

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf plan -destroy -out destroyPlan -var-file=tfvars/dev.tfvars
````

_Then apply (no return after this step)._

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf apply "destroyPlan"
````

In case the user decides to destroy a specific resource it can be accomplished by using the ``-target`` flag. Sample:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf plan -destroy -target module.project_k8s_ansible_playbook_prerequisites_azure_disk_csi_driver -out destroyPlan -var-file=tfvars/dev.tfvars
````

#### terraform import

If the user needs to import (already existing resources) please follow the example code below on how to do that:

Sample of error:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf apply "planOutput"
Acquiring state lock. This may take a few moments...
module.projekt_resource_group.azurerm_resource_group.resource_group: Creating...
╷
│ Error: A resource with the ID "/subscriptions/<subscription-id>/resourceGroups/devrg" already exists to be managed via Terraform this resource needs to be imported numbero the State. Please see the resource documentation for "azurerm_resource_group" for more information.
│
│   with module.projekt_resource_group.azurerm_resource_group.resource_group,
│   on .terraform/modules/projekt_resource_group/tf/modules/ResourceGroup/main.tf line 1, in resource "azurerm_resource_group" "resource_group":
│    1: resource "azurerm_resource_group" "resource_group" {
│
╵
Releasing state lock. This may take a few moments...
````

On this example the error is coming from module (
resource) `module.projekt_resource_group.azurerm_resource_group.resource_group`

So the user needs to import the resource(s) at this point. For every resource the user needs to read the official
documentation. On this
example [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group).

Sample of process:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf import -var-file=tfvars/dev.tfvars module.projekt_resource_group.azurerm_resource_group.resource_group "/subscriptions/5dd4eb6a-9fc8-4def-82e8-625f1852e5de/resourceGroups/devrg"
Acquiring state lock. This may take a few moments...
module.projekt_resource_group.azurerm_resource_group.resource_group: Importing from ID "/subscriptions/<subscription-id>/resourceGroups/devrg"...
module.projekt_resource_group.azurerm_resource_group.resource_group: Import prepared!
  Prepared azurerm_resource_group for import
module.projekt_resource_group.azurerm_resource_group.resource_group: Refreshing state... [id=/subscriptions/<subscription-id>/resourceGroups/devrg]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

Releasing state lock. This may take a few moments...
````

#### Tofu State List Resources

The tofu state list command is used to list resources within
a [OpenTofu state](https://opentofu.org/docs/cli/commands/state/list/).

Sample of process:

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf state list
data.azuread_client_config.current
data.azurerm_client_config.current
data.azurerm_subscription.subscription
data.external.certs
data.external.token
data.http.knative_operator
data.http.net_istio
data.remote_file.kube_config
terraform_data.gateway_api_crds
terraform_data.prime_master_node
terraform_data.secondary_master_nodes["master02"]
terraform_data.secondary_master_nodes["master03"]
terraform_data.worker_nodes["worker01"]
terraform_data.worker_nodes["worker02"]
terraform_data.worker_nodes["worker03"]
module.project_ansible_playbook_k8s_persistent_storage.ansible_playbook.playbook
module.project_application_azure_disks.azuread_application.application
module.project_application_service_principal_azure_disks.azuread_service_principal.service_principal
module.project_application_service_principal_rbac_azure_disks.azurerm_role_assignment.role_assignment
module.project_azure_disks["grafana"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-backend-0"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-backend-1"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-backend-2"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-write-0"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-write-1"].azurerm_managed_disk.managed_disk
module.project_azure_disks["loki-write-2"].azurerm_managed_disk.managed_disk
module.project_azure_disks["prometheus"].azurerm_managed_disk.managed_disk
module.project_cloudflare_api_token.cloudflare_api_token.api_token
module.project_k8s_ansible_playbook_cert_manager_issuer.ansible_playbook.playbook
module.project_k8s_ansible_playbook_load_balancer.ansible_playbook.playbook
module.project_k8s_ansible_playbook_prerequisites_azure_disk_csi_driver.ansible_playbook.playbook
module.project_k8s_cluster_helm_azure_disk_csi_deployment.helm_release.release
module.project_k8s_cluster_helm_deployment["external-dns"].helm_release.release
module.project_k8s_cluster_helm_deployment["grafana"].helm_release.release
module.project_k8s_cluster_helm_deployment["loki"].helm_release.release
module.project_k8s_cluster_helm_deployment["prometheus"].helm_release.release
module.project_k8s_cluster_helm_deployment["promtail"].helm_release.release
module.project_k8s_cluster_helm_deployment["reflector"].helm_release.release
module.project_k8s_cluster_helm_deployment["sealed-secrets"].helm_release.release
module.project_k8s_cluster_helm_fundamental_charts_deployment["calico"].helm_release.release
module.project_k8s_cluster_helm_fundamental_charts_deployment["cert-manager"].helm_release.release
module.project_k8s_cluster_helm_fundamental_charts_deployment["metrics_server"].helm_release.release
module.project_k8s_cluster_helm_istio_base_deployment.helm_release.release
module.project_k8s_cluster_helm_istio_cni_deployment.helm_release.release
module.project_k8s_cluster_helm_istio_discovery_deployment.helm_release.release
module.project_k8s_cluster_helm_istio_gateway_deployment.helm_release.release
module.project_k8s_cluster_helm_istio_ztunnel_deployment.helm_release.release
module.project_k8s_istio_gw_routes["grafana"].ansible_playbook.playbook
module.project_k8s_istio_gw_routes["prometheus"].ansible_playbook.playbook
module.project_k8s_local_sensitive_file_kube_config.local_sensitive_file.file
module.project_knative_dns_records["knative"].cloudflare_dns_record.dns_record
module.project_main_nodes["haProxyLB"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["haProxyLB"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["master01"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["master01"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["master02"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["master02"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["master03"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["master03"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["worker01"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["worker01"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["worker02"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["worker02"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_main_nodes["worker03"].data.azurerm_client_config.cognitive_account
module.project_main_nodes["worker03"].azurerm_linux_virtual_machine.linux_virtual_machine
module.project_network_security_group.azurerm_network_security_group.network_security_group
module.project_nodes_availability_set.azurerm_availability_set.availability_set
module.project_nodes_network_interfaces["haProxyLB"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["master01"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["master02"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["master03"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["worker01"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["worker02"].azurerm_network_interface.network_interface
module.project_nodes_network_interfaces["worker03"].azurerm_network_interface.network_interface
module.project_nodes_public_ips["haProxyLB"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["master01"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["master02"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["master03"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["worker01"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["worker02"].azurerm_public_ip.public_ip
module.project_nodes_public_ips["worker03"].azurerm_public_ip.public_ip
module.project_rbac_worker_nodes["worker01"].azurerm_role_assignment.role_assignment
module.project_rbac_worker_nodes["worker02"].azurerm_role_assignment.role_assignment
module.project_rbac_worker_nodes["worker03"].azurerm_role_assignment.role_assignment
module.project_resource_group.azurerm_resource_group.resource_group
module.project_storage_account.data.azurerm_client_config.storage_account
module.project_storage_account.azurerm_storage_account.storage_account
module.project_storage_account_container["admin"].azurerm_storage_container.storage_container
module.project_storage_account_container["chunks"].azurerm_storage_container.storage_container
module.project_storage_account_container["openwebui"].azurerm_storage_container.storage_container
module.project_storage_account_container["ruler"].azurerm_storage_container.storage_container
module.project_virtual_network.azurerm_virtual_network.virtual_network
module.project_virtual_network_subnet.azurerm_subnet.subnet
````

Example: Remove all Instances of a Resource

````bash
$ tofu -chdir=IaC/CustomKubernetesAzure/tf state rm module.project_k8s_cluster_helm_deployment\[\"promtail\"\].helm_release.release
Removed module.project_k8s_cluster_helm_deployment["promtail"].helm_release.release
Successfully removed 1 resource instance(s).
````

Example show helm values:

````bash
$ helm show values headlamp/headlamp
````

#### Headlamp Token

[Create a Service Account token](https://headlamp.dev/docs/latest/installation/#create-a-service-account-token)

Create a Service Account:
````bash
kubectl -n kube-system create serviceaccount headlamp-admin --kubeconfig IaC/CustomKubernetesAzure/tf/kube/config
````

Give admin rights to the account:
````bash
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin --kubeconfig IaC/CustomKubernetesAzure/tf/kube/config
````

Create the token using the following command:
````bash
kubectl create token headlamp-admin -n kube-system --kubeconfig IaC/CustomKubernetesAzure/tf/kube/config
````

#### Viewing Secrets in K8s

If the user needs to debug, view or whatever reason to view a secret it can be completed with the following way:

````bash
$ kubectl get secrets azure-cloud-provider -n kube-system -o jsonpath='{.data.cloud-config}' --kubeconfig IaC/CustomKubernetesAzure/tf/kube/config | base64 -d
````

#### Ansible Debugging modules

If the user desires to debug a module (Ansible role) for testing purposes the syntax should be the following:

````bash
ansible-playbook -i <remote node IP>, IaC/k8s/tf/playbook.yml --tags ping
````

The user needs to have the role included in ``IaC/k8s/tf/playbook.yml`` file before using the tags.

#### Ansible Vault

In order for the user to use the `ansible.cfg` file, the user needs to navigate to the directory that the file is
located. Sample of code:

````bash
$ cd IaC/k8s/tf/
````

If the user desires to use encrypted files on the repository we need to encrypt the file. Sample of code:

````bash
user@hostname:~/IaC/CustomKubernetesAzure/tf$ ansible-vault encrypt vault/vault.yml
````

If the user desires to view encrypted files on the repository. Sample of code:

````bash
user@hostname:~/IaC/CustomKubernetesAzure/tf$ ansible-vault view vault/vault.yml
````

If the user desires to edit encrypted files on the repository. Sample of code:

````bash
user@hostname:~/IaC/CustomKubernetesAzure/tf$ ansible-vault edit vault/vault.yml
````

#### Troubleshooting Cloud-Init

If the VM once provisioned is not started then the user can view the logs as to what went wrong. Sample of code:

````bash
$ cloud-init status --wait
status: error
````

As a next step the user can look for the error. Sample of code:

````bash
$ sudo systemctl status cloud-init-local.service cloud-init-network.service cloud-config.service cloud-final.service
Unit cloud-init-network.service could not be found.
● cloud-init-local.service - Cloud-init: Local Stage (pre-network)
     Loaded: loaded (/lib/systemd/system/cloud-init-local.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2026-01-11 17:28:07 UTC; 5min ago
   Main PID: 601 (code=exited, status=0/SUCCESS)
        CPU: 1.041s

Jan 11 17:28:06 linuxhaproxy systemd[1]: Starting Cloud-init: Local Stage (pre-network)...
Jan 11 17:28:07 linuxhaproxy cloud-init[612]: Cloud-init v. 25.2-0ubuntu1~22.04.1 running 'init-local' at Sun, 11 Jan 2026 17:28:07 +0000. Up 8.66 seconds.
Jan 11 17:28:07 linuxhaproxy systemd[1]: Finished Cloud-init: Local Stage (pre-network).

● cloud-config.service - Cloud-init: Config Stage
     Loaded: loaded (/lib/systemd/system/cloud-config.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2026-01-11 17:28:12 UTC; 5min ago
   Main PID: 811 (code=exited, status=0/SUCCESS)
      Tasks: 0 (limit: 4530)
     Memory: 172.0K
        CPU: 791ms
     CGroup: /system.slice/cloud-config.service

Jan 11 17:28:11 linuxhaproxy systemd[1]: Starting Cloud-init: Config Stage...
Jan 11 17:28:12 linuxhaproxy cloud-init[816]: Cloud-init v. 25.2-0ubuntu1~22.04.1 running 'modules:config' at Sun, 11 Jan 2026 17:28:12 +0000. Up 13.62 seconds.
Jan 11 17:28:12 linuxhaproxy systemd[1]: Finished Cloud-init: Config Stage.

× cloud-final.service - Cloud-init: Final Stage
     Loaded: loaded (/lib/systemd/system/cloud-final.service; enabled; vendor preset: enabled)
     Active: failed (Result: exit-code) since Sun 2026-01-11 17:28:27 UTC; 4min 55s ago
    Process: 817 ExecStart=/usr/bin/cloud-init modules --mode=final (code=exited, status=1/FAILURE)
   Main PID: 817 (code=exited, status=1/FAILURE)
        CPU: 12.918s

Jan 11 17:28:27 linuxhaproxy cloud-init[821]: Failed to restart haproxy.service: Unit haproxy.service not found.
Jan 11 17:28:27 linuxhaproxy cloud-init[821]: 2026-01-11 17:28:27,399 - cc_scripts_user.py[WARNING]: Failed to run module scripts-user (scripts in /var/lib/cloud/instance/scripts)
Jan 11 17:28:27 linuxhaproxy cloud-init[821]: 2026-01-11 17:28:27,404 - log_util.py[WARNING]: Running module scripts-user (<module 'cloudinit.config.cc_scripts_user' from '/usr/lib/python3/dist-packages/cloudin>
Jan 11 17:28:27 linuxhaproxy cloud-init[1435]: 3072 SHA256:10UxuNFuQFeqCKu4/Pp7qZoR3IvVQwNtBslqKhjJFao root@linuxhaproxy (RSA)
Jan 11 17:28:27 linuxhaproxy cloud-init[1436]: -----END SSH HOST KEY FINGERPRINTS-----
Jan 11 17:28:27 linuxhaproxy cloud-init[821]: Cloud-init v. 25.2-0ubuntu1~22.04.1 finished at Sun, 11 Jan 2026 17:28:27 +0000. Datasource DataSourceHetzner.  Up 28.94 seconds
Jan 11 17:28:27 linuxhaproxy systemd[1]: cloud-final.service: Main process exited, code=exited, status=1/FAILURE
Jan 11 17:28:27 linuxhaproxy systemd[1]: cloud-final.service: Failed with result 'exit-code'.
Jan 11 17:28:27 linuxhaproxy systemd[1]: Failed to start Cloud-init: Final Stage.
Jan 11 17:28:27 linuxhaproxy systemd[1]: cloud-final.service: Consumed 12.918s CPU time.
````

More information can be found from the official documentation [Cloud-init did not run](https://cloudinit.readthedocs.io/en/latest/howto/debugging.html#cloud-init-did-not-run).

#### Important Requirements

The requirements are the following:

- TF installed
- docker daemon running
- The user which will be used to create the resources should have enough permissions (sample as owner or custom RBAC
  role) to create / assign README access on the Subscription level and also Resource Group level. More information can
  be found on the Microsoft
  forum [Can't deploy Azure Open AI models due "No quota is available for this deployment. You can request for more quota."](https://learn.microsoft.com/en-us/answers/questions/1339528/cant-deploy-azure-open-ai-models-due-no-quota-is-a)
