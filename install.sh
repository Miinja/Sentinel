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
    libopenblas-dev libcurl4-openssl-dev libomp-dev pkg-config
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

log "Clonage de enum4linux..."
mkdir -p ~/sentinel/tools
if [ ! -d "$HOME/sentinel/tools/enum4linux/.git" ]; then
    if ! git clone https://github.com/CiscoCXSecurity/enum4linux.git ~/sentinel/tools/enum4linux; then
        log "❌ Échec du clonage de enum4linux."
        exit 1
    fi
else
    log "enum4linux déjà cloné, saut..."
fi

log "Installation de nuclei..."
ARCH=$(dpkg --print-architecture)

if [[ "$ARCH" == "arm64" ]]; then
    if ! wget -nc https://github.com/projectdiscovery/nuclei/releases/download/v3.4.3/nuclei_3.4.3_linux_arm64.zip; then
        log "❌ Échec du téléchargement de nuclei (ARM64)."
        exit 1
    fi
    unzip -o nuclei_3.4.3_linux_arm64.zip
    sudo mv nuclei /usr/local/bin/
    chmod +x /usr/local/bin/nuclei
    rm nuclei_3.4.3_linux_arm64.zip
else
    NUCLEI_URL="https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_${ARCH}.deb"
    if ! wget -nc "$NUCLEI_URL" -O nuclei.deb || ! sudo dpkg -i nuclei.deb; then
        log "⚠️ Erreur d'installation de nuclei, essaie manuellement."
    fi
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

if ! ls ./bin/llama-* 1> /dev/null 2>&1; then
    log "❌ Aucun binaire 'llama-*' trouvé."
    exit 1
else
    log "✅ Compilation réussie."
fi

log "Téléchargement du modèle Phi-1.5 GGUF (q4_0)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models

if [ -f "phi-1.5.gguf" ]; then
    log "Modèle déjà présent, saut du téléchargement."
else
    if ! curl -L -o phi-1.5.gguf https://huggingface.co/TheBloke/phi-1.5-GGUF/resolve/main/phi-1.5.Q4_0.gguf; then
        log "❌ Échec du téléchargement du modèle Phi-1.5."
        exit 1
    fi

    if ! head -c 4 phi-1.5.gguf | grep -q "GGUF"; then
        log "❌ Fichier téléchargé invalide (pas un modèle GGUF ?)."
        exit 1
    fi
fi

log "Création du script run.sh..."
cat <<'EOF' > ~/sentinel/run.sh
#!/bin/bash

MODEL_PATH="../../models/phi-1.5.gguf"
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

CTX_SIZE=1024            # Taille du contexte (plus grand pour mieux gérer les prompts longs)
N_PREDICT=128            # Nombre de tokens à prédire
TEMP=0.7                 # Température pour le texte généré
REPEAT_PENALTY=1.2       # Pénalité de répétition pour éviter les boucles
PROMPT="SYSTEM: Vous êtes Sentinel, une IA de cybersécurité fonctionnant dans un OS Linux léger. Vous êtes un assistant en ligne de commande installé sur un Raspberry Pi 4, conçu pour aider avec les audits, l'analyse forensique, la gestion de réseaux, le pentesting et l'administration Linux.

Vous répondez toujours en français, en utilisant un langage concis et technique, tout en acceptant les termes courants en cybersécurité (par exemple : scan, port, payload, exploit, reverse shell). Vous ne traduisez pas ces termes.

Vous ne hallucinez jamais. Si quelque chose n'est pas clair, vous expliquez comment le vérifier. Vous fournissez toujours des exemples en ligne de commande lorsqu'ils sont utiles. Soyez professionnel, concis et pragmatique.

Environnement actuel : hors ligne, CPU ARM, mémoire limitée, en fonctionnement uniquement dans le terminal."

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
- `live` : Lance iftop pour afficher en temps réel la bande passante réseau.

## Alias pour les scans et tests de vulnérabilité
- `scan` : Lance un scan de ports et services sur une cible avec nmap.
- `vuln` : Lance un scan de vulnérabilités sur un serveur web avec nikto.

## Alias pour l'interaction avec Sentinel
- `sentinel` : Lance l’assistant Sentinel (IA basée sur un LLM).

## Alias pour afficher la documentation
- `sentinel-help` : Affiche la documentation des outils installés et des alias disponibles.

## Alias Overall Systeme
- `sentinel-system` : Vue global du système (avec la température GPU/CPU)
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

log "✅ Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-help' pour lire la documentation rapide."
echo ""
echo '     sentinel "Comment auditer un réseau interne ?"'
echo ""
