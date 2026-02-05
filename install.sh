#!/bin/bash

echo "=== Installing COS ==="

sudo apt update

sudo apt install -y neofetch git curl

sudo cp branding/os-release /etc/os-release

echo "COS installed."
