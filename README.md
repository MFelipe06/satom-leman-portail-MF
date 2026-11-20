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
