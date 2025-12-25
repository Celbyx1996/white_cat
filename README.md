# WHITE_CAT 🐈‍⬛

Advanced adversary intelligence platform for home and small-office networks.

## Features

- **Host-Level Monitoring**: auditd + MITRE ATT&CK mapping
- **Network Intelligence**: Router-level traffic analysis
- **AI-Powered Analysis**: Qwen3 behavioral profiling
- **Real-Time Detection**: Attacker identification and tracking
- **Evidence Export**: Prosecution-grade forensic documentation

## Architecture

- **TIER 1**: Host Level (Ubuntu/Termux) - auditd syscall monitoring
- **TIER 2**: Network Level (Router) - packet capture & DNS tracking
- **TIER 3**: AI Intelligence (Qwen3) - threat scoring & attribution

## 📱 Termux Installation (Android)

WHITE_CAT can be deployed on Android devices using Termux for portable adversary intelligence.

### Quick Start (Termux)

```bash
# Clone repository
git clone https://github.com/Celbyx1996/white_cat.git
cd white_cat

# Run Termux installer
bash termux_install.sh
```

The automated installer will:
- ✅ Install Python, Git, and required dependencies
- ✅ Create directory structure
- ✅ Generate Termux-optimized configuration
- ✅ Setup quick-access aliases and Termux widgets
- ✅ Clone/update repository from GitHub

### Termux Features

**Adapted for Android limitations:**
- 📱 Process monitoring (no root required)
- 🔗 Network connection tracking
- 📊 Lightweight AI analysis (sklearn-based)
- 📝 Forensic logging and reporting
- 🔌 Storage access integration

**Quick Commands:**
```bash
white_cat           # Run WHITE_CAT
wc-status           # Check system status  
wc-logs             # View real-time logs
```

### Termux Widget

Access WHITE_CAT from your home screen:
1. Install **Termux:Widget** from F-Droid
2. Add widget to home screen
3. Select `white_cat` shortcut

### Configuration

Termux config located at: `~/white_cat/config/termux.yaml`

Key differences from standard deployment:
- `auditd: false` (not available on Android)
- `packet_capture: false` (requires root)
- `model: "lightweight"` (sklearn instead of Qwen3)
- `offline_mode: true` (mobile-optimized)

## 🖥️ Standard Installation (Ubuntu/Debian)

For full-featured deployment on Linux:

```bash
git clone https://github.com/Celbyx1996/white_cat.git
cd white_cat
bash quick_deploy.sh
python3 white_cat.py
```

## Documentation

Full documentation available in `docs/` folder.
