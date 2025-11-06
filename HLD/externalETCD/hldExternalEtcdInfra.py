from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.network import Haproxy
from diagrams.k8s.infra import Master, Node, ETCD
from diagrams.azure.network import PublicIpAddresses
from diagrams.k8s.storage import StorageClass, PersistentVolume, PersistentVolumeClaim

with (((Diagram("High Level Design - Azure custom K8s Infrastructure",
                show=False,
                # direction="TB",
                filename="hldExternalEtcdInfra",
                graph_attr={"bgcolor": "transparent"})))):
    with Cluster("Azure Resources"):
        publicIp = PublicIpAddresses("Public IP")
        lb = Haproxy("HAProxy LB")

        with Cluster("Master Node(s) Cluster"):
            masterNodes = [Master("Control Plane 3rd"),
                           Master("Control Plane 2nd"),
                           Master("Control Plane 1st")]

        with Cluster("ETCD Node(s) Cluster"):
            etcdNodes = [ETCD("ETCD 3rd"),
                         ETCD("ETCD 2nd"),
                         ETCD("ETCD 1st")]

        with Cluster("Worker Node(s)"):
            workerNodes = [Node("Worker Nth"),
                           Node("Worker 3rd"),
                           Node("Worker 2nd"),
                           Node("Worker 1st")]

        with Cluster("Persistent Storage"):
            storageClass = StorageClass("StorageClass")
            persistentVolume = PersistentVolume("PersistentVolume")
            persistentVolumeClaim = PersistentVolumeClaim("PersistentVolumeClaim")

    storageClass >> Edge(color="darkblue", style="dashed") >> persistentVolume
    persistentVolume >> Edge(color="darkblue", style="dashed") >> persistentVolumeClaim
    persistentVolumeClaim >> Edge(color="darkblue", style="dashed") << workerNodes

    publicIp >> Edge(color="darkblue", style="dashed") << lb
    workerNodes >> Edge(color="darkblue", style="dashed") << lb

    lb >> Edge(color="darkblue", style="dashed") << masterNodes
    lb >> Edge(color="darkblue", style="dashed") << etcdNodes
