from diagrams.azure.compute import VM
from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.iac import Ansible, Terraform
from diagrams.onprem.network import Haproxy, Nginx
from diagrams.generic.os import RedHat, Debian, Suse, Ubuntu, LinuxGeneral

with ((((Diagram("Low Level Design - Azure custom Virtual Machine(s) Infrastructure",
                 show=False,
                 direction="TB",
                 filename="lldInfraK8sCustom"))))):
    terraform = Terraform("Terraform")
    ansible = Ansible("Ansible")
    vm = VM("Azure Virtual Machine")

    os = [RedHat("Red Hat Enterprise Linux"),
          LinuxGeneral("CoreOS"),
          Debian("Debian"),
          LinuxGeneral("Oracle Linux"),
          Suse("SUSE Linux Enterprise"),
          Suse("openSUSE"),
          Ubuntu("Ubuntu")]

    nginx = Nginx("NGINX LB")
    haproxy = Haproxy("HAProxy LB")

    terraform >> Edge(color="black") >> vm
    vm >> Edge(color="black") >> os
    os >> Edge(color="black") >> ansible
    ansible >> Edge(color="black") >> haproxy
    ansible >> Edge(color="black") >> nginx
