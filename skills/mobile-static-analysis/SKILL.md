---
name: mobile-static-analysis
description: >
  Static analysis of Android APK or iOS IPA: decompilation, manifest inspection,
  hardcoded secrets detection, insecure data storage patterns, certificate pinning
  detection, exported components, and deep link analysis. No device required.
  Use when: APK or IPA provided, starting mobile engagement, or user requests
  "analyse app", "decompile APK", "check for hardcoded secrets".
license: MIT
compatibility: opencode
metadata:
  owner: mobile-pentester
  type: read-only
  approval: "No — static analysis only, no device interaction"
---

# mobile-static-analysis

**Owner**: `mobile-pentester`
**Type**: `read-only` (no device contact)
**Approval**: `No`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 2 (mobile)

---

## What I Do

Decompiles the mobile application binary, inspects configuration and source code
for security issues, and produces a static analysis report.
No device or network connection required.

---

## Scope Gate

```
1. Load engagements/{id}/scope.md — verify app path is in scope
2. Load authorization.md — verify expiry >= TODAY
3. IF either fails → STOP
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| app-path | scope.md or user | Yes — /path/to/app.apk or /path/to/app.ipa |
| platform | MEMORY.md | Yes — android | ios |

---

## Steps (Android APK)

```
1. Run scope gate

2. Verify file
   file {app-path}
   ls -lh {app-path}
   IF not APK → stop: "File does not appear to be an APK."

3. Decompile with apktool (resources + manifest)
   apktool d {app-path} -o engagements/{id}/evidence/mobile/apktool-out/ --force
   Extract: AndroidManifest.xml, res/, smali/

4. Decompile with jadx (Java source)
   jadx -d engagements/{id}/evidence/mobile/jadx-out/ {app-path} 2>/dev/null
   OR: jadx-gui (note: use CLI only)

5. AndroidManifest.xml analysis
   File: engagements/{id}/evidence/mobile/apktool-out/AndroidManifest.xml
   Check:
     android:debuggable="true"    → FINDING: debug enabled (High)
     android:allowBackup="true"   → FINDING: backup enabled (Low-Medium)
     android:usesCleartextTraffic="true" → FINDING: cleartext traffic (High)
     Exported activities (exported="true" without permission) → FINDING: exported component
     Exported content providers → FINDING: data exposure risk
     Deep links defined (<intent-filter> with data scheme) → note for further testing

6. Hardcoded secrets search
   Search in decompiled source:
     grep -r "api_key\|apikey\|api-key" jadx-out/ --include="*.java" -l
     grep -r "secret\|password\|passwd\|pwd" jadx-out/ --include="*.java" -l
     grep -r "AKIA[0-9A-Z]{16}" jadx-out/ -r  (AWS access key)
     grep -r "AIza[0-9A-Za-z_-]{35}" jadx-out/ -r  (Google API key)
     grep -r "-----BEGIN.*PRIVATE KEY" jadx-out/ -r  (private key)
     grep -r "jdbc:\|mongodb://\|postgres://" jadx-out/ -r  (DB connection strings)
   For each match: record file, line, context (surrounding 3 lines)
   FINDING: any hardcoded credential → Critical

7. Insecure data storage patterns
   Search for:
     SharedPreferences.putString (look for sensitive key names)
     SQLiteDatabase.execSQL (look for CREATE TABLE with password/token columns)
     getExternalStorageDirectory (external storage usage)
     openFileOutput with MODE_WORLD_READABLE
   FINDING: sensitive data in SharedPreferences unencrypted → Medium-High
   FINDING: external storage for sensitive data → High

8. Certificate pinning detection
   Search for:
     "CertificatePinner\|TrustManager\|SSLSocketFactory\|checkServerTrusted"
     "okhttp\|certificate_pinning\|pinning"
     In network_security_config.xml: <pin-set> elements
   Record: pinning-detected (yes/no), implementation type
   Note: relevant for dynamic analysis phase

9. Weak cryptography
   Search for:
     "DES\|MD5\|SHA1\|ECB\|RC4"
     "Cipher.getInstance(\"AES\")"  (no mode/padding = ECB)
   FINDING: weak crypto → Medium

10. Insecure random
    Search: "Math.random()\|java.util.Random"
    FINDING if used for security-sensitive purpose → Medium

11. Logging sensitive data
    Search: "Log.d\|Log.v\|Log.i\|Log.e\|System.out.print"
    Look for: password, token, key in log arguments
    FINDING: sensitive data in logs → Medium

12. Network security config
    File: res/xml/network_security_config.xml (if exists)
    Check:
      <domain-config cleartextTrafficPermitted="true"> → FINDING
      <debug-overrides> with user-defined CAs → note for dynamic
      No pinning defined → note (not a finding, but relevant)

13. Write report
    engagements/{id}/recon/mobile.md
    Save all finding candidates to: evidence/mobile/static-findings.md

14. Notify
    "Static analysis complete.
     APK: {app-path}
     Confirmed findings: {n}
     Potential findings: {n}
     Report: engagements/{id}/recon/mobile.md
     Dynamic analysis recommended: {yes — device required | no}"
```

---

## Steps (iOS IPA)

```
1. Run scope gate
2. Unzip IPA:
   unzip {app.ipa} -d engagements/{id}/evidence/mobile/ipa-out/
3. Locate binary:
   find ipa-out/ -name "*.app" -type d
4. Info.plist analysis:
   strings ipa-out/{App}.app/Info.plist | grep -i "key\|secret\|url\|allow"
   Check: NSAllowsArbitraryLoads (ATS disabled → cleartext traffic)
          NSExceptionDomains (ATS exceptions)
5. Strings extraction:
   strings ipa-out/{App}.app/{BinaryName} | grep -Ei "api|key|secret|token|password|http"
6. Class dump (if class-dump available):
   class-dump -H ipa-out/{App}.app/{Binary} -o evidence/mobile/classdump/
7. Hardcoded secrets: same grep patterns as Android step 6
8. Write report: same format as Android
```

---

## Output

**Writes to**: `engagements/{id}/recon/mobile.md`

```markdown
# Mobile Static Analysis — {app-name}

> Engagement: {engagement-id} | Date: {DATE}
> Platform: {android | ios} | File: {app-path}

## Application Info

- **Package**: {package-name}
- **Version**: {version}
- **Min SDK**: {android only}
- **Target SDK**: {android only}
- **Debuggable**: {yes/no}
- **Backup**: {allowed/disabled}

## Manifest / Info.plist Findings

| Issue | Severity | Detail |
|---|---|---|
| debuggable=true | High | Debug mode enabled in production build |
| allowBackup=true | Low | ADB backup allowed |
| Cleartext traffic | High | Plaintext HTTP permitted |

## Exported Components (Android)

| Component | Type | Permission | Notes |
|---|---|---|---|
| {name} | Activity | none | Accessible to any app |

## Hardcoded Secrets

| File | Line | Type | Value (truncated) |
|---|---|---|---|
| {class}.java | {n} | API Key | AIza...{last 4} |

## Certificate Pinning

- Detected: {yes — okhttp CertificatePinner / network_security_config | no}
- Bypassable: {likely with Frida | unknown — dynamic analysis needed}

## Insecure Data Storage

| Location | Data Type | Severity |
|---|---|---|
| SharedPreferences | auth_token stored plaintext | High |

## Cryptography

| Issue | Location | Severity |
|---|---|---|
| MD5 usage | LoginManager.java:42 | Medium |

## Summary

Confirmed findings: {n}
Recommended dynamic analysis: {yes | no}

---
*Static analysis only — no device interaction*
*Next step: mobile-dynamic-analysis (requires device/emulator)*
```

---

## Error Handling

| Condition | Action |
|---|---|
| apktool not installed | Note: use online decompiler or provide jadx-only analysis. |
| jadx fails on obfuscated code | Note obfuscation detected. Provide strings-level analysis only. |
| IPA binary is encrypted | Note: encrypted binary (App Store DRM). Dynamic analysis required to decrypt. |
| File too large (> 500MB) | Analyse manifest and resources only, skip full source decompile. |
