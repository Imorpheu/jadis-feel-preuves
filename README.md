# JADIS Feel — preuves d'antériorité

Ce dépôt public garde des preuves datées de l'existence et de l'intégrité
du code de JADIS Feel. Il ne contient pas le code source : seulement des empreintes.

## Ce que contient une preuve
- la date de la preuve ;
- l'identifiant de l'enregistrement Git prouvé, sa date et sa signature ;
- l'empreinte SHA-256 de l'ensemble des fichiers enregistrés.

## Comment la vérifier
Depuis une copie du dépôt privé, placée sur l'enregistrement indiqué :

    git checkout <enregistrement>
    bash scripts/generate-proof.sh <dossier du dépôt privé> <dossier temporaire>

L'empreinte obtenue doit être identique à celle publiée. La date de chaque
preuve est celle que GitHub enregistre quand elle est ajoutée à ce dépôt.

## Rangement
- `proofs/` : une preuve par date, en JSON et en texte.
- `scripts/generate-proof.sh` : le calcul.

Auteur : Imorpheu. Dépôt ouvert le 14/10/2026.
