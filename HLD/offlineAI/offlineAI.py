from diagrams.oci.connectivity import VPN
from diagrams import Diagram, Cluster, Edge
from diagrams.k8s.infra import Master, Node
from diagrams.onprem.network import Haproxy
from diagrams.k8s.storage import StorageClass, PersistentVolume, PersistentVolumeClaim

with (((Diagram("High Level Design - On Premise K8s Infrastructure with Internal AI",
                show=False,
                direction="TB",
                filename="offlineAI",
                graph_attr={"bgcolor": "transparent"})))):
    with Cluster("On Premise - Internal Zone (Offline)"):
        loadBalancer = Haproxy("HAProxy LB")

        with Cluster("Worker Node(s) (subnet)"):
            workerNodes = [Node("Worker 1st"),
                           Node("Worker 2nd"),
                           Node("Worker 3rd"),
                           Node("Worker Nth"),
                           Node("Worker with GPU 1st"),
                           Node("Worker with GPU 2nd"),
                           Node("Worker with GPU Nth")]

        with Cluster("Persistent Storage"):
            storageClass = StorageClass("StorageClass")
            persistentVolume = PersistentVolume("PersistentVolume")
            persistentVolumeClaim = PersistentVolumeClaim("PersistentVolumeClaim")

        with Cluster("Master Node(s) Cluster (subnet)"):
            masterNodes = [Master("Control Plane 1st"),
                           Master("Control Plane 2nd"),
                           Master("Control Plane 3rd")]

    storageClass >> Edge(color="darkblue", style="dashed") >> persistentVolume
    persistentVolume >> Edge(color="darkblue", style="dashed") >> persistentVolumeClaim
    persistentVolumeClaim >> Edge(color="darkblue", style="dashed") << workerNodes

    workerNodes >> Edge(color="darkblue", style="dashed") << loadBalancer
    loadBalancer >> Edge(color="darkblue", style="dashed") << masterNodes
