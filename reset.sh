#!/bin/bash
# Master Lab Resetter - Adithya's 50-Lab Prep (2026 Edition)
LAB_ID=$1
PASS="beast"

# SSH Helpers
run_cp() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@controlplane "$1"; }
run_n1() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node01 "$1"; }
run_n2() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node02 "$1"; }

echo "🧹 Initializing Global Cleanup..."
# Remove common resources created across labs
kubectl delete deploy --all --force --grace-period=0 2>/dev/null
kubectl delete pod --all --force --grace-period=0 2>/dev/null
kubectl delete svc --all 2>/dev/null
kubectl delete pvc --all 2>/dev/null
kubectl delete netpol --all 2>/dev/null
kubectl delete hpa --all 2>/dev/null
kubectl delete job --all 2>/dev/null
kubectl delete cronjob --all 2>/dev/null
kubectl delete ns prod quota limit mc-namespace 2>/dev/null

case $LAB_ID in
1|2|5|17|29) 
    echo "🔄 Restoring Control Plane Manifests..."
    run_cp "sed -i 's#2381#2380#g' /etc/kubernetes/manifests/etcd.yaml"
    run_cp "sed -i 's#9999#2379#g' /etc/kubernetes/manifests/kube-apiserver.yaml"
    run_cp "sed -i 's#/wrong/path#/var/lib/etcd#g' /etc/kubernetes/manifests/etcd.yaml"
    run_cp "sed -i 's#/wrong/path#/etc/kubernetes/manifests#g' /var/lib/kubelet/config.yaml"
    run_cp "grep -q 'NodeRestriction' /etc/kubernetes/manifests/kube-apiserver.yaml || sed -i 's#admission-plugins=#admission-plugins=NodeRestriction,#g' /etc/kubernetes/manifests/kube-apiserver.yaml"
    run_cp "systemctl restart kubelet" ;;

3|4|42|44) 
    echo "🔄 Resetting Node01..."
    run_n1 "systemctl start kubelet"
    run_n1 "[ -d /etc/cni/net.d.bak ] && mv /etc/cni/net.d.bak /etc/cni/net.d"
    run_n1 "chmod 755 /data/web 2>/dev/null"
    kubectl taint nodes node01 key:NoSchedule- 2>/dev/null ;;

12|50) 
    echo "🔄 Resetting Node02..."
    run_n2 "systemctl start kubelet" ;;

6)  echo "🔄 Scaling CoreDNS back to default..."
    kubectl -n kube-system scale deployment coredns --replicas=2 ;;

9)  echo "🔄 Cleaning RBAC Bindings..."
    kubectl delete clusterrolebinding default-admin audit-fail 2>/dev/null ;;

16|18) 
    echo "🔄 Restoring missing binaries/backups..."
    run_cp "touch /opt/etcd-backup.db"
    run_cp "[ -f /usr/bin/kubeadm.bak ] && mv /usr/bin/kubeadm.bak /usr/bin/kubeadm" ;;

27) echo "🔄 Restarting Security Services..."
    run_cp "systemctl start falco" ;;

30) echo "🔄 Restoring Manifest Permissions..."
    run_cp "chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml" ;;

47) echo "🔄 Cleaning Gateway API Routes..."
    kubectl delete httproute web-route 2>/dev/null ;;

49) echo "🔄 Removing RuntimeClasses..."
    kubectl delete runtimeclass gvisor 2>/dev/null ;;
esac

echo "✅ Lab $LAB_ID Reset Complete. Ready for next scenario."
