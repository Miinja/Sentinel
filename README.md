
# 🛡️ **Sentinel No IA** - Layer de Debian pour la Cybersécurité 🚀

## 🌟 Description

**Sentinel** est un environnement léger et sécurisé basé sur Debian, conçu pour les **professionnels de la cybersécurité**. Il inclut une série d'outils puissants pour les **audits**, les **tests de pénétration**, la **surveillance réseau**, et plus encore.

L'objectif est de fournir une interface de **ligne de commande (CLI)** optimisée pour les tâches de cybersécurité 💡

## 📝 Prérequis

- Debian (ou une distribution basée sur Debian) 🐧
- Connexion internet pour l'installation des dépendances 🌐

## 🚀 Installation

1. **Télécharge le script d'installation** et exécute-le sur ton Raspberry Pi ou machine Debian.

   ```bash
   [curl -fsSL https://raw.githubusercontent.com/Miinja/Sentinel/refs/heads/no-ia/install.sh -o install.sh]
   chmod +x install.sh
   ./install.sh
   ```

Le script d'installation effectue les actions suivantes :

- Mise à jour du système 🆙
- Installation des outils de cybersécurité 🔐
- Configuration de **Zsh** et installation de **Oh My Zsh** 🖥️
- Création des scripts et alias personnalisés 🔧

## ⚙️ Fonctionnalités

- **🕵️‍♂️ Outils de cybersécurité** : Des outils populaires pour le **pentesting**, le **scan réseau**, l'**analyse de vulnérabilités**, etc. 🔍
- **🛠️ Alias personnalisés** : Des alias utiles pour simplifier les commandes courantes et accélérer les opérations de cybersécurité. ⚡
- **📚 Documentation rapide** : Accès rapide à la **documentation** des outils via un simple alias. 📄


## 🧑‍💻 Alias disponibles

Voici les principaux alias disponibles dans **Sentinel** :

### 📡 Alias pour la capture réseau et surveillance

* `sniff` : Lance **tcpdump** pour capturer tout le trafic réseau sur toutes les interfaces.
* `live` : Lance **iftop** pour afficher en temps réel la bande passante réseau.

### 🔎 Alias pour les scans et tests de vulnérabilité

* `scan` : Lance un scan de ports et services sur une cible avec **nmap**.
* `vuln` : Lance un scan de vulnérabilités sur un serveur web avec **nikto**.

### 📚 Alias pour afficher la documentation

* `sentinel-help` : Affiche la **documentation** des outils installés et des alias disponibles sur Sentinel.

## 👨‍💻 Exemples d'utilisation

Voici quelques exemples d'utilisation de **Sentinel** :

* **Scanner un réseau avec nmap** :

  ```bash
  scan 192.168.1.0/24
  ```

* **Analyser le trafic réseau avec tcpdump** :

  ```bash
  sniff
  ```

* **Accéder à la documentation des outils** :

  ```bash
  sentinel-help
  ```

## 📖 Documentation des outils

Un fichier de documentation est également disponible pour tous les outils installés. Vous pouvez le consulter avec la commande :

```bash
sentinel-help
```

Voici quelques-uns des outils inclus dans **Sentinel** :

* **nmap** : Scanner de réseau pour identifier les hôtes et services.
* **tcpdump** : Capture réseau en ligne de commande pour analyser les paquets.
* **nikto** : Scanner de vulnérabilités pour les serveurs web.
* **sqlmap** : Outil d'injection SQL automatisé pour tester les bases de données.
* **aircrack-ng** : Suite d'outils pour tester la sécurité des réseaux Wi-Fi.

Et bien d'autres... 🔧

## 👐 Contribution

Si tu souhaites contribuer à **Sentinel**, tu peux ouvrir une **pull request** sur GitHub. Nous sommes toujours à la recherche de nouvelles idées pour améliorer ce projet ! 🚀

## 📄 Licence

Ce projet est sous **licence MIT**. Profite-en ! 🎉

---

### 🚀 Prêt à décoller ? Tu es maintenant armé pour défendre tes systèmes avec **Sentinel**. 🌍💥
**Par [Miinja](https://github.com/Miinja)**

