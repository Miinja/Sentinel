#!/bin/bash

# ============================
# INSTALL.SH – Sentinel Layer 
# ============================

read -p "Souhaitez-vous (ré)installer les outils et dépendances ? (y/n) " install_tools
if [[ "$install_tools" != "y" ]]; then
    echo "==> [Sentinel] Installation annulée."
    exit 0
fi

echo "==> [Sentinel] Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "==> [Sentinel] Installation des outils nécessaires..."
sudo apt install -y build-essential git cmake curl wget zsh python3-pip \
    nmap net-tools tcpdump tshark whois aircrack-ng nikto sqlmap \
    iperf3 iftop htop unzip arp-scan hydra john lynis bat libopenblas-dev

echo "==> [Sentinel] Installation de Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "==> [Sentinel] Configuration bannière Zsh..."
cat <<'EOF' >> ~/.zshrc

# Sentinel ASCII Banner
echo ""
echo "▀████▀     █     ▀███▀  ▄█▄▀          ███▀▀██▀▀██████▀▀▀███ "
echo "  ▀██     ▄██     ▄█  ▄█▀             █▀   ██   ▀█ ██    ▀█ "
echo "   ██▄   ▄███▄   ▄█  ▄█████▄      ▄██      ██      ██   █   "
echo "    ██▄  █▀ ██▄  █▀  ██▀  ▀██▄   ████      ██      ██████   "
echo "    ▀██ █▀  ▀██ █▀   ██     ██ ▄█▀ ██      ██      ██   █  ▄"
echo "     ▄██▄    ▄██▄    ██▄   ▄███▀   ██      ██      ██     ▄█"
echo "      ██      ██      █████████████████  ▄████▄  ▄██████████"
echo "                                   ██                       "
echo "                                   ██                       "
echo ""
echo "                    Welcome to Sentinel OS                 "
echo "------------------------------------------------------------"
echo ""

# Alias Outils
alias sniff='sudo tcpdump -i any'
alias live='sudo iftop'
alias scan='nmap -sV -T4'
alias vuln='nikto -host'

# Alias Sentinel
alias sentinel='~/sentinel/run.sh'

# Alias pour la documentation des outils
alias sentinel-help='cat ~/sentinel/docs/tools_doc.txt'

EOF

echo "==> [Sentinel] Changement de shell vers Zsh..."
chsh -s $(which zsh)

echo "==> [Sentinel] Clonage de llama.cpp..."
mkdir -p ~/sentinel
git clone https://github.com/ggerganov/llama.cpp.git ~/sentinel/llama.cpp
cd ~/sentinel/llama.cpp

# Détection d'architecture et compilation adaptée
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
    echo "==> [Sentinel] Compilation pour ARM (aarch64)..."
    make LLAMA_OPENBLAS=1
else
    echo "==> [Sentinel] Compilation standard..."
    make
fi

echo "==> [Sentinel] Téléchargement du modèle Phi-2 GGUF (q4_K_M)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models
wget -nc https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf -O phi-2.gguf

echo "==> [Sentinel] Création du script run.sh avec prompt système optimisé..."
cat <<'EOF' > ~/sentinel/run.sh
#!/bin/bash
cd ~/sentinel/llama.cpp

./main -m ../models/phi-2.gguf -p \
"SYSTEM: You are Sentinel, an offline cybersecurity AI running inside a lightweight Linux OS. You are a CLI-based assistant installed on a Raspberry Pi 4, designed to help with audits, forensics, networking, penetration testing, and Linux administration.

You always reply in fluent French, using concise and technical language, but you accept common English terms used in cybersecurity (e.g. scan, port, payload, exploit, reverse shell). You do not translate those.

You never hallucinate. If something is unclear, you explain how to verify it. Always provide command-line examples when useful. Be professional, concise, and pragmatic.

Current environment: offline, ARM CPU, limited memory, running in terminal only.

USER: $@
ASSISTANT:"
EOF

chmod +x ~/sentinel/run.sh

echo "==> [Sentinel] Clonage de enum4linux (non disponible via apt)..."
git clone https://github.com/CiscoCXSecurity/enum4linux.git ~/sentinel/tools/enum4linux

echo "==> [Sentinel] Installation de nuclei..."
mkdir -p ~/sentinel/tools
cd ~/sentinel/tools
wget https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_amd64.deb -O nuclei.deb
sudo dpkg -i nuclei.deb || echo "⚠️ Erreur d'installation de nuclei, essaie manuellement."

echo "==> [Sentinel] Création du fichier de documentation des outils..."

mkdir -p ~/sentinel/docs
cat <<'EOF' > ~/sentinel/docs/tools_doc.txt
# Liste des Outils disponibles dans Sentinel

nmap : Scan réseau
tcpdump : Capture réseau
tshark : Wireshark CLI
whois : Infos domaine
aircrack-ng : Sécurité Wi-Fi
nikto : Vulnérabilités Web
sqlmap : Injection SQL
iperf3 : Bande passante
iftop : Trafic réseau live
htop : Ressources système
unzip : Décompression ZIP
arp-scan : Découverte réseau local
enum4linux : Enumération systèmes Windows (cloné localement)
hydra : Brute-force
john : Cracking de hash
lynis : Audit sécurité
bat : cat amélioré
mitmproxy : Interception HTTPS
nuclei : Scanner vulnérabilités (via GitHub)

# Alias

- sniff : `tcpdump -i any`
- live : `iftop`
- scan : `nmap -sV -T4`
- vuln : `nikto -host`
- sentinel : lance l’IA
- sentinel-help : cette doc
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

echo "==> [Sentinel] Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour lire la documentation rapide."
echo "👉 Tu peux maintenant discuter avec Sentinel :"
echo ""
echo "     sentinel Comment auditer un réseau interne ?"
echo ""
