---
name: network-scan
description: >
  Network reconnaissance and vulnerability scanning: host discovery, port scanning,
  service fingerprinting, OS detection, CVE correlation, SSL/TLS audit, and
  network service enumeration (SSH, SMB, RDP, DNS, SNMP).
  Use when: starting network testing, mapping hosts in a range, identifying
  services and versions, or auditing SSL/TLS configuration.
license: MIT
compatibility: opencode
metadata:
  owner: network-pentester
  type: read-only
  approval: "No for ping sweep; Yes for port scan and service detection"
---

# network-scan

**Owner**: `network-pentester`
**Type**: `read-only` (generates network traffic — scope gate required)
**Approval**: `No (ping sweep) / Yes (port scan + service detection)`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 2 (network)

---

## What I Do

Discovers live hosts, open ports, and service versions across in-scope IP ranges.
Correlates service versions with known CVEs. Audits SSL/TLS configuration.
Produces `engagements/{id}/recon/network.md`.

---

## Scope Gate

```
1. Load engagements/{id}/scope.md — verify IP ranges/hosts in scope
2. Load authorization.md — verify expiry >= TODAY
3. Confirm scan rate with user: "I will use --max-rate={rate}. Confirm? (yes / adjust)"
4. IF scope fails → STOP
5. Log: ranges, rate, timestamp → evidence/network/scope-checks.log
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| target-ranges | scope.md | Yes |
| scan-rate | MEMORY.md → default-scan-rate | No — confirm per engagement |

Scan rate presets:
- conservative: `--max-rate 100` (production safe)
- standard: `--max-rate 500`
- aggressive: `--max-rate 2000` (lab/isolated only)

---

## Steps

```
PHASE 1 — Host Discovery (no approval required)

1. Run scope gate (rate confirmation included)

2. Ping sweep
   nmap -sn {target-ranges} --max-rate {rate} \
        -oX evidence/network/hosts.xml \
        -oG evidence/network/hosts.gnmap
   Extract: live hosts list
   Save: evidence/network/live-hosts.txt

PHASE 2 — Port Scanning (approval required)

3. Show plan and require approval
   "Port scan targets: {n} live hosts
    Scan type: -sV (service detection) -sC (default scripts)
    Top ports: 1000 (common), or full (--p-) if agreed
    Rate: --max-rate {rate}
    Proceed? (yes / no)"

4. Service scan (approved hosts)
   nmap -sV -sC -p- \
        --max-rate {rate} \
        --open \
        {live-hosts} \
        -oX evidence/network/services.xml \
        -oN evidence/network/services.txt \
        2>/dev/null
   Note: -p- scans all 65535 ports. If slow, use --top-ports 1000 first.

5. OS detection (if root/sudo available)
   nmap -O {live-hosts} --max-rate {rate} \
        -oN evidence/network/os-detection.txt 2>/dev/null

PHASE 3 — Service-Specific Enumeration

6. SSL/TLS audit (for each host with 443, 8443, or other TLS ports)
   IF sslscan available:
     sslscan --no-colour {host}:{port} > evidence/network/ssl-{host}.txt 2>/dev/null
   ELIF testssl.sh available:
     testssl.sh {host}:{port} > evidence/network/testssl-{host}.txt 2>/dev/null
   ELSE:
     openssl s_client -connect {host}:{port} -brief 2>/dev/null
   FINDING candidates:
     SSLv2/SSLv3 enabled → Critical
     TLS 1.0 enabled → Medium (deprecated)
     TLS 1.1 enabled → Low (deprecated)
     Weak ciphers (RC4, DES, 3DES, EXPORT) → High
     Expired or self-signed certificate → Medium
     BEAST, POODLE, CRIME, HEARTBLEED → Critical if confirmed

7. SSH (port 22)
   nmap -p 22 --script ssh-auth-methods,ssh-hostkey {hosts}
   Check: password auth enabled? (prefer key-only)
   FINDING: SSH password auth enabled → Low-Medium

8. SMB (ports 139, 445)
   nmap -p 445 --script smb-security-mode,smb2-security-mode {hosts}
   Check: SMB signing required?
   FINDING: SMB signing disabled → Medium (relay attack risk)
   IF enum4linux available:
     enum4linux -a {host} > evidence/network/smb-{host}.txt 2>/dev/null
     (null session enumeration attempt)

9. RDP (port 3389)
   nmap -p 3389 --script rdp-enum-encryption {hosts}
   Check: NLA (Network Level Authentication) required?
   FINDING: RDP without NLA → Medium

10. DNS (port 53)
    dig axfr {domain} @{host}  (zone transfer attempt per domain in scope)
    FINDING: zone transfer allowed → High

11. SNMP (UDP 161)
    IF snmpwalk/onesixtyone available:
      onesixtyone -c /usr/share/doc/onesixtyone/dict.txt {hosts}
    Check: default community strings (public, private)
    FINDING: SNMP with default community → Medium-High

12. CVE correlation
    Parse services.xml for service versions
    For each: {service} {version}, construct CVE query note:
      "Check NVD for {service} {version}: https://nvd.nist.gov/vuln/search?query={service}+{version}"
    IF nuclei available AND network templates exist:
      nuclei -t network/ -l evidence/network/live-hosts.txt \
             --rate-limit 10 \
             -o evidence/network/nuclei-findings.txt 2>/dev/null

13. Write report
    engagements/{id}/recon/network.md

14. Notify
    "Network scan complete.
     Live hosts: {n} | Open ports: {n} | Services: {list}
     CVE candidates: {n}
     Report: engagements/{id}/recon/network.md"
```

---

## Output

**Writes to**: `engagements/{id}/recon/network.md`

```markdown
# Network Scan — {target-ranges}

> Engagement: {engagement-id} | Date: {DATE}
> Scan rate: {rate} | Hosts scanned: {n}

## Host Inventory

| IP | Hostname | OS | Open Ports | Notes |
|---|---|---|---|---|
| {ip} | {hostname} | {linux/windows} | 22,80,443 | Web server |

## Service Summary

| IP | Port | Protocol | Service | Version |
|---|---|---|---|---|
| {ip} | 443 | tcp | https | nginx 1.18.0 |
| {ip} | 22 | tcp | ssh | OpenSSH 8.2p1 |

## SSL/TLS Findings

| Host | Issue | Severity |
|---|---|---|
| {host}:443 | TLS 1.0 enabled | Medium |
| {host}:443 | BEAST vulnerable | High |

## CVE Candidates

| Host | Service | Version | CVE | CVSS | Notes |
|---|---|---|---|---|---|
| {ip} | nginx | 1.18.0 | CVE-XXXX-XXXX | {score} | Verify at NVD |

## Service-Specific Findings

| Host | Service | Issue | Severity |
|---|---|---|---|
| {ip} | SMB/445 | Signing disabled | Medium |
| {ip} | RDP/3389 | NLA not required | Medium |

## Attack Surface Summary

Internet-facing services:   {n}
Potential CVE matches:      {n}
SSL/TLS issues:             {n}
High-interest services:     {list}

---
*Next step: network-exploit for CVE verification and service exploitation*
```

---

## Error Handling

| Condition | Action |
|---|---|
| nmap not found | Stop. Notify: "nmap is required for network scanning." |
| No live hosts found | Verify scope ranges, check network connectivity, confirm with user. |
| Scan causes packet loss / disruption | Stop scan immediately. Reduce rate. Notify red-team-lead. |
| ICMP blocked (ping sweep fails) | Try: nmap -Pn (no ping). Notify user that host discovery is less reliable. |
| Host outside scope responds | Pause. Verify with scope.md. Do not continue scanning unverified hosts. |
