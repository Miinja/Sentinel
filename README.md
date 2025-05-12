# Sentinel - Layer de Debian pour la cybersécurité

## Description

**Sentinel** est un environnement léger et sécurisé basé sur Debian, conçu pour les professionnels de la cybersécurité. Il inclut une série d'outils puissants pour les audits, les tests de pénétration, la surveillance du réseau, et plus encore. Le système fonctionne de manière totalement hors ligne sur des machines basées sur des processeurs ARM (ex. Raspberry Pi).

L'objectif est de fournir une interface de ligne de commande (CLI) optimisée pour les tâches de cybersécurité, avec une intégration fluide d'une IA de type LLM pour une assistance interactive.

## Fonctionnalités

- **IA Sentinel** : Utilise un modèle de langage pour fournir des réponses techniques et concises en français, adaptées à la cybersécurité.
- **Outils de cybersécurité** : Des outils populaires pour le pentesting, le scan réseau, l'analyse de vulnérabilités, etc.
- **Alias personnalisés** : Des alias utiles pour simplifier les commandes courantes et accélérer les opérations de cybersécurité.
- **Documentation rapide** : Accès rapide à la documentation des outils via un simple alias.

## Prérequis

- Raspberry Pi 4 (ou tout autre appareil ARM)
- Debian (ou une distribution basée sur Debian)
- Connexion internet pour l'installation des dépendances

## Installation

1. **Télécharge le script d'installation** et exécute-le sur ton Raspberry Pi ou machine Debian.

   ```bash
   curl -fsSL https://raw.githubusercontent.com/ton-repository/install.sh -o install.sh
   chmod +x install.sh
   ./install.sh

    Le script d'installation fait les actions suivantes :

        Mise à jour du système.

        Installation de nombreux outils de cybersécurité.

        Configuration de Zsh et installation de Oh My Zsh.

        Clonage et compilation du projet llama.cpp pour l'IA Sentinel.

        Téléchargement du modèle Phi-2 GGUF.

        Création des scripts et alias personnalisés.

Alias disponibles

Voici les principaux alias disponibles dans Sentinel :
Alias pour la capture réseau et surveillance

    sniff : Lance tcpdump pour capturer tout le trafic réseau sur toutes les interfaces.

sniff

live : Lance iftop pour afficher en temps réel la bande passante réseau.

    live

Alias pour les scans et tests de vulnérabilité

    scan : Lance un scan de ports et services sur une cible avec nmap.

scan <target>

vuln : Lance un scan de vulnérabilités sur un serveur web avec nikto.

    vuln <target>

Alias pour l'interaction avec Sentinel

    sentinel : Lance l'assistant Sentinel (IA basée sur un LLM).

    sentinel <question>

Alias pour afficher la documentation

    sentinel-help : Affiche la documentation des outils installés et des alias disponibles sur Sentinel.

    sentinel-help

Exemples d'utilisation

Voici quelques exemples d'utilisation de Sentinel :

    Scanner un réseau avec nmap :

scan 192.168.1.0/24

Analyser le trafic réseau avec tcpdump :

sniff

Demander à l'IA Sentinel un conseil sur un audit réseau :

sentinel Comment auditer un réseau interne ?

Accéder à la documentation des outils :

    sentinel-help

Documentation des outils

Un fichier de documentation est également disponible pour tous les outils installés. Vous pouvez le consulter avec la commande :

sentinel-help

Voici quelques-uns des outils inclus :

    nmap : Scanner de réseau pour identifier les hôtes et services.

    tcpdump : Capture réseau en ligne de commande pour analyser les paquets.

    nikto : Scanner de vulnérabilités pour les serveurs web.

    sqlmap : Outil d'injection SQL automatisé pour tester les bases de données.

    aircrack-ng : Suite d'outils pour tester la sécurité des réseaux Wi-Fi.

    Et bien d'autres...

Contribution

Si tu souhaites contribuer à Sentinel, tu peux ouvrir une pull request sur GitHub.
Licence

Ce projet est sous licence MIT.


### Explication des sections :
- **Description** : Présente le projet et ses fonctionnalités principales.
- **Prérequis** : Liste les conditions nécessaires pour faire fonctionner le projet.
- **Installation** : Décrit les étapes pour installer et configurer Sentinel.
- **Alias** : Fournit des exemples d'alias utiles pour l'utilisateur.
- **Exemples d'utilisation** : Montre comment utiliser les commandes de manière concrète.
- **Documentation des outils** : Donne un aperçu des outils installés et leur documentation.
- **Contribution et Licence** : Invite à contribuer et fournit la licence.

Ce fichier README doit fournir toutes les informations nécessaires pour configurer et utiliser Sentinel efficacement.
