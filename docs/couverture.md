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
