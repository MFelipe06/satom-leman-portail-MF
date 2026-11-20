#!/usr/bin/env bash
set -euo pipefail
echo "==> PART 3a — ADRs et docs..."

cat > docs/adr/ADR-001-environnements.md << 'EOF'
# ADR-001 — Strategie des environnements et des stacks
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
- stack-leman-prod -> parameters/prod.json -> VPC 10.0.0.0/16
- stack-leman-dev -> parameters/dev.json -> VPC 10.1.0.0/16
- stack-leman-peering -> templates/peering.yaml
- NAT Gateway et Network Firewall conditionnels (NatEnabled, FwEnabled)
- Region : eu-central-2

## Raison
Evite la dependance circulaire entre les deux stacks pour le peering.
Permet le controle des couts par parametre.

## Date de revue
Fin sprint 5.
EOF

cat > docs/adr/ADR-002-sous-reseaux.md << 'EOF'
# ADR-002 — Plan d'adressage des sous-reseaux
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision

| Nom | CIDR | Zone | Usage | Sprint |
|---|---|---|---|---|
| sub-public-1a-MF | 10.0.1.0/24 | eu-central-2a | Public zone a | 1 |
| sub-prive-1a-MF | 10.0.2.0/24 | eu-central-2a | Prive zone a | 1 |
| reserve db | 10.0.3.0/24 | — | Base de donnees | 6+ |
| sub-fw-1a-MF | 10.0.4.0/28 | eu-central-2a | Network Firewall | 4 |
| sub-public-1b-MF | 10.0.5.0/24 | eu-central-2b | Public zone b | 1 |
| sub-prive-1b-MF | 10.0.6.0/24 | eu-central-2b | Prive zone b | 1 |
| sub-fw-1b-MF | 10.0.7.0/28 | eu-central-2b | Firewall zone b reserve | 6+ |
| sub-dev-1a-MF | 10.1.1.0/24 | eu-central-2a | Dev zone a | 5 |

## Date de revue
Sprint 6.
EOF

cat > docs/adr/ADR-003-sg-alb-dast.md << 'EOF'
# ADR-003 — sg-alb-MF placeholder et DAST ZAP sans ALB
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
- sg-alb-MF cree comme placeholder des le sprint 3
- ZAP baseline scan vise web-01-MF directement au sprint 3
- Scan ZAP complet via ALB reporte au sprint 9

## Date de revue
Sprint 9.
EOF

cat > docs/adr/ADR-004-runner-ssm.md << 'EOF'
# ADR-004 — Runner GitHub heberge et SSM Run Command
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
- Runner GitHub heberge pour tous les appels API AWS
- dev-01-MF demarre via SSM Run Command pour les tests reseau
- Instance arretee apres chaque test

## Date de revue
Sprint 5.
EOF

cat > docs/adr/ADR-005-sonarcloud.md << 'EOF'
# ADR-005 — SonarCloud pour l'analyse qualite
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
SonarCloud gratuit avec sonar.qualitygate.wait=true.

## Quality gate
- 0 issue Blocker ou Critical
- Duplication < 3 %
- Couverture nouvelles lignes >= 80 %
- Notes A (maintenabilite, fiabilite, securite)

## Date de revue
Sprint 1.
EOF

cat > docs/adr/ADR-006-revue-solo.md << 'EOF'
# ADR-006 — Relecture des pull requests en solo
- **Date :** 2026-11-20
- **Statut :** Acceptee (derogation)
- **Proprietaire :** MF

## Decision
Auto-revue structuree avec checklist dans chaque PR.
Pipeline bloquante sur tous les controles automatiques.

## Date de revue
Avant soutenance.
EOF

cat > docs/adr/ADR-007-ssm-session-manager.md << 'EOF'
# ADR-007 — Acces aux instances via SSM Session Manager
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
SSM Session Manager avec role AmazonSSMManagedInstanceCore.
Aucun port 22 ou 3389 ouvert.

## Date de revue
Sprint 2.
EOF

cat > docs/adr/ADR-008-security-hub.md << 'EOF'
# ADR-008 — Security Hub active des G0
- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
Security Hub active dans templates/supervision.yaml des G0.
AWS Config active comme prerequis.
30 jours gratuits couvrent la duree du TP.

## Date de revue
Sprint 12.
EOF

cat > docs/journal.md << 'EOF'
# Journal de projet — satom-leman-portail-MF

## G0 — 2026-11-20 — Fondations

### Ce qui a ete fait
- Structure du depot creee via scripts bash
- ADR 001 a 008 commitees
- Templates placeholders crees
- Pipeline GitHub Actions creee
- Application minimale Python avec tests unitaires
- docs/couverture.md initialise

### Indicateurs DORA
| Indicateur | Valeur |
|---|---|
| Frequence de deploiement | 0 |
| Delai de mise en production | Non applicable |
| Taux d'echec des changements | Non applicable |
| MTTR | Non applicable |

### Couts de la session
Aucune ressource AWS deployee — 0 CHF

### Prochaine etape
Sprint 1 — network.yaml complet, VPC, sous-reseaux, OIDC, budget AWS.
EOF

cat > docs/couverture.md << 'EOF'
# Tableau de couverture — satom-leman-portail-MF
Derniere mise a jour : 2026-11-20

## Gate G0 — Fondations
| Controle | Statut | ADR |
|---|---|---|
| Depot GitHub cree | EN COURS | — |
| Branche main protegee | EN COURS | — |
| OIDC GitHub -> IAM configure | EN COURS | — |
| Budget 150 CHF + alerte 80 % | EN COURS | — |
| Security Hub active | EN COURS | ADR-008 |
| AWS Config active | EN COURS | ADR-008 |
| ADR 001 a 008 commitees | EN COURS | — |

## Sprint 1 — VPC et sous-reseaux
| Controle | Statut | ADR |
|---|---|---|
| Template network.yaml deploye | NON TRAITE | — |
| VPC 10.0.0.0/16 cree | NON TRAITE | — |
| 6 sous-reseaux crees | NON TRAITE | ADR-002 |
| cfn-guard no-private-subnet-igw vert | NON TRAITE | — |
| checkov vert | NON TRAITE | — |
| SonarQube quality gate vert | NON TRAITE | ADR-005 |

## Sprint 2 — Routage
| Controle | Statut | ADR |
|---|---|---|
| IGW creee et attachee | NON TRAITE | — |
| NAT Gateway conditionnelle | NON TRAITE | ADR-001 |
| Tables de routage publique et privee | NON TRAITE | — |
| web-01-MF et app-01-MF deployes | NON TRAITE | — |
| Volumes EBS chiffres | NON TRAITE | — |

## Sprint 3 — Security Groups et NACL
| Controle | Statut | ADR |
|---|---|---|
| sg-web-MF cree | NON TRAITE | ADR-003 |
| sg-alb-MF placeholder cree | NON TRAITE | ADR-003 |
| sg-app-MF cree | NON TRAITE | — |
| NACL publique configuree | NON TRAITE | — |
| DAST ZAP baseline | NON TRAITE | ADR-003 |

## Sprint 4 — Network Firewall
| Controle | Statut | ADR |
|---|---|---|
| sub-fw-1a-MF cree | NON TRAITE | ADR-002 |
| Network Firewall conditionnel | NON TRAITE | ADR-001 |
| Politique stateful + liste blanche | NON TRAITE | — |
| Test domaine bloque + journalise | NON TRAITE | ADR-004 |

## Sprint 5 — VPC Peering
| Controle | Statut | ADR |
|---|---|---|
| vpc-dev-leman-MF cree | NON TRAITE | ADR-001 |
| dev-01-MF deploye | NON TRAITE | — |
| Peering pcx-lab-MF actif | NON TRAITE | — |
| Routes limitees au CIDR du pair | NON TRAITE | — |
| Script check-cidr-overlap.py vert | NON TRAITE | — |

## Gate G1 — Pipeline verte
| Controle | Statut | ADR |
|---|---|---|
| cfn-lint vert | NON TRAITE | — |
| cfn-guard vert | NON TRAITE | — |
| checkov vert | NON TRAITE | — |
| gitleaks vert | NON TRAITE | — |
| Semgrep vert | NON TRAITE | — |
| Trivy vert | NON TRAITE | — |
| SonarQube quality gate vert | NON TRAITE | ADR-005 |
| SBOM CycloneDX genere | NON TRAITE | — |

## Gate G2 — Mesures sprints 4 et 5
| Controle | Statut | ADR |
|---|---|---|
| Domaine bloque par Firewall | NON TRAITE | ADR-004 |
| dev-01->app-01:8080 accessible | NON TRAITE | ADR-004 |
| dev-01->web-01:22 bloque | NON TRAITE | ADR-004 |

## Sprints 6 a 13 — Hors perimetre
| Sprint | Note |
|---|---|
| Sprint 6 — Transit Gateway | Placeholder dans templates/ |
| Sprint 7 — VPN Site-to-Site | Placeholder dans templates/ |
| Sprint 8 — Direct Connect | Placeholder dans templates/ |
| Sprint 9 — ALB | Placeholder dans templates/edge.yaml |
| Sprint 10 — Route 53 | Placeholder dans templates/edge.yaml |
| Sprint 11 — CloudFront | Placeholder dans templates/edge.yaml |
| Sprint 12 — Supervision | Security Hub active en G0 (ADR-008) |
| Sprint 13 — Reprise apres sinistre | Non traite |
EOF

echo "==> PART 3a terminee."
