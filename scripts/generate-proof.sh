#!/usr/bin/env bash
# Produit une preuve datée de l'état du code de JADIS Feel, sans publier le code.
# La preuve ne contient que des empreintes : ni nom de fichier, ni chemin, ni
# message d'enregistrement, qui décriraient la structure du code (décision du
# 12/10/2026). L'empreinte porte sur les fichiers du dernier enregistrement, et
# non sur le dossier : elle se refait à l'identique depuis n'importe quelle copie
# du dépôt, et ni les dépendances installées ni le fichier des secrets n'y entrent.
#
# Lancement depuis PowerShell, par le bash de Git :
#   & "C:\Program Files\Git\bin\bash.exe" scripts/generate-proof.sh "<dossier du dépôt de code>"
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage : generate-proof.sh <dossier du dépôt de code> [dossier du dépôt de preuve]"
  exit 1
fi

SOURCE_REPO="$1"
PROOF_REPO="${2:-$(pwd)}"
OUTPUT_DIR="${PROOF_REPO}/proofs"
DATE_STAMP="$(date -u +%Y-%m-%d)"
TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if ! git -C "${SOURCE_REPO}" rev-parse --git-dir > /dev/null 2>&1; then
  echo "Erreur : ce dossier n'est pas un dépôt Git : ${SOURCE_REPO}"
  exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cd "${SOURCE_REPO}"

BRANCHE="$(git branch --show-current)"
ENREGISTREMENT="$(git rev-parse HEAD)"
DATE_ENREGISTREMENT="$(git log -1 --format=%cI)"
ARBRE="$(git rev-parse 'HEAD^{tree}')"
if git cat-file -p HEAD | grep -q '^gpgsig'; then SIGNATURE="signé"; else SIGNATURE="non signé"; fi

# L'empreinte de chaque fichier tel qu'enregistré, puis l'empreinte de la liste
# entière. La liste reste en mémoire : seule l'empreinte finale est publiée.
EMPREINTE="$(
  git ls-tree -r -z --name-only HEAD | sort -z |
  while IFS= read -r -d '' FICHIER; do
    printf '%s  %s\n' "$(git cat-file blob "HEAD:${FICHIER}" | sha256sum | cut -d' ' -f1)" "${FICHIER}"
  done | sha256sum | cut -d' ' -f1
)"

cat > "${OUTPUT_DIR}/jadis-feel-IA-${DATE_STAMP}.json" <<EOF
{
  "projet": "JADIS Feel",
  "depot_prive": "Imorpheu/jadis-feel-IA",
  "auteur": "Imorpheu",
  "date_de_la_preuve": "${TIMESTAMP}",
  "branche": "${BRANCHE}",
  "enregistrement": "${ENREGISTREMENT}",
  "date_de_l_enregistrement": "${DATE_ENREGISTREMENT}",
  "signature_de_l_enregistrement": "${SIGNATURE}",
  "arbre_git": "${ARBRE}",
  "empreinte_sha256_des_fichiers_enregistres": "${EMPREINTE}"
}
EOF

cat > "${OUTPUT_DIR}/jadis-feel-IA-${DATE_STAMP}.txt" <<EOF
PREUVE DE CRÉATION ET D'INTÉGRITÉ — JADIS FEEL

Date de la preuve        : ${TIMESTAMP}
Dépôt privé              : Imorpheu/jadis-feel-IA
Auteur                   : Imorpheu
Branche                  : ${BRANCHE}
Enregistrement           : ${ENREGISTREMENT}
Date de l'enregistrement : ${DATE_ENREGISTREMENT}
Signature                : ${SIGNATURE}
Arbre Git                : ${ARBRE}
Empreinte SHA-256        : ${EMPREINTE}

Ce dépôt ne contient pas le code source : seulement des empreintes, qui
permettent de vérifier qu'une copie du code correspond à cette date.
EOF

echo "Preuve écrite dans ${OUTPUT_DIR}"
echo "Enregistrement : ${ENREGISTREMENT} (${SIGNATURE})"
echo "Empreinte      : ${EMPREINTE}"
