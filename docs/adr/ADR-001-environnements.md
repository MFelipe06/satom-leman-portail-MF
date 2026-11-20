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
