#!/bin/bash

# ============================
# INSTALL.SH – Sentinel Layer 
# ============================

echo "==> [Sentinel] Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "==> [Sentinel] Installation des outils nécessaires..."
sudo apt install -y build-essential git cmake curl wget zsh python3-pip \
    nmap net-tools tcpdump tshark whois aircrack-ng nikto sqlmap \
    iperf3 iftop htop unzip arp-scan enum4linux hydra john lynis bat

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
git clone https://github.com/ggerganov/llama.cpp.git ~/sentinel/llama.cpp
cd ~/sentinel/llama.cpp
make

echo "==> [Sentinel] Téléchargement du modèle Phi-2 GGUF (q4_K_M)..."
mkdir -p ~/sentinel/models
cd ~/sentinel/models
wget https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf -O phi-2.gguf

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

echo "==> [Sentinel] Création du fichier de documentation des outils..."

cat <<'EOF' > ~/sentinel/docs/tools_doc.txt
# Liste des Outils disponibles dans Sentinel

nmap : Outil de scan réseau pour identifier les hôtes et services
tcpdump : Capture réseau en ligne de commande, pour analyser les paquets
tshark : Version CLI de Wireshark, capture réseau sans GUI
whois : Interroge les bases de données WHOIS pour obtenir des infos sur les domaines
aircrack-ng : Suite d'outils pour tester la sécurité des réseaux Wi-Fi
nikto : Scanner de vulnérabilités pour les serveurs web
sqlmap : Outil d'injection SQL automatisé pour tester la sécurité des bases de données
iperf3 : Test de bande passante réseau entre deux hôtes
iftop : Surveillance du trafic réseau en temps réel
htop : Surveillance des ressources système (CPU, mémoire, processus)
unzip : Décompression de fichiers ZIP
arp-scan : Scanner de réseau pour découvrir les hôtes sur un réseau local
enum4linux : Outil d'énumération des informations sur des systèmes Windows
hydra : Brute-forcing pour divers protocoles (SSH, FTP, etc.)
john : Outil de cracking de mots de passe avec des hash
lynis : Audit de sécurité du système
bat : Alternative améliorée à la commande 'cat', avec une coloration syntaxique
mitmproxy : Proxy HTTP/HTTPS pour intercepter et manipuler le trafic
nuclei : Scanner de vulnérabilités basé sur des templates

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
- `sentinel` : Lance l'assistant Sentinel (IA basée sur un LLM).
  Exemple d'utilisation : `sentinel Comment auditer un réseau interne ?`
  
## Alias pour afficher la documentation
- `sentinel-help` : Affiche la documentation des outils installés et des alias disponibles sur Sentinel.
  Exemple d'utilisation : `sentinel-help`
EOF

chmod +x ~/sentinel/docs/tools_doc.txt

echo "==> [Sentinel] Installation terminée."
echo "👉 Lance une nouvelle session ou tape 'source ~/.zshrc' pour activer les alias."
echo "👉 Utilise 'sentinel-doc' pour lire la documentation rapide des outils."
echo "👉 Tu peux maintenant discuter avec Sentinel :"
echo ""
echo "     sentinel Comment auditer un réseau interne ?"
echo ""
