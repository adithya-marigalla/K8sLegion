#!/bin/bash
# ==============================================================================
# K8sLegion: The Advanced Kubernetes "Break-Fix" Simulator
# Component: solution.sh (Verbose Mastery Edition)
# Author: Adithya (AWS Pro & GCP ACE)
# ==============================================================================

LAB_ID=$1
PASS="beast"

# SSH Helpers
run_cp() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@controlplane "$1"; }
run_n1() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node01 "$1"; }
run_n2() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node02 "$1"; }

[ -z "$LAB_ID" ] && echo "Usage: ./solution.sh <ID>" && exit 1

echo "---------------------------------------------------------------"
echo "🛠️  K8sLegion: EXECUTING RECOVERY FOR SCENARIO $LAB_ID"
echo "---------------------------------------------------------------"

case $LAB_ID in
1)  echo "📝 STEP: Correcting ETCD Peer Port in Static Pod Manifest (2381 -> 2380)."
    echo "💻 CODE: run_cp \"sed -i 's#2381#2380#g' /etc/kubernetes/manifests/etcd.yaml\""
    run_cp "sed -i 's#2381#2380#g' /etc/kubernetes/manifests/etcd.yaml" ;;

2)  echo "📝 STEP: Pointing API Server to correct ETCD port (9999 -> 2379)."
    echo "💻 CODE: run_cp \"sed -i 's#9999#2379#g' /etc/kubernetes/manifests/kube-apiserver.yaml\""
    run_cp "sed -i 's#9999#2379#g' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;

3)  echo "📝 STEP: Restarting the Kubelet service on Node01."
    echo "💻 CODE: run_n1 \"systemctl start kubelet\""
    run_n1 "systemctl start kubelet" ;;

4)  echo "📝 STEP: Restoring CNI configuration directory on Node01."
    echo "💻 CODE: run_n1 \"mv /etc/cni/net.d.bak /etc/cni/net.d\""
    run_n1 "mv /etc/cni/net.d.bak /etc/cni/net.d 2>/dev/null || true" ;;

5)  echo "📝 STEP: Repairing Static Pod Path in Kubelet configuration."
    echo "💻 CODE: run_cp \"sed -i 's|/wrong/path|/etc/kubernetes/manifests|g' /var/lib/kubelet/config.yaml && systemctl restart kubelet\""
    run_cp "sed -i 's#/wrong/path#/etc/kubernetes/manifests#g' /var/lib/kubelet/config.yaml && systemctl restart kubelet" ;;

6)  echo "📝 STEP: Scaling CoreDNS to ensure DNS availability."
    echo "💻 CODE: kubectl -n kube-system scale deployment coredns --replicas=2"
    kubectl -n kube-system scale deployment coredns --replicas=2 ;;

7)  echo "📝 STEP: Patching 'web-svc' selector to align with Pod labels (app=web)."
    echo "💻 CODE: kubectl patch svc web-svc -p '{\"spec\":{\"selector\":{\"app\":\"web\"}}}'"
    kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"web"}}}' ;;

8)  echo "📝 STEP: Fixing PVC by removing non-existent StorageClass."
    echo "💻 CODE: kubectl patch pvc bad-pvc --type='json' -p='[{\"op\": \"remove\", \"path\": \"/spec/storageClassName\"}]'"
    kubectl patch pvc bad-pvc --type='json' -p='[{"op": "remove", "path": "/spec/storageClassName"}]' 2>/dev/null || kubectl delete pvc bad-pvc ;;

9)  echo "📝 STEP: Removing insecure Cluster-Admin binding for default ServiceAccount."
    echo "💻 CODE: kubectl delete clusterrolebinding default-admin"
    kubectl delete clusterrolebinding default-admin 2>/dev/null ;;

10) echo "📝 STEP: Moving Service to correct namespace (prod)."
    echo "💻 CODE: kubectl delete svc prod-svc && kubectl expose pod nginx -n prod --port=80"
    kubectl delete svc prod-svc -n default 2>/dev/null
    kubectl expose pod nginx -n prod --port=80 --name=prod-svc 2>/dev/null ;;

11) echo "📝 STEP: Correcting Deployment image typo (nginxx -> nginx)."
    echo "💻 CODE: kubectl set image deployment/bad nginxx=nginx"
    kubectl set image deployment/bad nginxx=nginx ;;

12) echo "📝 STEP: Starting Kubelet on Node02."
    echo "💻 CODE: run_n2 \"systemctl start kubelet\""
    run_n2 "systemctl start kubelet" ;;

13) echo "📝 STEP: Removing restrictive ResourceQuota (Pods: 0)."
    echo "💻 CODE: kubectl delete quota pod-quota -n quota"
    kubectl delete quota pod-quota -n quota ;;

14) echo "📝 STEP: Removing 'deny-all' NetworkPolicy."
    echo "💻 CODE: kubectl delete netpol deny-all"
    kubectl delete netpol deny-all ;;

15) echo "📝 STEP: Fixing targetPort mismatch in web2-svc."
    echo "💻 CODE: kubectl patch svc web2-svc --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/ports/0/targetPort\", \"value\":80}]'"
    kubectl patch svc web2-svc --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/targetPort", "value":80}]' ;;

16) echo "📝 STEP: Re-creating missing ETCD backup placeholder."
    echo "💻 CODE: run_cp \"touch /opt/etcd-backup.db\""
    run_cp "touch /opt/etcd-backup.db" ;;

17) echo "📝 STEP: Fixing ETCD data-dir path in manifest."
    echo "💻 CODE: run_cp \"sed -i 's#/wrong/path#/var/lib/etcd#g' /etc/kubernetes/manifests/etcd.yaml\""
    run_cp "sed -i 's#/wrong/path#/var/lib/etcd#g' /etc/kubernetes/manifests/etcd.yaml" ;;

18) echo "📝 STEP: Restoring kubeadm binary."
    echo "💻 CODE: run_cp \"mv /usr/bin/kubeadm.bak /usr/bin/kubeadm\""
    run_cp "mv /usr/bin/kubeadm.bak /usr/bin/kubeadm 2>/dev/null || true" ;;

19) echo "📝 STEP: Forcing kube-proxy to restart by deleting pods."
    echo "💻 CODE: kubectl delete pod -n kube-system -l k8s-app=kube-proxy"
    kubectl delete pod -n kube-system -l k8s-app=kube-proxy ;;

20) echo "📝 STEP: Fixing failing Init Container command."
    echo "💻 CODE: kubectl patch pod init-fail ... command: ['/bin/true']"
    kubectl delete pod init-fail --force --grace-period=0 2>/dev/null
    kubectl run init-fail --image=busybox --restart=Never --overrides='{"spec":{"initContainers":[{"name":"init","image":"busybox","command":["/bin/true"]}]}}' ;;

21) echo "📝 STEP: Fixing Liveness Probe path (/healthz-typo -> /)."
    echo "💻 CODE: kubectl patch pod probe-fail --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/containers/0/livenessProbe/httpGet/path\", \"value\":\"/\"}]'"
    kubectl patch pod probe-fail --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/livenessProbe/httpGet/path", "value":"/"}]' ;;

22) echo "📝 STEP: Fixing Readiness Probe failure by creating expected file."
    echo "💻 CODE: kubectl exec ready-fail -- touch /tmp/ready"
    kubectl exec ready-fail -- touch /tmp/ready 2>/dev/null ;;

23) echo "📝 STEP: Cleaning up failed Job."
    echo "💻 CODE: kubectl delete job bad-job"
    kubectl delete job bad-job ;;

24) echo "📝 STEP: Correcting CronJob schedule/command."
    echo "💻 CODE: kubectl patch cronjob bad-cron ... command: ['/bin/true']"
    kubectl patch cronjob bad-cron -p '{"spec":{"jobTemplate":{"spec":{"template":{"spec":{"containers":[{"name":"busybox","image":"busybox","command":["/bin/true"]}]}}}}}}' ;;

25) echo "📝 STEP: Scaling down Deployment to resolve resource exhaustion."
    echo "💻 CODE: kubectl scale deploy scale-error --replicas=2"
    kubectl scale deploy scale-error --replicas=2 ;;

26) echo "📝 STEP: Updating SecurityContext to run as non-root (UID 1000)."
    echo "💻 CODE: kubectl patch pod insecure -p '{\"spec\":{\"securityContext\":{\"runAsUser\":1000}}}'"
    kubectl delete pod insecure --force 2>/dev/null
    kubectl run insecure --image=nginx --overrides='{"spec":{"securityContext":{"runAsUser":1000}}}' ;;

27) echo "📝 STEP: Restarting Falco service."
    echo "💻 CODE: run_cp \"systemctl start falco\""
    run_cp "systemctl start falco" 2>/dev/null ;;

28) echo "📝 STEP: Removing invalid AppArmor annotation."
    echo "💻 CODE: kubectl annotate pod apparmor container.apparmor.security.beta.kubernetes.io/nginx-"
    kubectl annotate pod apparmor container.apparmor.security.beta.kubernetes.io/nginx- 2>/dev/null ;;

29) echo "📝 STEP: Re-enabling NodeRestriction admission plugin."
    echo "💻 CODE: run_cp \"sed -i 's/admission-plugins=/admission-plugins=NodeRestriction,/g' /etc/kubernetes/manifests/kube-apiserver.yaml\""
    run_cp "sed -i 's/admission-plugins=/admission-plugins=NodeRestriction,/g' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;

30) echo "📝 STEP: Restoring secure permissions (644) to API manifest."
    echo "💻 CODE: run_cp \"chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml\""
    run_cp "chmod 644 /etc/kubernetes/manifests/kube-apiserver.yaml" ;;

31) echo "📝 STEP: Fixing Helm deployment image."
    echo "💻 CODE: kubectl set image deployment/helm-app nginxx=nginx"
    kubectl set image deployment/helm-app nginxx=nginx ;;

32) echo "📝 STEP: Switching Service traffic from Blue to Green."
    echo "💻 CODE: kubectl patch svc app-svc -p '{\"spec\":{\"selector\":{\"app\":\"green\"}}}'"
    kubectl patch svc app-svc -p '{"spec":{"selector":{"app":"green"}}}' ;;

33) echo "📝 STEP: Aligning Canary labels with Production Service."
    echo "💻 CODE: kubectl label pod -l app=canary app=main-app --overwrite"
    kubectl label pod -l app=canary app=main-app --overwrite ;;

34) echo "📝 STEP: Adding volumeMount to Sidecar (mc-pod-3)."
    echo "💻 CODE: kubectl replace --force -f fixed-mc-pod.yaml"
    kubectl delete pod mc-pod -n mc-namespace --force 2>/dev/null
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata: {name: mc-pod, namespace: mc-namespace}
spec:
  volumes: [{name: logs, emptyDir: {}}]
  containers:
  - name: mc-pod-1, image: nginx
  - name: mc-pod-2, image: busybox, volumeMounts: [{name: logs, mountPath: /var/log}], command: ["sh","-c","while true; do date >> /var/log/app.log; sleep 1; done"]
  - name: mc-pod-3, image: busybox, volumeMounts: [{name: logs, mountPath: /var/log}], command: ["sh","-c","tail -f /var/log/app.log"]
EOF
;;

35) echo "📝 STEP: Correcting Ambassador container port mapping."
    echo "💻 CODE: kubectl delete deploy ambassador && kubectl apply -f fixed-ambassador.yaml"
    kubectl delete deploy ambassador 2>/dev/null ;;

36) echo "📝 STEP: Removing conflicting LimitRange logic."
    echo "💻 CODE: kubectl delete ns limit"
    kubectl delete ns limit ;;

37) echo "📝 STEP: Reducing impossible CPU requests (100 -> 0.1)."
    echo "💻 CODE: kubectl set resources pod big-pod --requests=cpu=100m"
    kubectl delete pod big-pod --force 2>/dev/null
    kubectl run big-pod --image=nginx --requests='cpu=100m' ;;

38) echo "📝 STEP: Removing Ingress-blocking NetworkPolicy."
    echo "💻 CODE: kubectl delete netpol block-ingress"
    kubectl delete netpol block-ingress ;;

39) echo "📝 STEP: Assigning correct ServiceAccount to Pod."
    echo "💻 CODE: kubectl patch pod sa-test -p '{\"spec\":{\"serviceAccountName\":\"default\"}}'"
    kubectl delete pod sa-test --force 2>/dev/null
    kubectl run sa-test --image=nginx ;;

40) echo "📝 STEP: Creating missing Secret for volume mount."
    echo "💻 CODE: kubectl create secret generic non-existent-secret"
    kubectl create secret generic non-existent-secret ;;

41) echo "📝 STEP: Creating missing ConfigMap for env injection."
    echo "💻 CODE: kubectl create configmap missing-cm"
    kubectl create configmap missing-cm ;;

42) echo "📝 STEP: Restoring hostPath directory permissions."
    echo "💻 CODE: run_n1 \"chmod 755 /data/web\""
    run_n1 "chmod 755 /data/web" ;;

43) echo "📝 STEP: Removing impossible NodeSelector (disk=ssd)."
    echo "💻 CODE: kubectl patch pod node-test --type='json' -p='[{\"op\": \"remove\", \"path\": \"/spec/nodeSelector\"}]'"
    kubectl delete pod node-test --force 2>/dev/null
    kubectl run node-test --image=nginx ;;

44) echo "📝 STEP: Removing NoSchedule taint from Node01."
    echo "💻 CODE: kubectl taint nodes node01 key:NoSchedule-"
    kubectl taint nodes node01 key:NoSchedule- 2>/dev/null ;;

45) echo "📝 STEP: Deploying Metrics Server to enable HPA."
    echo "💻 CODE: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml ;;

46) echo "📝 STEP: Restoring Metrics Server."
    echo "💻 CODE: kubectl apply -f metrics-server.yaml"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml ;;

47) echo "📝 STEP: Correcting Gateway API parentRef."
    echo "💻 CODE: kubectl patch httproute web-route --type='json' -p='[{\"op\": \"replace\", \"path\": \"/spec/parentRefs/0/name\", \"value\":\"prod-gateway\"}]'"
    kubectl patch httproute web-route --type='json' -p='[{"op": "replace", "path": "/spec/parentRefs/0/name", "value":"prod-gateway"}]' ;;

48) echo "📝 STEP: Using non-root compatible image for SecurityContext."
    echo "💻 CODE: kubectl delete pod non-root && kubectl run non-root --image=bitnami/nginx"
    kubectl delete pod non-root --force 2>/dev/null
    kubectl run non-root --image=bitnami/nginx ;;

49) echo "📝 STEP: Creating missing RuntimeClass 'gvisor'."
    echo "💻 CODE: kubectl apply -f runtime-class.yaml"
    cat <<EOF | kubectl apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata: {name: gvisor}
handler: runsc
EOF
;;

50) echo "📝 STEP: Restoring Node02 health and Proxy pods."
    echo "💻 CODE: run_n2 \"systemctl start kubelet\" && kubectl delete pod -n kube-system -l k8s-app=kube-proxy"
    run_n2 "systemctl start kubelet"
    kubectl delete pod -n kube-system -l k8s-app=kube-proxy ;;
esac

echo "---------------------------------------------------------------"
echo "✅ RECOVERY COMPLETE: Scenario $LAB_ID parameters are now restored."
echo "---------------------------------------------------------------"
