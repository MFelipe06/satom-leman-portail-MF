## Sprint concerne
<!-- ex: Sprint 1 — VPC et sous-reseaux -->

## Description
<!-- Resume des changements -->

## Checklist de revue — auto-revue MF (ADR-006)

### Conformite
- [ ] cfn-lint sans erreur
- [ ] cfn-guard et checkov verts
- [ ] Aucun secret dans le diff (gitleaks vert)
- [ ] Conventional Commit respecte
- [ ] ADR presente si decision significative

### Securite
- [ ] Aucun port 22 ou 3389 ouvert a 0.0.0.0/0
- [ ] Tags presents sur toutes les ressources
- [ ] Volumes EBS chiffres si applicable
- [ ] Aucune cle longue duree dans le code

### Tests
- [ ] Mesure documentee dans docs/couverture.md
- [ ] Entree ajoutee dans docs/journal.md
- [ ] Pipeline verte sur la branche de la PR

### Nettoyage
- [ ] NAT et Firewall desactivables par parametre
- [ ] Aucune ressource orpheline creee manuellement
