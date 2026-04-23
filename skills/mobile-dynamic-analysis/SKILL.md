---
name: mobile-dynamic-analysis
description: >
  Dynamic analysis of Android or iOS applications: Frida instrumentation,
  SSL pinning bypass, runtime method hooking, traffic interception, local storage
  inspection on device, and sensitive data in memory/logs.
  Requires a connected device or emulator.
  Use when: device available, SSL pinning bypass needed, runtime behaviour analysis,
  or confirming static analysis findings at runtime.
license: MIT
compatibility: opencode
metadata:
  owner: mobile-pentester
  type: read-write
  approval: "Yes — device interaction and hooking require approval"
---

# mobile-dynamic-analysis

**Owner**: `mobile-pentester`
**Type**: `read-write` (device interaction)
**Approval**: `Yes`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 3 (mobile)

---

## What I Do

Instruments the running application using Frida/objection, intercepts network traffic,
inspects local storage at runtime, and hooks sensitive methods to observe behaviour.
Confirms or extends findings from static analysis.

---

## Scope Gate

```
1. Load scope.md — verify app in scope
2. Load authorization.md — verify expiry >= TODAY
3. Verify device: adb devices (Android) or ideviceinfo (iOS)
4. IF scope fails → STOP
5. IF no device → notify: "Dynamic analysis requires a connected device/emulator."
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| app-path | MEMORY.md → app-path | Yes |
| package-name | MEMORY.md or user | Yes |
| platform | MEMORY.md | Yes |
| frida-server-ready | MEMORY.md | Yes for Frida hooks |

---

## Steps (Android)

```
1. Run scope gate + device check

2. Install app on device/emulator (if not already installed)
   adb install {app-path}
   Show:
     "Installing {app-path} on connected device.
      Proceed? (yes / no)"
   adb shell pm list packages | grep {package-name}

3. Launch app and capture logcat
   adb logcat -c  (clear log)
   adb shell am start -n {package-name}/{main-activity}
   adb logcat {package-name} > evidence/mobile/logcat.txt &
   Monitor for: passwords, tokens, PII in logs

4. Local storage inspection
   (requires root or backup-enabled)
   adb shell run-as {package-name} ls /data/data/{package-name}/
   adb shell run-as {package-name} ls shared_prefs/
   adb shell run-as {package-name} cat shared_prefs/{name}.xml
   adb shell run-as {package-name} ls databases/
   Copy DB: adb shell run-as {package-name} cat databases/{db} > evidence/mobile/local.db
   Open: sqlite3 evidence/mobile/local.db ".tables"
   FINDING: tokens, passwords, PII in plaintext local storage → High

5. SSL Pinning bypass (if pinning detected in static analysis)
   REQUIRE APPROVAL:
     "Attempting SSL pinning bypass using Frida/objection.
      This will inject into the running process: {package-name}
      Proceed? (yes / no)"

   IF objection available:
     objection -g {package-name} explore
     android sslpinning disable

   ELSE IF frida available:
     Download: frida-codeshare universal-android-ssl-pinning-bypass
     frida -U -f {package-name} \
           --codeshare pcipolloni/universal-android-ssl-pinning-bypass-with-frida \
           --no-pause

   Verify bypass: start mitmproxy/Burp, route device traffic through proxy
     adb shell settings put global http_proxy {proxy-ip}:8080
     Observe traffic in proxy
   FINDING: SSL pinning absent or bypassable → Medium-High

6. Traffic interception (after pinning bypass or if no pinning)
   Configure proxy:
     adb shell settings put global http_proxy {proxy-ip}:8080
   Install mitmproxy/Burp CA cert:
     adb push {cert.cer} /sdcard/
     adb shell am start -n com.android.certinstaller/.CertInstallerActivity \
       --ei android.intent.extra.CERTIFICATE 0
   Intercept app traffic for 5 minutes of normal app use
   Look for:
     HTTP (not HTTPS) requests → FINDING: cleartext transmission (High)
     Sensitive data in request bodies/headers
     Authorization tokens transmitted insecurely
   Save: pcap or proxy history to evidence/mobile/traffic-capture.har

7. Frida method hooking (for specific static findings)
   REQUIRE APPROVAL for each hook script.
   Examples:
     Hook crypto: intercept AES/DES decrypt calls to see plaintext
     Hook SharedPreferences: observe all values read/written
     Hook LoginManager: intercept credentials before they are hashed
   Frida script:
     frida -U -p {pid} -l {script.js}
   Save scripts to: evidence/mobile/frida-scripts/

8. Sensitive data in memory (optional — if critical secrets suspected)
   REQUIRE APPROVAL:
     "Dumping process memory to search for credentials.
      This is intrusive and generates a large file.
      Proceed? (yes / no)"
   frida-ps -U | grep {package}
   Use Memory.scan or Frida to search memory for pattern

9. Cleanup
   adb shell settings delete global http_proxy
   adb shell pm uninstall {package-name}  (if test device, not personal)

10. Write findings
    Update: engagements/{id}/recon/mobile.md (dynamic section)
    For each confirmed finding: pass to finding-document
```

---

## Error Handling

| Condition | Action |
|---|---|
| No device connected | Stop. Notify: "adb devices shows no device. Connect device or start emulator." |
| App crashes on install | Note compatibility issue. Document. May indicate anti-tampering. |
| Frida not found | Suggest: pip install frida-tools. Note dynamic analysis limited. |
| SSL pinning bypass fails | Note: strong pinning implemented. Recommend grey-box approach or source review. |
| Root not available | Skip local storage inspection. Note in report as untested. |
