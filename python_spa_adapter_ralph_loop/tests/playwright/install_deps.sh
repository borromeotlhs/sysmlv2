#!/bin/bash
# Install Playwright Chromium dependencies for Ubuntu 24.04+

echo "Installing Playwright Chromium dependencies..."

sudo apt-get update && sudo apt-get install -y \
  libnspr4 \
  libnss3 \
  libatk1.0-0 \
  libatk-bridge2.0-0 \
  libcups2 \
  libdrm2 \
  libxkbcommon0 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxrandr2 \
  libgbm1 \
  libasound2t64 \
  libx11-6 \
  libxcb1 \
  libxext6 \
  libxfixes3 \
  libxrender1 \
  libcairo2 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libgdk-pixbuf-2.0-0 \
  libgtk-3-0

echo "Dependencies installed successfully!"
