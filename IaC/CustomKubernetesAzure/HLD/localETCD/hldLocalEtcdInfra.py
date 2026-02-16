from diagrams.custom import Custom
from diagrams.onprem.ci import Jenkins
from diagrams.onprem.logging import Loki
from diagrams.onprem.tracing import Tempo
from diagrams.azure.devops import Pipelines
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.network import Haproxy
from diagrams.k8s.infra import Master, Node
from diagrams.azure.general import Twousericon
from diagrams.onprem.iac import Terraform, Ansible
from diagrams.onprem.network import Internet, Istio
from diagrams.k8s.ecosystem import ExternalDns, Helm
from diagrams.azure.network import PublicIpAddresses
from diagrams.onprem.monitoring import Prometheus, Grafana
from diagrams.azure.compute import OsImages, ContainerRegistries
from diagrams.onprem.certificates import CertManager, LetsEncrypt
from diagrams.k8s.storage import StorageClass, PersistentVolume, PersistentVolumeClaim

with (((Diagram("High Level Design - Azure custom K8s Infrastructure",
                show=False,
                direction="TB",
                filename="hldLocalEtcdInfra",
                graph_attr={"bgcolor": "transparent"})))):
    publicWeb = Internet("World Wirde Web")
    devopsEngineers = Twousericon("DevOps Engineers")
    cliApplications = OsImages("Client Application(s)")

    with Cluster("Infrastructure Tools"):
        infraTools = [Helm("Helm"),
                      Ansible("Ansible"),
                      Terraform("Terraform")]

    with Cluster("Azure Resources"):
        lb = Haproxy("HAProxy LB")
        publicIp = PublicIpAddresses("Public IP")
        publicWeb >> Edge(label="TLS") << lb
        infraTools >> Edge(label="TLS") << lb
        devopsEngineers >> Edge(label="TLS") << lb
        cliApplications >> Edge(label="TLS") << lb

        with Cluster("Azure Virtual Network"):
            azureContainerRegistry = ContainerRegistries("Azure Container Registry")
            azureContainerRegistry << Edge(label="Outbound TLS") << lb

            with Cluster("Mutual Transport Layer Security"):
                istioGateway = Istio("ISTIO Ingress Gateway")
                istioKnative = Custom("ISTIO Knative", "./my_resources/knative.png")

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

            with Cluster("Worker Node(s) (subnet)"):
                workerNodes = [Node("Worker 1st"),
                               Node("Worker 2nd"),
                               Node("Worker 3rd"),
                               Node("Worker Nth")]

            with Cluster("Master Node(s) Cluster (subnet)"):
                masterNodes = [Master("Control Plane 1st"),
                               Master("Control Plane 2nd"),
                               Master("Control Plane 3rd")]

            with Cluster("Persistent Storage"):
                storageClass = StorageClass("StorageClass")
                persistentVolume = PersistentVolume("PersistentVolume")
                persistentVolumeClaim = PersistentVolumeClaim("PersistentVolumeClaim")

            with Cluster("Pipelines Deployments"):
                pipelineDeployments = [Jenkins("Jenkins Pipelines"),
                                       Pipelines("Azure DevOps Pipelines")]

    devopsEngineers >> Edge(abel="TLS", style="dotted")<< pipelineDeployments

    storageClass >> Edge(color="darkblue", style="dashed") >> persistentVolume
    persistentVolume >> Edge(color="darkblue", style="dashed") >> persistentVolumeClaim
    persistentVolumeClaim >> Edge(color="darkblue", style="dashed") << workerNodes

    workerNodes >> Edge(color="darkblue", style="dashed") << lb
    lb >> Edge(color="darkblue", style="dashed") << masterNodes
    publicIp >> Edge(color="darkblue", style="dashed") << lb

    istioGateway >> Edge(style="dotted") << grafanaToolsStack
    workerNodes >> Edge(style="dotted") << istioGateway >> Edge(style="dotted") << necessaryTools
    istioKnative >> Edge(style="dotted") << grafanaToolsStack
    workerNodes >> Edge(style="dotted") << istioKnative >> Edge(style="dotted") << necessaryTools
