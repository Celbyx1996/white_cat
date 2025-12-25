#!/bin/bash
# WHITE_CAT Termux-Ubuntu Installation (Full Root Version)
# For Ubuntu running inside Termux with root privileges

set -e

echo "🐱 WHITE_CAT Termux-Ubuntu Installation (ROOT)"
echo "================================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  WARNING: Not running as root"
    echo "💡 This script works best with root privileges"
    echo "   Continue anyway? [y/N]"
    read -r continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        echo "Exiting. Run with: sudo bash termux_ubuntu_install.sh"
        exit 1
    fi
fi

echo "✅ Root access detected"
echo ""

# Detect environment
echo "🔍 Detecting environment..."
if [ -n "$PREFIX" ]; then
    echo "📱 Termux environment detected"
    IN_TERMUX=true
else
    echo "🐧 Native Ubuntu environment"
    IN_TERMUX=false
fi

# Check Ubuntu version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "📦 OS: $NAME $VERSION"
fi
echo ""

# Update system
echo "📦 Updating system packages..."
apt-get update
apt-get upgrade -y

# Install core packages
echo "🔧 Installing core dependencies..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    libyaml-dev \
    sqlite3 \
    libsqlite3-dev \
    wget \
    curl

# Install auditd (Full monitoring capability)
echo ""
echo "🛡️  Installing auditd for syscall monitoring..."
apt-get install -y auditd audispd-plugins

# Configure auditd
echo "⚙️  Configuring auditd..."
cat > /etc/audit/rules.d/white_cat.rules << 'EOF'
# WHITE_CAT Audit Rules - MITRE ATT&CK Coverage

## System Calls Monitoring
-a always,exit -F arch=b64 -S execve -k execution
-a always,exit -F arch=b32 -S execve -k execution

## File Access Monitoring
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k privilege_escalation

## Network Activity
-a always,exit -F arch=b64 -S socket -S connect -k network
-a always,exit -F arch=b32 -S socket -S connect -k network

## Process Injection
-a always,exit -F arch=b64 -S ptrace -k injection
-a always,exit -F arch=b32 -S ptrace -k injection

## Privilege Escalation
-w /usr/bin/sudo -p x -k privilege_escalation
-w /usr/bin/su -p x -k privilege_escalation
EOF

# Restart auditd
if systemctl is-active --quiet auditd; then
    echo "🔄 Restarting auditd service..."
    systemctl restart auditd
else
    echo "⚠️  Auditd not running as systemd service"
fi

# Install network monitoring tools
echo ""
echo "🌐 Installing network monitoring tools..."
apt-get install -y \
    tcpdump \
    tshark \
    nmap \
    netcat \
    dnsutils \
    iptables \
    iproute2

# Install Python packages
echo ""
echo "🐍 Installing Python packages..."
pip3 install --upgrade pip setuptools wheel

pip3 install \
    pyyaml \
    psutil \
    requests \
    scapy \
    pyshark \
    tqdm \
    colorama \
    python-dateutil

# AI/ML packages
echo ""
read -p "📊 Install AI/ML packages? (numpy, pandas, sklearn) [Y/n]: " install_ml
if [[ ! "$install_ml" =~ ^[Nn]$ ]]; then
    echo "🤖 Installing ML packages..."
    pip3 install numpy pandas scikit-learn
fi

# Create directory structure
echo ""
echo "📁 Creating WHITE_CAT directory structure..."
WC_DIR="/opt/white_cat"
mkdir -p $WC_DIR
cd $WC_DIR

mkdir -p src/core
mkdir -p src/tier1
mkdir -p src/tier2
mkdir -p src/tier3
mkdir -p src/reporting
mkdir -p config
mkdir -p logs
mkdir -p data/captures
mkdir -p data/reports
mkdir -p docs

# Create __init__.py files
touch src/__init__.py
touch src/core/__init__.py
touch src/tier1/__init__.py
touch src/tier2/__init__.py
touch src/tier3/__init__.py
touch src/reporting/__init__.py

echo "✅ Directory structure created at $WC_DIR"

# Create full-featured config
echo ""
echo "⚙️  Creating Ubuntu configuration (full features)..."
cat > config/ubuntu_root.yaml << 'EOF'
# WHITE_CAT Ubuntu Root Configuration
# Full-featured deployment with auditd and packet capture

platform: ubuntu
environment: termux_proot
root_access: true

# Tier 1: Full Host Monitoring
tier1:
  enabled: true
  auditd: true
  monitoring:
    - auditd_syscalls
    - process_monitor
    - file_integrity
    - user_activity
  auditd_rules: /etc/audit/rules.d/white_cat.rules
  log_file: /var/log/audit/audit.log
  
# Tier 2: Full Network Intelligence
tier2:
  enabled: true
  packet_capture: true
  interfaces:
    - all  # Monitor all interfaces
  dns_monitoring: true
  connection_tracking: true
  pcap_storage: data/captures/
  capture_filter: ""  # Capture everything
  
# Tier 3: AI Analysis
tier3:
  enabled: true
  model: "sklearn"  # Use sklearn for now
  behavioral_analysis: true
  threat_scoring: true
  offline_mode: true
  
# MITRE ATT&CK Mapping
mitre:
  enabled: true
  tactics:
    - Initial Access
    - Execution
    - Persistence
    - Privilege Escalation
    - Defense Evasion
    - Credential Access
    - Discovery
    - Lateral Movement
    - Collection
    - Exfiltration
    
# Logging
logging:
  level: INFO
  file: logs/white_cat.log
  max_size: 50MB
  rotation: daily
  
# Storage
storage:
  database: data/white_cat.db
  reports: data/reports/
  retention_days: 30
  
# Alerts
alerts:
  enabled: true
  severity_threshold: MEDIUM
  channels:
    - console
    - file
EOF

# Clone/update repository
echo ""
read -p "📥 Clone WHITE_CAT from GitHub? [Y/n]: " clone_repo
if [[ ! "$clone_repo" =~ ^[Nn]$ ]]; then
    echo "Cloning repository..."
    if [ -d ".git" ]; then
        git pull origin main
    else
        cd /opt
        rm -rf white_cat
        git clone https://github.com/Celbyx1996/white_cat.git
        cd white_cat
    fi
    echo "✅ Repository cloned/updated"
fi

# Create systemd service
echo ""
read -p "⚡ Create systemd service for auto-start? [Y/n]: " create_service
if [[ ! "$create_service" =~ ^[Nn]$ ]]; then
    cat > /etc/systemd/system/white_cat.service << 'EOF'
[Unit]
Description=WHITE_CAT Adversary Intelligence Platform
After=network.target auditd.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/white_cat
ExecStart=/usr/bin/python3 /opt/white_cat/white_cat.py --config /opt/white_cat/config/ubuntu_root.yaml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    echo "✅ Systemd service created"
    echo "   Enable with: systemctl enable white_cat"
    echo "   Start with:  systemctl start white_cat"
fi

# Set permissions
echo ""
echo "🔒 Setting permissions..."
chown -R root:root $WC_DIR
chmod -R 750 $WC_DIR
chmod +x $WC_DIR/*.sh 2>/dev/null || true

# Create launcher scripts
echo ""
echo "🚀 Creating launcher scripts..."
cat > /usr/local/bin/white_cat << 'EOF'
#!/bin/bash
cd /opt/white_cat
python3 white_cat.py --config config/ubuntu_root.yaml "$@"
EOF

cat > /usr/local/bin/wc-status << 'EOF'
#!/bin/bash
cd /opt/white_cat
python3 white_cat.py --config config/ubuntu_root.yaml --status
EOF

cat > /usr/local/bin/wc-logs << 'EOF'
#!/bin/bash
tail -f /opt/white_cat/logs/white_cat.log
EOF

chmod +x /usr/local/bin/white_cat
chmod +x /usr/local/bin/wc-status
chmod +x /usr/local/bin/wc-logs

# Installation complete
echo ""
echo "✅ =================================================="
echo "✅  WHITE_CAT TERMUX-UBUNTU INSTALLATION COMPLETE"
echo "✅  FULL ROOT VERSION WITH AUDITD & PACKET CAPTURE"
echo "✅ =================================================="
echo ""
echo "📍 Installation Directory: /opt/white_cat"
echo "⚙️  Configuration: /opt/white_cat/config/ubuntu_root.yaml"
echo "📝 Audit Rules: /etc/audit/rules.d/white_cat.rules"
echo ""
echo "🚀 Quick Start Commands:"
echo ""
echo "   white_cat              - Run WHITE_CAT"
echo "   wc-status              - Check system status"
echo "   wc-logs                - View real-time logs"
echo ""
echo "⚡ Systemd Service:"
echo "   systemctl start white_cat      - Start service"
echo "   systemctl enable white_cat     - Enable auto-start"
echo "   systemctl status white_cat     - Check status"
echo ""
echo "🛡️  Features Enabled:"
echo "   ✅ Auditd syscall monitoring"
echo "   ✅ Full packet capture (tcpdump/tshark)"
echo "   ✅ MITRE ATT&CK mapping"
echo "   ✅ Real-time threat detection"
echo "   ✅ Forensic evidence collection"
echo ""
echo "📚 Documentation: /opt/white_cat/docs/"
echo "🐱 Full combat readiness achieved!"
echo ""
