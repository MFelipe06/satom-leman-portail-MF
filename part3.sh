#!/usr/bin/env bash
set -euo pipefail
echo "==> PART 3 — ADRs, docs, README, commit, push..."

# ── docs/adr/ADR-001 ─────────────────────────────────────────
cat > docs/adr/ADR-001-environnements.md << 'EOF'
# ADR-001 — Strategie des environnements et des stacks

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Contexte
Le dossier demande deux stacks (dev et prod) a partir des memes templates,
et un vpc-dev-leman en 10.1.0.0/16 au sprint 5.

## Decision
- stack-leman-prod deploie templates/network.yaml avec parameters/prod.json -> VPC 10.0.0.0/16
- stack-leman-dev deploie templates/network.yaml avec parameters/dev.json -> VPC 10.1.0.0/16
- stack-leman-peering deploie templates/peering.yaml et importe les outputs des deux stacks
- NAT Gateway et Network Firewall sont conditionnels (NatEnabled, FwEnabled)
- Region : eu-central-2

## Raison
Evite la dependance circulaire entre les deux stacks pour le peering.
Permet le controle des couts par parametre sans restructurer les templates.

## Consequences
- Les labs manuels (eu-north-1) servent de reference uniquement.
- Tout deploiement passe par la pipeline GitHub Actions.

## Risques acceptes
Aucun.

## Date de revue
Fin sprint 5.
EOF

# ── docs/adr/ADR-002 ─────────────────────────────────────────
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
| (reserve db) | 10.0.3.0/24 | — | Base de donnees | 6+ |
| sub-fw-1a-MF | 10.0.4.0/28 | eu-central-2a | Network Firewall | 4 |
| sub-public-1b-MF | 10.0.5.0/24 | eu-central-2b | Public zone b | 1 |
| sub-prive-1b-MF | 10.0.6.0/24 | eu-central-2b | Prive zone b | 1 |
| sub-fw-1b-MF | 10.0.7.0/28 | eu-central-2b | Firewall zone b (reserve) | 6+ |
| sub-dev-1a-MF | 10.1.1.0/24 | eu-central-2a | Dev zone a | 5 |

## Risques acceptes
Firewall sans HA jusqu'au sprint 6.

## Date de revue
Sprint 6.
EOF

# ── docs/adr/ADR-003 ─────────────────────────────────────────
cat > docs/adr/ADR-003-sg-alb-dast.md << 'EOF'
# ADR-003 — sg-alb-MF placeholder et DAST ZAP sans ALB

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
- sg-alb-MF cree comme placeholder des le sprint 3
- sg-web reference sg-alb-MF comme source pour le port 80
- ZAP baseline scan vise web-01-MF directement au sprint 3
- Scan ZAP complet via ALB reporte au sprint 9

## Derogation
ZAP baseline incomplet sans ALB — documente dans docs/couverture.md.

## Date de revue
Sprint 9.
EOF

# ── docs/adr/ADR-004 ─────────────────────────────────────────
cat > docs/adr/ADR-004-runner-ssm.md << 'EOF'
# ADR-004 — Runner GitHub heberge et SSM Run Command

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
- Runner GitHub heberge pour tous les appels API AWS
- dev-01-MF demarre de facon ephemere via SSM Run Command pour les tests reseau
- Instance arretee apres chaque test

## Raison
Cout minimal, pas de port d'administration ouvert.

## Risques acceptes
Si dev-01-MF ne demarre pas, le job echoue.
Mitigation : aws ec2 wait instance-running avec timeout 5 minutes.

## Date de revue
Sprint 5.
EOF

# ── docs/adr/ADR-005 ─────────────────────────────────────────
cat > docs/adr/ADR-005-sonarcloud.md << 'EOF'
# ADR-005 — SonarCloud pour l'analyse qualite

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
SonarCloud gratuit (depot public GitHub) avec sonar.qualitygate.wait=true.

## Quality gate
- 0 issue Blocker ou Critical
- 100 % security hotspots revus
- Duplication < 3 %
- Couverture nouvelles lignes >= 80 %
- Notes A (maintenabilite, fiabilite, securite)

## Date de revue
Sprint 1.
EOF

# ── docs/adr/ADR-006 ─────────────────────────────────────────
cat > docs/adr/ADR-006-revue-solo.md << 'EOF'
# ADR-006 — Relecture des pull requests en solo

- **Date :** 2026-11-20
- **Statut :** Acceptee (derogation)
- **Proprietaire :** MF

## Decision
Auto-revue structuree avec checklist dans chaque PR.
Voir .github/pull_request_template.md.

## Compensation
Pipeline bloquante sur tous les controles automatiques
(cfn-lint, cfn-guard, checkov, gitleaks, Semgrep, Trivy, SonarQube).

## Date de revue
Avant soutenance.
EOF

# ── docs/adr/ADR-007 ─────────────────────────────────────────
cat > docs/adr/ADR-007-ssm-session-manager.md << 'EOF'
# ADR-007 — Acces aux instances via SSM Session Manager

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
SSM Session Manager avec role AmazonSSMManagedInstanceCore.
Acces sortant via NAT Gateway quand NatEnabled=true.
Aucun port 22 ou 3389 ouvert.

## Risques acceptes
SSM indisponible si NAT desactivee et instances allumees.
Mitigation : arreter les instances avec la NAT.

## Date de revue
Sprint 2.
EOF

# ── docs/adr/ADR-008 ─────────────────────────────────────────
cat > docs/adr/ADR-008-security-hub.md << 'EOF'
# ADR-008 — Security Hub active des G0

- **Date :** 2026-11-20
- **Statut :** Acceptee
- **Proprietaire :** MF

## Decision
Security Hub active dans templates/supervision.yaml des G0.
AWS Config active comme prerequis.

## Raison
30 jours gratuits couvrent la duree du TP.
Findings reels sur VPC, SG, EC2 des le sprint 1.

## Rapport partiel
Findings des sprints 6-13 absents — documente dans docs/couverture.md.

## Cout estime
0 USD pendant les 30 premiers jours. < 5 USD/mois ensuite.

## Date de revue
Sprint 12.
EOF

# ── docs/couverture.md ───────────────────────────────────────
cat > docs/couverture.md << 'EOF'
# Tableau de couverture — satom-leman-portail-MF

Derniere mise a jour : 2026-11-20

## Legende
| Symbole | Signification |
|---|---|
| OK | Vert avec preuve |
| EN COURS | En cours |
| NON TRAITE | Non traite |
| DEROGATION | Derogation — voir ADR |

## Gate G0 — Fondations

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| Depot GitHub cree | EN COURS | — | — |
| Branche main protegee | EN COURS | — | — |
| OIDC GitHub -> IAM configure | EN COURS | — | — |
| Budget 150 CHF + alerte 80 % | EN COURS | — | — |
| Security Hub active | EN COURS | — | ADR-008 |
| AWS Config active | EN COURS | — | ADR-008 |
| ADR 001 a 008 commitees | EN COURS | — | — |

## Sprint 1 — VPC et sous-reseaux

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| Template network.yaml deploye | NON TRAITE | — | — |
| VPC 10.0.0.0/16 cree | NON TRAITE | — | — |
| 6 sous-reseaux crees (plan ADR-002) | NON TRAITE | — | ADR-002 |
| Aucun sous-reseau prive route vers IGW | NON TRAITE | — | — |
| cfn-guard no-private-subnet-igw vert | NON TRAITE | — | — |
| checkov vert | NON TRAITE | — | — |
| SonarQube quality gate vert | NON TRAITE | — | ADR-005 |
| Mesure : describe-subnets | NON TRAITE | — | — |

## Sprint 2 — Routage

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| IGW creee et attachee | NON TRAITE | — | — |
| NAT Gateway conditionnelle | NON TRAITE | — | ADR-001 |
| Table de routage publique | NON TRAITE | — | — |
| Table de routage privee | NON TRAITE | — | — |
| web-01-MF et app-01-MF deployes | NON TRAITE | — | — |
| Volumes EBS chiffres | NON TRAITE | — | — |
| Mesure : sortie app-01 vers depot de paquets | NON TRAITE | — | ADR-004 |

## Sprint 3 — Security Groups et NACL

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| sg-web-MF cree | NON TRAITE | — | ADR-003 |
| sg-alb-MF placeholder cree | NON TRAITE | — | ADR-003 |
| sg-app-MF cree | NON TRAITE | — | — |
| NACL publique configuree | NON TRAITE | — | — |
| DAST ZAP baseline sur web-01-MF | NON TRAITE | — | ADR-003 |
| Reachability Analyzer web-01->app-01:8080 | NON TRAITE | — | — |

## Sprint 4 — Network Firewall

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| sub-fw-1a-MF cree (10.0.4.0/28) | NON TRAITE | — | ADR-002 |
| Network Firewall conditionnel | NON TRAITE | — | ADR-001 |
| Politique stateful + liste blanche domaines | NON TRAITE | — | — |
| Test domaine bloque + journalise | NON TRAITE | — | ADR-004 |

## Sprint 5 — VPC Peering

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| vpc-dev-leman-MF cree (10.1.0.0/16) | NON TRAITE | — | ADR-001 |
| dev-01-MF deploye (10.1.1.10) | NON TRAITE | — | — |
| Peering pcx-lab-MF actif | NON TRAITE | — | — |
| Routes limitees au CIDR du pair | NON TRAITE | — | — |
| Script check-cidr-overlap.py vert | NON TRAITE | — | — |
| Mesure : dev-01->app-01:8080 accessible | NON TRAITE | — | ADR-004 |

## Gate G1 — Pipeline verte

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| cfn-lint vert | NON TRAITE | — | — |
| cfn-guard vert | NON TRAITE | — | — |
| checkov vert | NON TRAITE | — | — |
| gitleaks vert | NON TRAITE | — | — |
| Semgrep vert | NON TRAITE | — | — |
| Trivy vert | NON TRAITE | — | — |
| SonarQube quality gate vert | NON TRAITE | — | ADR-005 |
| SBOM CycloneDX genere | NON TRAITE | — | — |
| Deploiement dev par change set | NON TRAITE | — | — |
| Validation manuelle avant prod | NON TRAITE | — | — |

## Gate G2 — Mesures sprints 4 et 5

| Controle | Statut | Preuve | ADR |
|---|---|---|---|
| Domaine bloque par Firewall + journal | NON TRAITE | — | ADR-004 |
| dev-01->app-01:8080 accessible | NON TRAITE | — | ADR-004 |
| dev-01->web-01:22 bloque | NON TRAITE | — | ADR-004 |

## Sprints 6 a 13 — Hors perimetre

| Sprint | Statut | Note |
|---|---|---|
| Sprint 6 — Transit Gateway | NON TRAITE | Placeholder dans templates/ |
| Sprint 7 — VPN Site-to-Site | NON TRAITE | Placeholder dans templates/ |
| Sprint 8 — Direct Connect | NON TRAITE | Placeholder dans templates/ |
| Sprint 9 — ALB | NON TRAITE | Placeholder dans templates/edge.yaml |
| Sprint 10 — Route 53 | NON TRAITE | Placeholder dans templates/edge.yaml |
| Sprint 11 — CloudFront | NON TRAITE | Placeholder dans templates/edge.yaml |
| Sprint 12 — Supervision | NON TRAITE | Security Hub active en G0 (ADR-008) |
| Sprint 13 — Reprise apres sinistre | NON TRAITE | — |
EOF

# ── docs/journal.md ──────────────────────────────────────────
cat > docs/journal.md << 'EOF'
# Journal de projet — satom-leman-portail-MF

## Format des entrees
- Date et sprint
- Ce qui a ete fait
- Indicateurs DORA
- Couts de la session
- Prochaine etape

---

## G0 — 2026-11-20 — Fondations

### Ce qui a ete fait
- Structure du depot creee via scripts bash (part1/part2/part3)
- ADR 001 a 008 commitees
- Templates placeholders crees (network, security, compute, peering, edge, supervision)
- Pipeline GitHub Actions creee
- Application minimale Python creee avec tests unitaires
- docs/couverture.md initialise

### Indicateurs DORA
| Indicateur | Valeur | Note |
|---|---|---|
| Frequence de deploiement | 0 | Aucun deploiement AWS encore |
| Delai de mise en production | — | Non applicable |
| Taux d'echec des changements | — | Non applicable |
| MTTR | — | Non applicable |

### Couts de la session
| Ressource | Cout |
|---|---|
| Aucune ressource AWS deployee | 0 CHF |

### Prochaine etape
Sprint 1 — template network.yaml complet, VPC et sous-reseaux,
OIDC GitHub -> IAM, budget AWS.
EOF

# ── README.md ────────────────────────────────────────────────
cat > README.md << 'EOF'
# satom-leman-portail-MF

**Projet :** SatomCloudNetwork — Groupe Leman Finance SA
**Etudiant :** MF — Satom IT & Learning Solutions
**Region AWS :** eu-central-2

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

