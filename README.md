# 🛡️ K8sLegion: The Kubernetes Chaos Engine

**Built by Marigalla Adithya (Multi Cloud & Distributed Systems Architect)**

K8sLegion is a specialized Kubernetes CHAOS ENGINEERING simulator designed for Architects and Platform Engineers to replicate real-world production failure scenarios and Engineered to mirror the complexity of MAANG-scale infrastructure,K8sLegion transforms Kubernetes knowledge from command execution into system-level thinking—focusing on diagnosis, failure analysis, and recovery under pressure.

## 💰 Zero-Cost, Local-First Infrastructure

Unlike cloud-based sandboxes or subscription-driven platforms that are time-limited and costly, K8sLegion is built for the **local-first engineer mindset**.

- 💯 **100% Free**  
  No cloud bills, no hidden API costs, no usage limits.

- 🧠 **Persistent Learning Environment**  
  Your lab remains exactly where you left it—ideal for iterative learning and deep mastery on a local multi-node cluster.

- 🖥️ **Hardware Agnostic**  
  Designed to run efficiently on commodity hardware, turning any Mac/Linux system into a production-grade Kubernetes war room.

- 🔐 **Privacy-Centric by Design**  
  All simulations, configurations, and data remain local—no telemetry, no tracking, no external dependencies.

---

> K8sLegion empowers engineers to build **real-world debugging intuition** without external constraints—just like operating clusters in production environments.

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
⚙️ Prerequisites & Environment Setup
Before running K8sLegion, ensure your lab environment (Control Plane and Worker Nodes) is prepared. These scripts are designed for a 1+2 Node Kubernetes Cluster running on Linux (Ubuntu/Debian recommended).

1. Install Dependencies (Control Plane Only)
The engine uses sshpass to automate commands across the cluster without manual password prompts.

sudo apt-get update && sudo apt-get install sshpass git -y

2. Prepare the Nodes (Control Plane & All Workers)
For the scripts to interact with your nodes, SSH must be configured to allow root login with password authentication. Run the following block on every node in your cluster:

# Enable Root Login and Password Authentication
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Ensure OpenSSH Server is installed and running
sudo apt-get install openssh-server -y
sudo systemctl restart sshd

# Set the root password to match the scripts
echo "root:your_secure_password" | sudo chpasswd

3. Script Initialization
After cloning the repository, grant execution permissions to the entire engine suite:

chmod +x legion.sh break.sh validate.sh solution.sh reset.sh

🛠️ Configuration Note
Update the PASS variable at the top of each .sh file:

PASS="your_secure_password"
