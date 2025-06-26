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
if [[ "${install_tools,,}" != "y" ]]; then
    log "Installation annulée."
    exit 0
fi

log "Mise à jour du système..."
if ! sudo apt update && sudo apt upgrade -y; then
    log "❌ Échec de la mise à jour du système."
    exit 1
fi

install_if_needed() {
    local pkg=$1
    if ! dpkg -l | grep -qw "$pkg"; then
        log "Installation de $pkg..."
        if ! sudo apt install -y "$pkg"; then
            log "❌ Erreur lors de l'installation de $pkg."
            exit 1
        fi
    else
        log "$pkg déjà installé, saut..."
    fi
}

log "Installation des outils nécessaires..."
tools=(
    nmap tcpdump tshark whois aircrack-ng sqlmap
    iperf3 iftop htop unzip arp-scan hydra john lynis bat
    neofetch zsh curl git
)
for tool in "${tools[@]}"; do
    install_if_needed "$tool"
done

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

# Alias Sentinel
alias sentinel-help='cat ~/sentinel/docs/tools_doc.txt'
alias sentinel-system='neofetch --cpu_temp --gpu_temp'

EOF
fi

log "Changement de shell vers Zsh..."
chsh -s "$(which zsh)"

mkdir -p ~/sentinel/docs

log "Création de la documentation..."
cat <<'EOF' > ~/sentinel/docs/tools_doc.txt
# Liste des Outils disponibles dans Sentinel

nmap : Scan réseau
tcpdump : Capture réseau
tshark : Wireshark CLI
whois : Infos domaine
aircrack-ng : Sécurité Wi-Fi
sqlmap : Injection SQL
iperf3 : Bande passante
iftop : Trafic réseau live
htop : Ressources système
unzip : Décompression ZIP
arp-scan : Découverte réseau local
hydra : Brute-force
john : Cracking de hash
lynis : Audit sécurité
bat : cat amélioré
neofetch : Affiche infos système
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

log "✅ Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour lire la documentation rapide."
