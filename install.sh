#!/bin/bash

# ============================
# INSTALL.SH – Sentinel Layer 
# ============================

YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${YELLOW}==> [Sentinel] $1${NC}"
}

read -p "Souhaitez-vous (ré)installer les outils et dépendances ? (y/n) " install_tools
if [[ "$install_tools" != "y" ]]; then
    log "Installation annulée."
    exit 0
fi

log "Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

log "Installation des outils nécessaires..."
sudo apt install -y build-essential git cmake curl wget zsh python3-pip \
    nmap net-tools tcpdump tshark whois aircrack-ng nikto sqlmap \
    iperf3 iftop htop unzip arp-scan hydra john lynis bat neofetch \
    libopenblas-dev libcurl4-openssl-dev

log "Installation de Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    log "Oh My Zsh est déjà installé, saut..."
fi

log "Configuration bannière Zsh..."
if ! grep -q "Sentinel ASCII Banner" ~/.zshrc; then
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
alias sentinel='func() { ./sentinel/run.sh "$*"; }; func'
alias sentinel-help='cat ~/sentinel/docs/tools_doc.txt'
alias sentinel-system='neofetch --cpu_temp --gpu_temp'

EOF
fi

log "Changement de shell vers Zsh..."
chsh -s $(which zsh)

mkdir -p ~/sentinel

log "Clonage de llama.cpp..."
if [ ! -d "$HOME/sentinel/llama.cpp/.git" ]; then
    git clone https://github.com/ggerganov/llama.cpp.git ~/sentinel/llama.cpp
else
    log "llama.cpp déjà cloné, saut..."
fi

log "Installation des dépendances pour la compilation (OpenBLAS, pkg-config, etc.)..."
sudo apt install -y libopenblas-dev libomp-dev pkg-config

log "Compilation via CMake..."
cd ~/sentinel/llama.cpp
mkdir -p build && cd build

ARCH=$(uname -m)

log "Compilation avec CMake..."
cmake .. -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS -DLLAMA_CURL=ON

log "Compilation avec make..."
make -j$(nproc)

if ! ls ./bin/llama-* 1> /dev/null 2>&1; then
    log "❌ Erreur : aucun binaire 'llama-*' trouvé dans bin/, compilation probablement échouée."
    exit 1
else
    log "✅ Compilation réussie : un ou plusieurs binaires 'llama-*' trouvés."
fi


log "Téléchargement du modèle Phi-2 GGUF (q4_K_M)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models
wget -nc https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf -O phi-2.gguf

log "Création du script run.sh..."

cat <<'EOF' > ~/sentinel/run.sh
#!/bin/bash
cd ~/sentinel/llama.cpp/build

if ! ls ./bin/llama-* 1> /dev/null 2>&1; then
    log "❌ Erreur : aucun binaire 'llama-*' trouvé dans bin/, compilation probablement échouée."
    exit 1
else
    log "✅ Compilation réussie : un ou plusieurs binaires 'llama-*' trouvés."
fi


./bin/llama-run -m ../../models/phi-2.gguf -p \
"SYSTEM: You are Sentinel, an offline cybersecurity AI running inside a lightweight Linux OS. You are a CLI-based assistant installed on a Raspberry Pi 4, designed to help with audits, forensics, networking, penetration testing, and Linux administration.

You always reply in fluent French, using concise and technical language, but you accept common English terms used in cybersecurity (e.g. scan, port, payload, exploit, reverse shell). You do not translate those.

You never hallucinate. If something is unclear, you explain how to verify it. Always provide command-line examples when useful. Be professional, concise, and pragmatic.

Current environment: offline, ARM CPU, limited memory, running in terminal only.

USER: $@
ASSISTANT:"
EOF

chmod +x ~/sentinel/run.sh

log "Clonage de enum4linux..."
mkdir -p ~/sentinel/tools
if [ ! -d "$HOME/sentinel/tools/enum4linux/.git" ]; then
    git clone https://github.com/CiscoCXSecurity/enum4linux.git ~/sentinel/tools/enum4linux
else
    log "enum4linux déjà cloné, saut..."
fi

log "Installation de nuclei..."
ARCH=$(dpkg --print-architecture)

if [[ "$ARCH" == "arm64" ]]; then
    wget -nc https://github.com/projectdiscovery/nuclei/releases/download/v3.4.3/nuclei_3.4.3_linux_arm64.zip
    unzip nuclei_3.4.3_linux_arm64.zip
    sudo mv nuclei /usr/local/bin/
    chmod +x /usr/local/bin/nuclei
else
    NUCLEI_URL="https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_${ARCH}.deb"
    wget -nc "$NUCLEI_URL" -O nuclei.deb && sudo dpkg -i nuclei.deb || echo "⚠️ Erreur d'installation de nuclei, essaie manuellement."
fi

log "Création de la documentation..."
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
nmap : Vue global du systeme

# Liste des Alias disponibles dans Sentinel

## Alias pour la capture réseau et surveillance
- `sniff` : Lance tcpdump pour capturer tout le trafic réseau sur toutes les interfaces.
  Exemple d'utilisation : `sniff` 
- `live` : Lance iftop pour afficher en temps réel la bande passante réseau.
  Exemple d'utilisation : `live`

## Alias pour les scans et tests de vulnérabilité
- `scan` : Lance un scan de ports et services sur une cible avec nmap.
  Exemple d'utilisation : `scan <target>`
- `vuln` : Lance un scan de vulnérabilités sur un serveur web avec nikto.
  Exemple d'utilisation : `vuln <target>`

## Alias pour l'interaction avec Sentinel
- `sentinel` : Lance l’assistant Sentinel (IA basée sur un LLM).
  Exemple d'utilisation : `sentinel Comment auditer un réseau interne ?`
  
## Alias pour afficher la documentation
- `sentinel-help` : Affiche la documentation des outils installés et des alias disponibles sur Sentinel.
  Exemple d'utilisation : `sentinel-help`

## Alias Overall Systeme
- `sentinel-system` : Utilise Neofetch pour une vue global du systeme (avec la temperature GPU/CPU)
  Exemple d'utilisation : `sentinel-system`
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

log "Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour lire la documentation rapide."
echo "👉 Tu peux maintenant discuter avec Sentinel :"
echo ""
echo "     sentinel Comment auditer un réseau interne ?"
echo ""
