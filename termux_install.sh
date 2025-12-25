#!/bin/bash
# WHITE_CAT Termux Installation Script
# Automated deployment for Android/Termux environment

set -e

echo "🐱 WHITE_CAT Termux Installation"
echo "=================================="
echo ""

# Check if running in Termux
if [ ! -d "$PREFIX" ]; then
    echo "❌ Error: This script must be run in Termux"
    exit 1
fi

echo "📱 Detected Termux environment: $PREFIX"
echo ""

# Update packages
echo "📦 Updating Termux packages..."
pkg update -y
pkg upgrade -y

# Install required packages
echo "🔧 Installing dependencies..."
pkg install -y \
    python \
    python-pip \
    git \
    clang \
    libffi \
    openssl \
    sqlite \
    libyaml \
    libxml2 \
    libxslt \
    rust

echo ""
echo "🐍 Setting up Python environment..."

# Upgrade pip
pip install --upgrade pip setuptools wheel

# Install Python dependencies
echo "📚 Installing Python packages..."
pip install pyyaml psutil requests tqdm colorama

# Optional: Install AI packages (lighter alternatives for mobile)
read -p "Install AI analysis packages? (requires ~500MB) [y/N]: " install_ai
if [[ "$install_ai" =~ ^[Yy]$ ]]; then
    echo "🤖 Installing AI packages (this may take several minutes)..."
    pip install numpy pandas scikit-learn
    echo "✅ AI packages installed"
else
    echo "⏭️  Skipping AI packages (you can install them later)"
fi

# Create directory structure
echo ""
echo "📁 Creating project structure..."
mkdir -p ~/white_cat
cd ~/white_cat

mkdir -p src/core
mkdir -p src/tier1
mkdir -p src/tier2  
mkdir -p src/tier3
mkdir -p src/reporting
mkdir -p config
mkdir -p logs
mkdir -p data
mkdir -p docs

# Create __init__.py files
touch src/__init__.py
touch src/core/__init__.py
touch src/tier1/__init__.py
touch src/tier2/__init__.py
touch src/tier3/__init__.py
touch src/reporting/__init__.py

echo "✅ Directory structure created"

# Create Termux-specific config
echo ""
echo "⚙️  Creating Termux configuration..."
cat > config/termux.yaml << 'EOF'
# WHITE_CAT Termux Configuration
platform: termux
environment: android

# Tier 1: Host Monitoring (Limited on Android)
tier1:
  enabled: true
  monitoring:
    - process_monitor
    - file_monitor
    - network_connections
  auditd: false  # Not available in Termux
  
# Tier 2: Network Intelligence
tier2:
  enabled: true
  packet_capture: false  # Requires root
  dns_monitoring: true
  connection_tracking: true
  
# Tier 3: AI Analysis (Lightweight mode)
tier3:
  enabled: true
  model: "lightweight"  # Use sklearn instead of Qwen3
  offline_mode: true
  
# Logging
logging:
  level: INFO
  file: logs/white_cat.log
  max_size: 10MB
  
# Storage
storage:
  database: data/white_cat.db
  reports: data/reports/
EOF

# Create Termux launcher
echo ""
echo "🚀 Creating launcher script..."
cat > ~/white_cat/run_termux.sh << 'EOF'
#!/bin/bash
# WHITE_CAT Termux Launcher

cd ~/white_cat

echo "🐱 Starting WHITE_CAT (Termux Mode)"
echo "===================================="
echo ""

# Check if main script exists
if [ ! -f "white_cat.py" ]; then
    echo "❌ white_cat.py not found!"
    echo "📥 Cloning from GitHub..."
    
    if [ -d ".git" ]; then
        git pull
    else
        cd ~
        rm -rf white_cat
        git clone https://github.com/Celbyx1996/white_cat.git
        cd white_cat
    fi
fi

# Run with Termux config
python white_cat.py --config config/termux.yaml "$@"
EOF

chmod +x ~/white_cat/run_termux.sh

# Create desktop shortcut (Termux widget support)
echo ""
echo "🔗 Creating shortcuts..."
mkdir -p ~/.shortcuts
cat > ~/.shortcuts/white_cat << 'EOF'
#!/bin/bash
termux-wake-lock
cd ~/white_cat && bash run_termux.sh
EOF
chmod +x ~/.shortcuts/white_cat

# Storage permissions
echo ""
echo "📂 Requesting storage permissions..."
termux-setup-storage

# Download/update from GitHub
echo ""
read -p "📥 Clone WHITE_CAT from GitHub? [Y/n]: " clone_repo
if [[ ! "$clone_repo" =~ ^[Nn]$ ]]; then
    echo "Cloning repository..."
    cd ~
    if [ -d "white_cat/.git" ]; then
        cd white_cat
        git pull origin main
    else
        rm -rf white_cat
        git clone https://github.com/Celbyx1996/white_cat.git
        cd white_cat
    fi
    echo "✅ Repository cloned/updated"
fi

# Final setup
echo ""
echo "🎯 Final configuration..."
cd ~/white_cat

# Create startup notification
cat > ~/.bashrc_white_cat << 'EOF'
# WHITE_CAT Quick Access
alias white_cat='cd ~/white_cat && bash run_termux.sh'
alias wc-status='cd ~/white_cat && python white_cat.py --status'
alias wc-logs='tail -f ~/white_cat/logs/white_cat.log'
EOF

# Add to bashrc if not already there
if ! grep -q "bashrc_white_cat" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# WHITE_CAT aliases" >> ~/.bashrc
    echo "source ~/.bashrc_white_cat" >> ~/.bashrc
fi

# Installation complete
echo ""
echo "✅ ========================================"
echo "✅  WHITE_CAT TERMUX INSTALLATION COMPLETE"
echo "✅ ========================================"
echo ""
echo "📱 Installation Directory: ~/white_cat"
echo "🚀 Quick Start Commands:"
echo ""
echo "   white_cat              - Run WHITE_CAT"
echo "   wc-status              - Check status"
echo "   wc-logs                - View logs"
echo ""
echo "📱 Termux Widget: Added to ~/.shortcuts/white_cat"
echo "⚙️  Configuration: ~/white_cat/config/termux.yaml"
echo ""
echo "🔄 Reload shell to activate aliases:"
echo "   source ~/.bashrc"
echo ""
echo "🎯 To start monitoring:"
echo "   cd ~/white_cat"
echo "   bash run_termux.sh"
echo ""
echo "📚 Documentation: ~/white_cat/docs/"
echo "🐱 Happy hunting!"
echo ""
