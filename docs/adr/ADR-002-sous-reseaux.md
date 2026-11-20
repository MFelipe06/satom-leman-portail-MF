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
