#!/bin/bash
# Lab Validator - Automated Grading for Adithya's 50-Lab Prep
LAB_ID=$1
PASS="beast"

# SSH Helpers
run_cp() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@controlplane "$1"; }
run_n1() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node01 "$1"; }
run_n2() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node02 "$1"; }

check_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ LAB $LAB_ID: PARAMETERS MET"
        exit 0
    else
        echo "❌ LAB $LAB_ID: CONFIGURATION DRIFT DETECTED"
        exit 1
    fi
}

case $LAB_ID in
1) run_cp "grep -q '2380' /etc/kubernetes/manifests/etcd.yaml" ;;
2) run_cp "grep -q '2379' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;
3) run_n1 "systemctl is-active --quiet kubelet" ;;
4) run_n1 "[ -d /etc/cni/net.d ] && [ ! -d /etc/cni/net.d.bak ]" ;;
5) run_cp "grep -q '/etc/kubernetes/manifests' /var/lib/kubelet/config.yaml" ;;
6) [ "$(kubectl -n kube-system get deploy coredns -o jsonpath='{.spec.replicas}')" -ge 1 ] ;;
7) [ "$(kubectl get svc web-svc -o jsonpath='{.spec.selector.app}')" == "web" ] ;;
8) SC=$(kubectl get pvc bad-pvc -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
   [ "$SC" != "slow-manual" ] && [ -n "$SC" ] ;;
9) ! kubectl get clusterrolebinding default-admin 2>/dev/null ;;
10) [ "$(kubectl get svc prod-svc -n prod --no-headers 2>/dev/null | wc -l)" -eq 1 ] ;;
11) [ "$(kubectl get deploy bad -o jsonpath='{.spec.template.spec.containers[0].image}')" == "nginx" ] ;;
12) run_n2 "systemctl is-active --quiet kubelet" ;;
13) [ "$(kubectl get quota pod-quota -n quota -o jsonpath='{.spec.hard.pods}')" != "0" ] ;;
14) ! kubectl get netpol deny-all 2>/dev/null ;;
15) [ "$(kubectl get svc web2-svc -o jsonpath='{.spec.ports[0].targetPort}')" -eq 80 ] ;;
16) run_cp "[ -f /opt/etcd-backup.db ]" ;;
17) run_cp "grep -q '/var/lib/etcd' /etc/kubernetes/manifests/etcd.yaml" ;;
18) run_cp "[ -f /usr/bin/kubeadm ]" ;;
19) [ "$(kubectl -n kube-system get pods -l k8s-app=kube-proxy --no-headers | grep Running | wc -l)" -gt 0 ] ;;
20) [ "$(kubectl get pod init-fail -o jsonpath='{.spec.initContainers[0].command[0]}')" != "/bin/false" ] ;;
21) [ "$(kubectl get pod probe-fail -o jsonpath='{.spec.containers[0].livenessProbe.httpGet.path}')" == "/" ] ;;
22) [ "$(kubectl get pod ready-fail -o jsonpath='{.status.containerStatuses[0].ready}')" == "true" ] ;;
23) [ "$(kubectl get job bad-job -o jsonpath='{.status.succeeded}')" -ge 1 ] ;;
24) [ "$(kubectl get cronjob bad-cron -o jsonpath='{.spec.suspend}')" == "false" ] && [ "$(kubectl get cronjob bad-cron -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[0].command[0]}')" != "/bin/false" ] ;;
25) [ "$(kubectl get deploy scale-error -o jsonpath='{.spec.replicas}')" -le 10 ] ;;
26) [ "$(kubectl get pod insecure -o jsonpath='{.spec.securityContext.runAsUser}')" != "0" ] ;;
27) run_cp "systemctl is-active --quiet falco" ;;
28) [ -z "$(kubectl get pod apparmor -o jsonpath='{.metadata.annotations}')" ] || [[ "$(kubectl get pod apparmor -o jsonpath='{.metadata.annotations}')" != *"missing-profile"* ]] ;;
29) run_cp "grep -q 'NodeRestriction' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;
30) run_cp "[ \"\$(stat -c %a /etc/kubernetes/manifests/kube-apiserver.yaml)\" == \"644\" ]" ;;
31) [ "$(kubectl get deploy helm-app -o jsonpath='{.spec.template.spec.containers[0].image}')" == "nginx" ] ;;
32) [ "$(kubectl get svc app-svc -o jsonpath='{.spec.selector.app}')" == "green" ] ;;
33) kubectl get pod -l app=main-app --no-headers | grep -q "Running" && [ "$(kubectl get svc prod-svc -o jsonpath='{.spec.selector.app}')" == "main-app" ] ;;
34) [ "$(kubectl get pod mc-pod -n mc-namespace -o jsonpath='{.spec.containers[2].volumeMounts[0].name}')" == "logs" ] ;;
35) [ "$(kubectl get deploy ambassador -o jsonpath='{.spec.template.spec.containers[1].name}')" == "ambassador" ] ;;
36) ! kubectl get ns limit 2>/dev/null || [ "$(kubectl get limitrange cpu-limit -n limit -o jsonpath='{.spec.limits[0].min.cpu}')" == "100m" ] ;;
37) [ -z "$(kubectl get pod big-pod -o jsonpath='{.spec.containers[0].resources.requests.cpu}')" ] || [ "$(kubectl get pod big-pod -o jsonpath='{.spec.containers[0].resources.requests.cpu}')" != "100" ] ;;
38) ! kubectl get netpol block-ingress 2>/dev/null ;;
39) [ "$(kubectl get pod sa-test -o jsonpath='{.spec.serviceAccountName}')" != "missing-sa" ] ;;
40) [ "$(kubectl get pod secret-test -o jsonpath='{.status.phase}')" == "Running" ] ;;
41) [ "$(kubectl get pod cm-test -o jsonpath='{.status.phase}')" == "Running" ] ;;
42) run_n1 "[ \"\$(stat -c %a /data/web)\" != \"000\" ]" ;;
43) [ -z "$(kubectl get pod node-test -o jsonpath='{.spec.nodeSelector}')" ] ;;
44) [ -z "$(kubectl get node node01 -o jsonpath='{.spec.taints}')" ] ;;
45) kubectl get deploy metrics-server -n kube-system >/dev/null 2>&1 && [ "$(kubectl get hpa web -o jsonpath='{.status.currentCPUUtilizationPercentage}')" != "" ] ;;
46) kubectl get deploy metrics-server -n kube-system >/dev/null 2>&1 ;;
47) [ "$(kubectl get httproute web-route -o jsonpath='{.spec.parentRefs[0].name}')" == "prod-gateway" ] ;;
48) [ "$(kubectl get pod non-root -o jsonpath='{.status.phase}')" == "Running" ] ;;
49) kubectl get runtimeclass gvisor >/dev/null 2>&1 && [ "$(kubectl get pod gvisor-test -o jsonpath='{.spec.runtimeClassName}')" == "gvisor" ] ;;
50) run_n2 "systemctl is-active --quiet kubelet" && [ "$(kubectl -n kube-system get pods -l k8s-app=kube-proxy | grep Running | wc -l)" -gt 0 ] ;;
esac

check_result $?
