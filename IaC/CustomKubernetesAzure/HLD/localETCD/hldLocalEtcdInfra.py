from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.network import Haproxy
from diagrams.k8s.infra import Master, Node
from diagrams.azure.network import PublicIpAddresses
from diagrams.k8s.storage import StorageClass, PersistentVolume, PersistentVolumeClaim

with (((Diagram("High Level Design - Azure custom K8s Infrastructure",
                show=False,
                # direction="TB",
                filename="hldLocalEtcdInfra",
                graph_attr={"bgcolor": "transparent"})))):
    with Cluster("Azure Resources"):
        publicIp = PublicIpAddresses("Public IP")
        lb = Haproxy("HAProxy LB")

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

    storageClass >> Edge(color="darkblue", style="dashed") >> persistentVolume
    persistentVolume >> Edge(color="darkblue", style="dashed") >> persistentVolumeClaim
    persistentVolumeClaim >> Edge(color="darkblue", style="dashed") << workerNodes

    workerNodes >> Edge(color="darkblue", style="dashed") << lb
    lb >> Edge(color="darkblue", style="dashed") << masterNodes
    publicIp >> Edge(color="darkblue", style="dashed") << lb
