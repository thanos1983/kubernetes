from diagrams.custom import Custom
from diagrams.k8s.infra import Node
from diagrams.onprem.ci import Jenkins
from diagrams.onprem.logging import Loki
from diagrams.onprem.tracing import Tempo
from diagrams.k8s.controlplane import API
from diagrams import Diagram, Cluster, Edge
from diagrams.azure.devops import Pipelines
from diagrams.azure.general import Twousericon
from diagrams.onprem.iac import Terraform, Ansible
from diagrams.azure.storage import StorageAccounts
from diagrams.azure.identity import ActiveDirectory
from diagrams.onprem.network import Internet, Istio
from diagrams.k8s.ecosystem import ExternalDns, Helm
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.onprem.certificates import CertManager, LetsEncrypt
from diagrams.azure.network import PublicIpAddresses, LoadBalancers
from diagrams.azure.compute import ContainerRegistries, KubernetesServices, OsImages

with (((Diagram("High Level Design - Azure Kubernetes Service Infrastructure",
                show=False,
                direction="TB",
                filename="hldAzureKubernetesService",
                graph_attr={"bgcolor": "transparent"})))):
    publicWeb = Internet("World Wirde Web")
    devopsEngineers = Twousericon("DevOps Engineers")
    cliApplications = OsImages("Client Application(s)")

    with Cluster("Infrastructure Tools"):
        infraTools = [Helm("Helm"),
                      Ansible("Ansible"),
                      Terraform("Terraform")]

    with Cluster("Azure Resources"):
        azureLoadBalancer = LoadBalancers("Azure LoadBalancer")
        publicWeb >> Edge(label="TLS") << azureLoadBalancer
        activeDirectory = ActiveDirectory("Azure ActiveDirectory")

        with Cluster("Azure Virtual Network"):
            azureContainerRegistry = ContainerRegistries("Azure Container Registry")

            with Cluster("Azure Virtual Network Subnet for AKS"):
                with Cluster("Azure Kubernetes Service (AKS) Resources"):
                    aks = KubernetesServices("Azure Kubernetes Service (AKS)")
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
                                         Tempo("Tempo"),
                                         Grafana("Grafana"),
                                         Prometheus("Prometheus"),
                                         Custom("Alloy", "./my_resources/alloy.png")]

                with Cluster("Pipelines Deployments"):
                    pipelineDeployments = [Jenkins("Jenkins Pipelines"),
                                           Pipelines("Azure DevOps Pipelines")]

                apiControlplane = API("Kubernetes API")
                istioGateway = Istio("ISTIO Ingress Gateway")
                storageAccount = StorageAccounts("Azure StorageAccount")
                azureContainerRegistry << Edge(label="Outbound TLS") << workerNodes
                devopsEngineers >> pipelineDeployments >> activeDirectory >> azureLoadBalancer >> Edge(abel="TLS",
                                                                                                       style="dotted") << istioGateway
                istioGateway >> Edge(label="mutual TLS", style="dotted") << grafanaToolsStack
                devopsEngineers >> activeDirectory >> Edge(
                    label="TLS") >> apiControlplane >> workerNodes >> storageAccount
                cliApplications >> activeDirectory << Edge(abel="mutual TLS", style="dotted") >> istioGateway
                workerNodes >> Edge(label="mutual TLS", style="dotted") << istioGateway >> Edge(label="mutual TLS",
                                                                                                style="dotted") << necessaryTools
