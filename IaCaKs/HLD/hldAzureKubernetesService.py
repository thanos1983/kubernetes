from diagrams.k8s.infra import Node
from diagrams.onprem.ci import Jenkins
from diagrams.onprem.logging import Loki
from diagrams.onprem.network import Istio
from diagrams.k8s.controlplane import API
from diagrams import Diagram, Cluster, Edge
from diagrams.azure.devops import Pipelines
from diagrams.azure.compute import OsImages
from diagrams.azure.general import Twousericon
from diagrams.onprem.iac import Terraform, Ansible
from diagrams.azure.storage import StorageAccounts
from diagrams.k8s.ecosystem import ExternalDns, Helm
from diagrams.azure.compute import ContainerRegistries
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.certificates import CertManager, LetsEncrypt
from diagrams.azure.network import PublicIpAddresses, LoadBalancers

with (((Diagram("High Level Design - Azure Kubernetes Service Infrastructure",
                show=False,
                # direction="TB",
                filename="hldAzureKubernetesService",
                graph_attr={"bgcolor": "transparent"})))):
    with Cluster("Azure Resources"):
        devopsEngineers = Twousericon("DevOps Engineers")
        cliApplications = OsImages("Client Application(s)")
        azureLoadBalancer = LoadBalancers("Azure LoadBalancer")

        with Cluster("Infrastructure Tools"):
            infraTools = [Helm("Helm"),
                          Ansible("Ansible"),
                          Terraform("Terraform")]

        with Cluster("Azure Virtual Network"):
            with Cluster("Azure Virtual Network Subnet for AKS"):
                workerNodes = [Node("Worker 3rd"),
                               Node("Worker 2nd"),
                               Node("Worker 1st"),
                               Node("Worker nth")]

                with Cluster("K8s Tools Stack"):
                    necessaryTools = [LetsEncrypt("LetsEncrypt"),
                                      ExternalDns("ExternalDns"),
                                      CertManager("CertManager")]

                with Cluster("Grafana Stack"):
                    grafanaToolsStack = [Loki("Loki"),
                                         Grafana("Grafana"),
                                         Prometheus("Prometheus")]

                with Cluster("Pipelines Deployments"):
                    pipelineDeployments = [Jenkins("Jenkins Pipelines"),
                                           Pipelines("Azure DevOps Pipelines")]

                azureContainerRegistry = ContainerRegistries("Azure Container Registry")
                apiControlplane = API("Kubernetes API")
                istioGateway = Istio("ISTIO Ingress Gateway")
                storageAccount = StorageAccounts("Azure StorageAccount")
                azureContainerRegistry << Edge(label="Outbound TLS") << workerNodes
                devopsEngineers >> pipelineDeployments >> azureLoadBalancer
                istioGateway >> Edge(label="mutual TLS", style="dotted") << grafanaToolsStack
                devopsEngineers >> azureLoadBalancer >> Edge(
                    label="TLS") >> apiControlplane >> workerNodes >> storageAccount
                cliApplications >> azureLoadBalancer << Edge(abel="mutual TLS", style="dotted") >> istioGateway
                workerNodes >> Edge(label="mutual TLS", style="dotted") << istioGateway >> Edge(label="mutual TLS",
                                                                                                style="dotted") << necessaryTools
