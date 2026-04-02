<<<<<<< HEAD
# 🛡️ K8sLegion: The Kubernetes Chaos Engine

**Built by Marigalla Adithya (Multi Cloud & Distributed Systems Architect)**

K8sLegion is a specialized "Break-Fix" simulator designed for Architects & Platform Engineers preparing for CKA, CKAD, CKS, and MAANG technical interviews. It moves beyond abstract tutorials into **parameter-driven recovery scenarios**.

## 🚀 Key Features
* **50 Structured Scenarios**: From ETCD failures to complex Gateway API routing.
* **Chaos Mode**: Randomly trigger outages to test your real-time response.
* **Verbose Solutions**: Every fix includes the technical logic and imperative commands used.
* **Clean State Mastery**: Automated resets to ensure a "production-ready" cluster every time.

## 🛠️ Usage
1. **Load a Lab:** `./legion.sh 34 load`
2. **Diagnose:** Use `kubectl` and `ssh` to find the drift.
3. **Validate:** `./legion.sh current check`
4. **Learn:** `./legion.sh current solution` (Verbose Mode)
5. **Reset:** `./legion.sh current reset`

## 📜 Scenarios Covered
- ETCD Peer & Client Connectivity
- Static Pod Manifest Corruption
- Network Micro-segmentation (NetworkPolicies)
- Multi-container Patterns (Sidecars/Adapters)
- RBAC Hardening & Admission Controllers
- Gateway API & Modern Ingress
=======
# K8sLegion
K8sLegion is a specialized "Break-Fix" simulator designed for Architects &amp; Platform Engineers preparing for CKA, CKAD, CKS, and MAANG technical interviews. It moves beyond abstract tutorials into **parameter-driven recovery scenarios**.
>>>>>>> b9d80b726af99739f6d51051d37b2e1c35a01bd7
