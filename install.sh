#!/bin/bash

# ============================
# INSTALL.SH – Sentinel Layer 
# ============================

read -p "==> [Sentinel] Voulez-vous mettre à jour le système et (ré)installer les outils ? (y/n): " do_install

if [[ "$do_install" == "y" ]]; then
    echo "==> [Sentinel] Mise à jour du système..."
    sudo apt update && sudo apt upgrade -y

    echo "==> [Sentinel] Installation des outils nécessaires..."
    sudo apt install -y build-essential git cmake curl wget zsh python3-pip \
        nmap net-tools tcpdump tshark whois aircrack-ng nikto sqlmap \
        iperf3 iftop htop unzip arp-scan hydra john lynis bat mitmproxy

    echo "==> [Sentinel] Installation manuelle de enum4linux..."
    if [ ! -d "/opt/enum4linux" ]; then
        sudo git clone https://github.com/CyberScan-Network/enum4linux-ng.git /opt/enum4linux
        sudo ln -s /opt/enum4linux/enum4linux-ng.py /usr/local/bin/enum4linux
        sudo chmod +x /usr/local/bin/enum4linux
    else
        echo "==> enum4linux est déjà installé."
    fi

    echo "==> [Sentinel] Installation manuelle de nuclei..."
    if ! command -v nuclei &> /dev/null; then
        curl -s https://api.github.com/repos/projectdiscovery/nuclei/releases/latest \
        | grep "browser_download_url.*linux_amd64.zip" \
        | cut -d '"' -f 4 \
        | wget -i - -O nuclei.zip

        unzip nuclei.zip
        sudo mv nuclei /usr/local/bin/
        sudo chmod +x /usr/local/bin/nuclei
        rm nuclei.zip
    else
        echo "==> nuclei est déjà installé."
    fi

    echo "==> [Sentinel] Installation de Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

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

mkdir -p ~/sentinel

if [ ! -d "~/sentinel/llama.cpp" ]; then
    echo "==> [Sentinel] Clonage de llama.cpp..."
    git clone https://github.com/ggerganov/llama.cpp.git ~/sentinel/llama.cpp
    cd ~/sentinel/llama.cpp
    make
else
    echo "==> llama.cpp est déjà présent."
fi

echo "==> [Sentinel] Téléchargement du modèle Phi-2 GGUF (q4_K_M)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models

if [ ! -f "phi-2.gguf" ]; then
    wget https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf -O phi-2.gguf
else
    echo "==> Modèle déjà téléchargé."
fi

echo "==> [Sentinel] Création du script run.sh..."
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

mkdir -p ~/sentinel/docs

echo "==> [Sentinel] Création du fichier de documentation des outils..."
cat <<'EOF' > ~/sentinel/docs/tools_doc.txt
# Liste des Outils disponibles dans Sentinel

nmap : Scan réseau pour détecter les hôtes/services
tcpdump : Capture réseau en ligne de commande
tshark : Version CLI de Wireshark
whois : Interroge les bases WHOIS
aircrack-ng : Sécurité des réseaux Wi-Fi
nikto : Scanner vulnérabilités serveurs web
sqlmap : Injection SQL automatisée
iperf3 : Test bande passante réseau
iftop : Trafic réseau en temps réel
htop : Surveillance des ressources système
unzip : Décompression ZIP
arp-scan : Découverte d'hôtes sur un LAN
enum4linux : Enumération systèmes Windows (via GitHub)
hydra : Brute-force pour divers protocoles
john : Cracking de hash de mots de passe
lynis : Audit de sécurité
bat : Version améliorée de 'cat'
mitmproxy : Proxy HTTP/HTTPS pour intercepter
nuclei : Scanner de vulnérabilités (via GitHub)

# Alias disponibles

sniff : tcpdump sur toutes interfaces
live : iftop (trafic réseau)
scan : nmap rapide
vuln : nikto sur hôte
sentinel : assistant IA local
sentinel-help : cette doc
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

echo "==> [Sentinel] Installation terminée."
echo "👉 Tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour voir la documentation."
echo "👉 Pour discuter avec Sentinel :"
echo ""
echo "     sentinel Comment auditer un réseau interne ?"
echo ""
