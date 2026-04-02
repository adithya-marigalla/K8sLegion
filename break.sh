#!/bin/bash
# Master Lab Breaker - Adithya's 50-Lab Parameterized Prep (2026 Edition)
LAB_ID=$1
PASS="beast"

# SSH Helpers
run_cp() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@controlplane "$1"; }
run_n1() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node01 "$1"; }
run_n2() { sshpass -p "$PASS" ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no root@node02 "$1"; }

case $LAB_ID in
1) echo "🧨 Req: ETCD Cluster Connectivity. Break: Peer port mismatch (2381)."
   run_cp "sed -i 's#2380#2381#g' /etc/kubernetes/manifests/etcd.yaml" ;;
2) echo "🧨 Req: API Server Backend. Break: API Server looking for ETCD on port 9999."
   run_cp "sed -i 's#2379#9999#g' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;
3) echo "🧨 Req: Node01 Operational. Break: Kubelet service stopped."
   run_n1 "systemctl stop kubelet" ;;
4) echo "🧨 Req: CNI Networking. Break: CNI config moved to .bak on Node01."
   run_n1 "mv /etc/cni/net.d /etc/cni/net.d.bak" ;;
5) echo "🧨 Req: Static Pods. Break: Kubelet config pointing to /wrong/path for manifests."
   run_cp "sed -i 's#/etc/kubernetes/manifests#/wrong/path#g' /var/lib/kubelet/config.yaml && systemctl restart kubelet" ;;
6) echo "🧨 Req: CoreDNS availability. Break: Deployment scaled to 0."
   kubectl -n kube-system scale deployment coredns --replicas=0 ;;
7) echo "🧨 Req: Svc 'web-svc' on port 80. Break: Service selector uses 'app=wrong'."
   kubectl create deploy web --image=nginx --replicas=2
   kubectl expose deploy web --port=80 --name=web-svc
   kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"wrong"}}}' ;;
8) echo "🧨 Req: Bound PVC 'bad-pvc'. Break: Requesting non-existent SC 'slow-manual'."
   cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata: {name: bad-pvc}
spec: {accessModes: [ReadWriteOnce], resources: {requests: {storage: 1Gi}}, storageClassName: slow-manual}
EOF
;;
9) echo "🧨 Req: Least Privilege. Break: 'default' SA bound to 'cluster-admin' role."
   kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --serviceaccount=default:default ;;
10) echo "🧨 Req: 'prod-svc' in namespace 'prod'. Break: Svc created in 'default' ns."
    kubectl create ns prod
    kubectl run nginx --image=nginx -n default
    kubectl expose pod nginx -n default --port=80 --name=prod-svc ;;
11) echo "🧨 Req: Deployment 'bad' running Nginx. Break: Image typo 'nginxx'."
    kubectl create deployment bad --image=nginxx ;;
12) echo "🧨 Req: Node02 Operational. Break: Kubelet service stopped."
    run_n2 "systemctl stop kubelet" ;;
13) echo "🧨 Req: ResourceQuota in 'quota' ns. Break: Pod limit set to '0'."
    kubectl create ns quota
    kubectl create quota pod-quota --hard=pods=0 -n quota
    kubectl create deploy stress --image=nginx -n quota ;;
14) echo "🧨 Req: Network Isolation. Break: Deny-all Policy blocking all traffic."
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all}
spec: {podSelector: {}, policyTypes: [Ingress, Egress]}
EOF
;;
15) echo "🧨 Req: Svc 'web2-svc' to port 80. Break: targetPort set to 8081."
    kubectl create deploy web2 --image=nginx --port=80
    kubectl expose deploy web2 --port=80 --target-port=8081 --name=web2-svc ;;
16) echo "🧨 Req: Disaster Recovery. Break: ETCD backup file deleted from /opt/."
    run_cp "rm -f /opt/etcd-backup.db" ;;
17) echo "🧨 Req: ETCD Persistence. Break: Data path set to /wrong/path in manifest."
    run_cp "sed -i 's#/var/lib/etcd#/wrong/path#g' /etc/kubernetes/manifests/etcd.yaml" ;;
18) echo "🧨 Req: Cluster Tools. Break: /usr/bin/kubeadm renamed to .bak."
    run_cp "mv /usr/bin/kubeadm /usr/bin/kubeadm.bak" ;;
19) echo "🧨 Req: Cluster Networking. Break: Kube-Proxy pods deleted manually."
    kubectl -n kube-system delete pod -l k8s-app=kube-proxy ;;
20) echo "🧨 Req: Pod 'init-fail' Readiness. Break: Init container command is '/bin/false'."
    kubectl run init-fail --image=busybox --restart=Never --overrides='{"spec":{"initContainers":[{"name":"init","image":"busybox","command":["/bin/false"]}]}}' ;;
21) echo "🧨 Req: Liveness Health. Break: httpGet path set to /healthz-typo."
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata: {name: probe-fail}
spec:
  containers: [{name: nginx, image: nginx, livenessProbe: {httpGet: {path: /healthz-typo, port: 80}}}]
EOF
;;
22) echo "🧨 Req: Readiness Health. Break: Readiness probe pointing to non-existent file."
    kubectl run ready-fail --image=nginx --overrides='{"spec":{"containers":[{"name":"nginx","image":"nginx","readinessProbe":{"exec":{"command":["ls","/tmp/ready"]}}}]}}' ;;
23) echo "🧨 Req: Successful Batch Job. Break: Job command exits with code 1."
    kubectl create job bad-job --image=busybox -- /bin/false ;;
24) echo "🧨 Req: Reliable CronJob. Break: Schedule set to every minute with failing command."
    kubectl create cronjob bad-cron --image=busybox --schedule='* * * * *' -- /bin/false ;;
25) echo "🧨 Req: Scaled Deployment. Break: Replicas set to 50 (Resource Exhaustion)."
    kubectl create deploy scale-error --image=nginx
    kubectl scale deploy scale-error --replicas=50 ;;
26) echo "🧨 Req: Non-Root Security. Break: runAsUser explicitly set to 0 (Root)."
    kubectl run insecure --image=nginx --overrides='{"spec":{"securityContext":{"runAsUser":0}}}' ;;
27) echo "🧨 Req: Runtime Security. Break: Falco service stopped on Control Plane."
    run_cp "systemctl stop falco" ;;
28) echo "🧨 Req: AppArmor Protection. Break: Annotations point to 'missing-profile'."
    kubectl run apparmor --image=nginx --overrides='{"metadata":{"annotations":{"container.apparmor.security.beta.kubernetes.io/nginx":"localhost/missing-profile"}}}' ;;
29) echo "🧨 Req: Admission Control. Break: NodeRestriction removed from API Server."
    run_cp "sed -i 's#NodeRestriction,##g' /etc/kubernetes/manifests/kube-apiserver.yaml" ;;
30) echo "🧨 Req: File Security. Break: API Manifest permissions set to 777."
    run_cp "chmod 777 /etc/kubernetes/manifests/kube-apiserver.yaml" ;;
31) echo "🧨 Req: Helm Deployment. Break: Chart image tag typo."
    kubectl create deploy helm-app --image=nginxx ;;
32) echo "🧨 Req: Blue-Green Switch. Break: Svc 'app-svc' labels still pointing to 'blue'."
    kubectl create deploy blue --image=nginx
    kubectl create deploy green --image=nginx
    kubectl expose deploy blue --port=80 --name=app-svc ;;
33) echo "🧨 Req: Canary Deployment. Break: Canary pods missing labels for main Service."
    kubectl create deploy main-app --image=nginx --replicas=3
    kubectl expose deploy main-app --port=80 --name=prod-svc
    kubectl create deploy canary --image=nginx --replicas=1
    kubectl label pod -l app=canary app=standalone --overwrite ;;
34) echo "🧨 Req: Logging Sidecar. Break: Container 3 missing volumeMount for shared log."
    kubectl create ns mc-namespace
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata: {name: mc-pod, namespace: mc-namespace}
spec:
  volumes: [{name: logs, emptyDir: {}}]
  containers:
  - name: mc-pod-1, image: nginx
  - name: mc-pod-2, image: busybox, volumeMounts: [{name: logs, mountPath: /var/log}], command: ["sh","-c","while true; do date >> /var/log/app.log; sleep 1; done"]
  - name: mc-pod-3, image: busybox, command: ["sh","-c","tail -f /var/log/app.log"]
EOF
;;
35) echo "🧨 Req: Ambassador Pattern. Break: Ambassador container mapping to wrong port."
    kubectl create deploy ambassador --image=nginx ;;
36) echo "🧨 Req: LimitRange Logic. Break: Namespace 'limit' has Min CPU > Max CPU."
    kubectl create ns limit
    cat <<EOF | kubectl apply -n limit -f -
apiVersion: v1
kind: LimitRange
metadata: {name: cpu-limit}
spec: {limits: [{type: Container, min: {cpu: "2"}, max: {cpu: "1"}}]}
EOF
    kubectl run stress-pod --image=nginx -n limit ;;
37) echo "🧨 Req: Scheduling Pod. Break: Requesting 100 CPU cores (Insufficient resources)."
    kubectl run big-pod --image=nginx --requests='cpu=100' ;;
38) echo "🧨 Req: External Ingress. Break: NetPol blocking all Ingress on all pods."
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: block-ingress}
spec: {podSelector: {}, policyTypes: [Ingress]}
EOF
;;
39) echo "🧨 Req: Custom SA 'sa-test'. Break: Pod points to non-existent 'missing-sa'."
    kubectl run sa-test --image=nginx --serviceaccount=missing-sa ;;
40) echo "🧨 Req: Secret Mounting. Break: Volume points to 'non-existent-secret'."
    kubectl run secret-test --image=nginx --overrides='{"spec":{"containers":[{"name":"nginx","image":"nginx","volumeMounts":[{"name":"s","mountPath":"/s"}]}],"volumes":[{"name":"s","secret":{"secretName":"non-existent-secret"}}]}}' ;;
41) echo "🧨 Req: ConfigMap Injection. Break: envFrom points to 'missing-cm'."
    kubectl run cm-test --image=nginx --overrides='{"spec":{"containers":[{"name":"nginx","image":"nginx","envFrom":[{"configMapRef":{"name":"missing-cm"}}]}]}}' ;;
42) echo "🧨 Req: HostPath Data. Break: Node directory /data/web has permissions 000."
    run_n1 "mkdir -p /data/web && chmod 000 /data/web"
    kubectl run vol-test --image=nginx --overrides='{"spec":{"containers":[{"name":"nginx","image":"nginx","volumeMounts":[{"name":"d","mountPath":"/usr/share/nginx/html"}]}],"volumes":[{"name":"d","hostPath":{"path":"/data/web"}}]}}' ;;
43) echo "🧨 Req: Targeted Scheduling. Break: Pod nodeSelector requires 'disk=ssd'."
    kubectl run node-test --image=nginx --overrides='{"spec":{"nodeSelector":{"disk":"ssd"}}}' ;;
44) echo "🧨 Req: Node Availability. Break: Node01 tainted with NoSchedule."
    kubectl taint nodes node01 key=value:NoSchedule ;;
45) echo "🧨 Req: Auto-scaling (HPA). Break: HPA created for 'web' but metrics-server is missing."
    kubectl create deploy web --image=nginx
    kubectl autoscale deploy web --cpu-percent=50 --min=1 --max=10 ;;
46) echo "🧨 Req: Cluster Monitoring. Break: Metrics-Server deployment deleted."
    kubectl delete deployment metrics-server -n kube-system 2>/dev/null ;;
47) echo "🧨 Req: Gateway API Routing. Break: parentRef points to 'wrong-gateway'."
    cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: web-route}
spec: {parentRefs: [{name: wrong-gateway}], rules: [{backendRefs: [{name: web-svc, port: 80}]}]}
EOF
;;
48) echo "🧨 Req: Rootless Container. Break: runAsNonRoot: true on image running as UID 0."
    kubectl run non-root --image=nginx --overrides='{"spec":{"securityContext":{"runAsNonRoot":true}}}' ;;
49) echo "🧨 Req: Sandboxed Runtime. Break: Pod requires RuntimeClass 'gvisor' (Missing)."
    kubectl run gvisor-test --image=nginx --overrides='{"spec":{"runtimeClassName":"gvisor"}}' ;;
50) echo "🧨 Req: Compound Health. Break: Node02 Kubelet down AND Kube-Proxy deleted."
    run_n2 "systemctl stop kubelet"
    kubectl -n kube-system delete pod -l k8s-app=kube-proxy ;;
esac
