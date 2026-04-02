#!/bin/bash
# ==============================================================================
# K8sLegion: The Advanced Kubernetes "Break-Fix" Simulator
# Author: Adithya (AWS Pro & GCP ACE)
# GitHub: github.com/adithya-marigalla/K8sLegion
# ==============================================================================
# "Structured learning is the difference between a tinkerer and an engineer."
# ==============================================================================

STATE_FILE=".k8s_legion_current"
VERSION="2.1.0"

# --- Branding & Header (The Perfect ASCII) ---
show_header() {
    clear
    echo "==============================================================="
    cat << "EOF"
  _  __  ___      _                       _             
 | |/ /( _ )    | |     ___   __ _  (_) ___   _ __  
 | ' / / _ \    | |    / _ \ / _` | | |/ _ \ | '_ \ 
 | . \ \__/ /   | |___|  __/| (_| | | | (_) || | | |
 |_|\_\\___/    |_____|\___| \__, | |_|\___/ |_| |_|
                             |___/                  
EOF
    echo "       K8sLegion Chaos Engine | Built by Adithya Marigalla     "
    echo "==============================================================="
    echo " Version: $VERSION | Target: Structured CKA/CKAD/CKS Mastery"
    echo "---------------------------------------------------------------"
}

show_usage() {
    echo "Usage: ./legion.sh [ID|random|current] [load|check|solution|reset]"
    echo ""
    echo "STRUCTURED LEARNING PATH (Manual Selection):"
    echo "  ./legion.sh 1 load       # Start Scenario 1 (ETCD)"
    echo "  ./legion.sh 2 load       # Move to Scenario 2 (API Server)"
    echo "  ... up to 50 ..."
    echo ""
    echo "DYNAMIC COMMANDS:"
    echo "  ./legion.sh random load   # Surprise challenge"
    echo "  ./legion.sh current check # Validate your fix"
    echo "  ./legion.sh current reset # Wipe the slate clean"
    exit 1
}

# --- Mission Briefings (The Requirement Specs) ---
show_briefing() {
    local ID=$1
    echo "🚀 MISSION BRIEFING: SCENARIO #$ID"
    echo "---------------------------------------------------------------"
    case $ID in
        1)  echo "📋 TASK: Fix ETCD Peer connectivity. Component status is failing."
            echo "👉 REQUIREMENT: Peers must communicate on port 2380." ;;
        2)  echo "📋 TASK: Restore API Server reachability."
            echo "👉 REQUIREMENT: API must communicate with ETCD on port 2379." ;;
        7)  echo "📋 TASK: Expose the 'web' deployment via service 'web-svc'."
            echo "👉 REQUIREMENT: Svc Type: ClusterIP, Port: 80, TargetPort: 80." ;;
        14) echo "📋 TASK: Implement Micro-segmentation via NetworkPolicy."
            echo "👉 REQUIREMENT: Allow Ingress/Egress on port 80 only." ;;
        34) echo "📋 TASK: Multi-container Logging Pattern (Sidecar)."
            echo "👉 REQUIREMENT: Create 'mc-pod' in 'mc-namespace'. Container 3 must"
            echo "               tail logs from Container 2 via a shared volume." ;;
        47) echo "📋 TASK: Implement Gateway API Routing."
            echo "👉 REQUIREMENT: Point HTTPRoute 'web-route' to 'prod-gateway'." ;;
        *)  echo "📋 TASK: Standardized Troubleshooting Scenario."
            echo "👉 REQUIREMENT: Align current cluster state with production spec." ;;
    esac
    echo "---------------------------------------------------------------"
    echo "🛠️  Action: Investigate the cluster. Use 'kubectl' and 'ssh'."
    echo "✅ To verify your fix, run: ./legion.sh current check"
    echo "---------------------------------------------------------------"
}

# --- Core Logic ---
# Check for missing arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    show_header
    show_usage
fi

show_header

# 1. Selection Logic (The Gatekeeper)
if [[ "$1" == "random" ]]; then
    ID=$((1 + $RANDOM % 50))
    echo "$ID" > "$STATE_FILE"
    echo "🎲 Random Selection: Loading Scenario #$ID"
elif [[ "$1" == "current" ]]; then
    if [ ! -f "$STATE_FILE" ]; then
        echo "❌ No active scenario. Please specify a number (1-50)."
        exit 1
    fi
    ID=$(cat "$STATE_FILE")
elif [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le 50 ]; then
    # Manual ID Selection
    ID=$1
    echo "$ID" > "$STATE_FILE"
    echo "📂 Manual Selection: Loading Scenario #$ID"
else
    echo "❌ Invalid Input. Use 1-50, 'random', or 'current'."
    exit 1
fi

# 2. Execution Logic
ACTION=$2
case "$ACTION" in
    load)
        ./break.sh "$ID"
        show_briefing "$ID"
        ;;
    check)
        ./validate.sh "$ID"
        ;;
    solution)
        echo "💡 Applying K8sLegion Solution for Lab $ID..."
        ./solution.sh "$ID"
        ;;
    reset)
        echo "🧹 Resetting environment for Lab $ID..."
        ./reset.sh "$ID"
        ;;
    *)
        show_usage
        ;;
esac
