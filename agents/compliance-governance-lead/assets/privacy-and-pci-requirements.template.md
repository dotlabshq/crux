# Privacy And PCI Requirements

> Reference notes for GDPR, KVKK, and PCI-DSS oriented work in Crux.
> This file helps structure assessments; it does not replace legal counsel or QSA advice.

---

## GDPR / KVKK Themes

Focus areas that usually need explicit treatment:
- lawful basis and purpose limitation
- transparency and privacy notices
- processor / controller roles
- cross-border transfer and residency
- retention and deletion
- access control and least privilege
- logging, monitoring, and breach response
- supplier / subprocessor governance
- data subject request handling

---

## PCI-DSS Themes

Questions to answer early:
- does the organisation store, process, or transmit cardholder data directly?
- is the product in or connected to cardholder data environment (CDE)?
- who controls encryption, segmentation, logging, vulnerability management, and access review?

Core areas commonly reviewed:
- network segregation
- strong authentication and access control
- key management and encryption
- audit logging
- secure configuration
- vulnerability management
- supplier responsibility boundaries

---

## Cross-Framework Practical Mapping

Repeated control families across privacy and payment work:
- IAM and least privilege
- logging and accountability
- encryption and key handling
- data minimisation
- retention and secure deletion
- supplier due diligence
- incident and breach handling
- secure configuration and patching

---

## Assessment Rule

When a requirement is in scope, mark each control one of:
- implemented
- partial
- missing
- not applicable
- evidence missing

Never collapse "vendor says yes" into "implemented" without noting evidence quality.
