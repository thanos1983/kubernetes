from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.network import Haproxy
from diagrams.k8s.infra import Master, Node, ETCD
from diagrams.azure.network import PublicIpAddresses  # NetworkSecurityGroupsClassic

with (((Diagram("", # High Level Design - Azure custom K8s Infrastructure
                show=False,
                direction="TB",
                filename="hldExternalEtcdInfra")))):
    with Cluster("Azure Resources"):
        publicIp = PublicIpAddresses("Public IP")
        lb = Haproxy("HAProxy LB")

        with Cluster("Master Node(s) Cluster"):
            masterNodes = [Master("Control Plane 3"),
                           Master("Control Plane 1"),
                           Master("Control Plane 2")]

        with Cluster("ETCD Node(s) Cluster"):
            etcdNodes = [ETCD("Node 3"),
                         ETCD("Node 1"),
                         ETCD("Node 2")]

        with Cluster("Worker Node(s)"):
            workerNodes = [Node("Worker 3"),
                           Node("Worker nth"),
                           Node("Worker 1"),
                           Node("Worker 2")]

    publicIp >> Edge(color="darkblue", style="dashed") >> lb
    workerNodes >> Edge(color="darkblue", style="dashed") >> publicIp

    lb >> Edge(color="darkblue", style="dashed") >> masterNodes
    lb >> Edge(color="darkblue", style="dashed") >> etcdNodes
