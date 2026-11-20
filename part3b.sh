#!/usr/bin/env bash
set -euo pipefail
echo "==> PART 3b — README, commit, push..."

cat > README.md << 'EOF'
# satom-leman-portail-MF

Projet : SatomCloudNetwork — Groupe Leman Finance SA
Etudiant : MF — Satom IT & Learning Solutions
Region AWS : eu-central-2

## Perimetre traite

| Element | Statut |
|---|---|
| Gate G0 — Fondations | EN COURS |
| Sprint 1 — VPC et sous-reseaux | NON TRAITE |
| Sprint 2 — Routage | NON TRAITE |
| Sprint 3 — Security Groups et NACL | NON TRAITE |
| Sprint 4 — Network Firewall | NON TRAITE |
| Sprint 5 — VPC Peering | NON TRAITE |
| Gate G1 — Pipeline verte | NON TRAITE |
| Gate G2 — Mesures sprints 4 et 5 | NON TRAITE |
| Sprints 6 a 13 | NON TRAITE — Hors perimetre |

## Structure du depot

templates/    CloudFormation — un fichier par domaine
parameters/   dev.json et prod.json
policies/     cfn-guard et IAM
app/          Application Python port 8080
sbom/         SBOM CycloneDX genere par la pipeline
docs/adr/     ADR-001 a ADR-008
docs/         couverture.md et journal.md
scripts/      Utilitaires pipeline
.github/      Workflows GitHub Actions

## Demarrage rapide

cfn-lint templates/*.yaml

cfn-guard validate \
  --data templates/network.yaml \
  --rules policies/cfn-guard/

cd app && pip install -r requirements-dev.txt
pytest tests/ --cov=src --cov-report=xml

## Suppression des ressources facturees en fin de session

aws cloudformation update-stack \
  --stack-name stack-leman-prod \
  --use-previous-template \
  --parameters ParameterKey=NatEnabled,ParameterValue=false \
               ParameterKey=FwEnabled,ParameterValue=false \
  --region eu-central-2

## Decisions d'architecture
Voir docs/adr/

## Couverture des controles
Voir docs/couverture.md
EOF

echo "==> Initialisation git..."
git init
git remote add origin https://github.com/MFelipe06/satom-leman-portail-MF.git

echo "==> Ajout de tous les fichiers..."
git add .

echo "==> Commit initial G0..."
git commit -m "chore: G0 — structure depot, ADR 001-008, templates placeholders, pipeline, app minimale"

echo "==> Push vers GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "============================================================"
echo "  G0 TERMINE — depot pousse sur GitHub"
echo ""
echo "  Prochaines etapes :"
echo "  1. Proteger la branche main :"
echo "     https://github.com/MFelipe06/satom-leman-portail-MF/settings/branches"
echo "  2. Activer SonarCloud :"
echo "     https://sonarcloud.io"
echo "  3. Creer le budget 150 CHF :"
echo "     https://console.aws.amazon.com/billing/home#/budgets/create"
echo "  4. Donner ton Account ID AWS pour le role OIDC :"
echo "     aws sts get-caller-identity --query Account --output text"
echo "============================================================"
