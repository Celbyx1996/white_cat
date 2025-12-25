#!/bin/bash
# WHITE_CAT Installation Script

echo "🐈‍⬛ WHITE_CAT Installation Starting..."

# Create directories
mkdir -p src/core src/tier1 src/tier2 src/tier3 src/reporting
mkdir -p logs data models tests

# Install dependencies
pip3 install -r requirements.txt

echo "✅ Installation complete!"
echo "Run: python3 white_cat.py"
