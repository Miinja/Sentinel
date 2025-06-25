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
    build-essential git cmake curl wget zsh python3-pip
    nmap net-tools tcpdump tshark whois aircrack-ng nikto sqlmap
    iperf3 iftop htop unzip arp-scan hydra john lynis bat neofetch
    libopenblas-dev libcurl4-openssl-dev libomp-dev pkg-config enum4linux
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
alias vuln='nikto -host'

# Fonction Sentinel
sentinel() {
~/sentinel/run.sh "$@"
}

# Alias Sentinel
alias sentinel='~/sentinel/run.sh'
alias sentinel-help='cat ~/sentinel/docs/tools_doc.txt'
alias sentinel-system='neofetch --cpu_temp --gpu_temp'

EOF
fi

log "Changement de shell vers Zsh..."
chsh -s "$(which zsh)"

mkdir -p ~/sentinel

log "Clonage de llama.cpp..."
if [ ! -d "$HOME/sentinel/llama.cpp/.git" ]; then
    if ! git clone https://github.com/ggerganov/llama.cpp.git ~/sentinel/llama.cpp; then
        log "❌ Échec du clonage de llama.cpp."
        exit 1
    fi
else
    log "llama.cpp déjà cloné, saut..."
fi

log "Compilation de llama.cpp..."
cd ~/sentinel/llama.cpp
mkdir -p build && cd build

if ! cmake .. -DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS -DLLAMA_CURL=ON; then
    log "❌ Erreur CMake."
    exit 1
fi

if ! make -j$(nproc); then
    log "❌ Erreur compilation make."
    exit 1
fi

log "Téléchargement du modèle TinyLlama GGUF (Q4_K_M)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models

MODEL_URL="https://huggingface.co/tensorblock/tinyllama-15M-GGUF/resolve/main/tinyllama-15M-Q2_K.gguf"
MODEL_NAME="tinyllama-15M-Q2_K.gguf"

log "Téléchargement du modèle TinyLlama 15M (Q2_K)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models

if [ -f "$MODEL_NAME" ]; then
    log "Modèle déjà présent, saut du téléchargement."
else
    if ! curl -L -o "$MODEL_NAME" "$MODEL_URL"; then
        log "❌ Échec du téléchargement du modèle TinyLlama."
        exit 1
    fi

    if ! head -c 4 "$MODEL_NAME" | grep -q "GGUF"; then
        log "❌ Fichier téléchargé invalide (pas un modèle GGUF ?)."
        exit 1
    fi
fi

log "Création du script run.sh..."
cat <<'EOF' > ~/sentinel/run.sh
#!/bin/bash

MODEL_PATH="$HOME/sentinel/models/tinyllama-15M-Q2_K.gguf"
OUTPUT_PATH="output.txt"

if [ ! -d "$HOME/sentinel/llama.cpp/build" ]; then
    echo "❌ Le répertoire de construction de Llama.cpp n'existe pas."
    exit 1
fi

cd "$HOME/sentinel/llama.cpp/build"

if ! ls ./bin/llama-* 1> /dev/null 2>&1; then
    echo "❌ Aucun binaire 'llama-*' trouvé."
    exit 1
fi

BIN=$(ls ./bin/llama-* | head -n1)

if [ ! -f "$MODEL_PATH" ]; then
    echo "❌ Le modèle n'existe pas à l'emplacement spécifié : $MODEL_PATH"
    exit 1
fi

# Génère dynamiquement la liste des outils installés
TOOLS=$(compgen -c | grep -E '^(nmap|tcpdump|tshark|whois|aircrack-ng|nikto|sqlmap|iperf3|iftop|htop|arp-scan|hydra|john|lynis|bat)' | sort -u | tr '\n' ', ' | sed 's/, $//')

CTX_SIZE=512
N_PREDICT=192
TEMP=0.4
REPEAT_PENALTY=1.2
PROMPT="SYSTEM: You are Sentinel, a local cybersecurity assistant running on a Raspberry Pi 4. You know the system context and installed tools (such as: ${TOOLS}). Your task is to assist with digital forensics, ethical hacking, Wi-Fi auditing, penetration testing, and Linux administration. Always respond concisely in fluent French, even if the input is in another language."

$BIN -m "$MODEL_PATH" \
     --ctx-size "$CTX_SIZE" \
     --n-predict "$N_PREDICT" \
     --temp "$TEMP" \
     --repeat_penalty "$REPEAT_PENALTY" \
     -p "$PROMPT"
EOF

chmod +x ~/sentinel/run.sh

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
enum4linux : Enumération systèmes Windows
hydra : Brute-force
john : Cracking de hash
lynis : Audit sécurité
bat : cat amélioré
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

log "✅ Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour lire la documentation rapide."
echo ""
echo '     sentinel "Comment auditer un réseau interne ?"'
echo ""
