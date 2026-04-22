# Vendor Security Baseline

> Baseline criteria for product procurement and supplier review.

---

## Mandatory Input Questions

Before evaluation, capture:
- product name
- business use case
- deployment model
- users and admin roles
- data types involved
- integrations
- intended environment
- regulatory obligations touched

---

## Baseline Security Controls

Every product review should check at least:
- SSO / MFA support
- role-based access control
- strong admin separation
- encryption in transit and at rest
- audit logging and export capability
- backup / recovery commitments
- availability commitments and resilience design
- retention and deletion controls
- incident notification commitments
- subprocessor transparency
- data residency / transfer posture
- API security and integration security basics

---

## Baseline Compliance Controls

When applicable, check:
- DPA availability
- privacy terms and subprocessor list
- support for data subject rights workflows
- card-data boundary clarity
- contract language for breach notice, audit support, and termination handling

---

## Recommendation Logic

- `approve`
  Required controls are met and evidence is sufficient.

- `conditional-approve`
  Product is usable only if listed conditions are completed first.

- `reject`
  Mandatory controls are absent, risk is disproportionate, or critical evidence is missing.

---

## Typical "Should Have" Features

These should be recommended when absent:
- SSO with SAML or OIDC
- MFA for all admins
- granular RBAC
- immutable or exportable audit logs
- customer-managed retention settings
- regional hosting options
- documented backup and restore commitments
- API token scoping and rotation
- security event notification workflow
