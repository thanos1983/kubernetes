from diagrams.azure import network
from diagrams.custom import Custom
from diagrams.oci.connectivity import VPN
from diagrams import Diagram, Cluster, Edge
from diagrams.k8s.infra import Master, Node
from diagrams.onprem.network import Haproxy
from diagrams.k8s.storage import StorageClass, PersistentVolume, PersistentVolumeClaim

with (((Diagram("High Level Design - On Premise K8s Infrastructure with External AI",
                show=False,
                # direction="TB",
                filename="onlineAI",
                # graph_attr={"bgcolor": "transparent"}
                )))):
    with Cluster("On Premise - Internal Zone (Offline)"):
        onPremGateWay = VPN("OnPremise GateWay")
        loadBalancer = Haproxy("HAProxy LB")
        loadBalancer >> Edge(color="firebrick", style="dashed") << onPremGateWay  # label="Port: 80, 443"

        with Cluster("Persistent Storage"):
            storageClass = StorageClass("StorageClass")
            persistentVolume = PersistentVolume("PersistentVolume")
            persistentVolumeClaim = PersistentVolumeClaim("PersistentVolumeClaim")

        with Cluster("Worker Node(s) (subnet)"):
            workerNodes = [Node("Worker 1st"),
                           Node("Worker 2nd"),
                           Node("Worker 3rd"),
                           Node("Worker Nth")]

        with Cluster("Master Node(s) Cluster (subnet)"):
            masterNodes = [Master("Control Plane 1st"),
                           Master("Control Plane 2nd"),
                           Master("Control Plane 3rd")]

    workerNodes >> Edge(color="darkblue", style="dashed") << loadBalancer
    loadBalancer >> Edge(color="darkblue", style="dashed") << masterNodes

    storageClass >> Edge(color="darkblue", style="dashed") >> persistentVolume
    persistentVolume >> Edge(color="darkblue", style="dashed") >> persistentVolumeClaim
    persistentVolumeClaim >> Edge(color="darkblue", style="dashed") << workerNodes

    with Cluster("Azure Cloud Infrastructure"):
        with Cluster("Gateway Subnet"):
            azureGateway = network.VirtualNetworkGateways("Azure GateWay")
            onPremGateWay >> Edge(color="gray", label="IPSec IKE2 Tunnel", style="dashed", ) << azureGateway

            azureLocalGateway = network.LocalNetworkGateways("Local GateWay")
            azureGateway >> Edge(color="gray") << azureLocalGateway

        with Cluster("External Zone Subnet"):
            azureChatgpt = Custom("OpenAI", "./my_resources/chatgpt.png")
            azureLocalGateway >> Edge(color="gray") << azureChatgpt
