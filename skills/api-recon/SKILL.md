---
name: api-recon
description: >
  API reconnaissance: endpoint discovery, authentication mechanism analysis,
  OpenAPI/Swagger/GraphQL schema collection, HTTP method testing, and
  API versioning enumeration. Maps the full API attack surface before exploitation.
  Use when: starting API testing, discovering endpoints from documentation or JS files,
  or mapping authentication and authorization boundaries.
license: MIT
compatibility: opencode
metadata:
  owner: api-pentester
  type: read-only
  approval: "No — but active probing requires scope confirmation"
---

# api-recon

**Owner**: `api-pentester`
**Type**: `read-only` (active probing — scope gate required)
**Approval**: `No`
**Workflow**: `.crux/workflows/pentest-engagement.md` — Step 2 (api)

---

## What I Do

Discovers API endpoints, collects documentation, analyses authentication mechanisms,
and maps the API attack surface. Produces `engagements/{id}/recon/api.md`.

---

## Scope Gate

```
1. Load engagements/{id}/scope.md — verify API base URL in scope
2. Load authorization.md — verify expiry >= TODAY
3. IF either fails → STOP, notify red-team-lead
```

---

## Inputs

| Input | Source | Required |
|---|---|---|
| engagement-id | MEMORY.md | Yes |
| api-base-url | scope.md or user | Yes |
| api-spec-path | user | No — OpenAPI/Swagger/Postman collection |
| auth-token | user | No — authenticated discovery |
| graphql | MEMORY.md or user | No — default: auto-detect |

---

## Steps

```
1. Run scope gate

2. Collect API documentation
   Try these paths on api-base-url:
     /swagger.json
     /swagger.yaml
     /openapi.json
     /openapi.yaml
     /api-docs
     /api-docs/v1
     /api-docs/v2
     /v1/docs
     /v2/docs
     /docs
     /redoc
     /graphql        (GraphQL endpoint detection)
     /graphiql
     /__graphql
     /api/graphql
   For each 200 response: download and save to evidence/api/spec-{path}.json

3. Parse API spec (if found)
   Extract: all endpoints, HTTP methods, parameters, auth schemes, response schemas
   Save endpoint list to: evidence/api/endpoints.txt
   Count: {n} endpoints discovered

4. GraphQL introspection (if GraphQL detected or graphql: true)
   Query:
     curl -s -X POST {graphql-url} \
       -H "Content-Type: application/json" \
       -d '{"query":"{__schema{types{name,fields{name,type{name}}}}}"}'
   IF introspection enabled (200 with schema data):
     Save schema to: evidence/api/graphql-schema.json
     Extract: all types, queries, mutations, subscriptions
     FINDING candidate: GraphQL introspection enabled (Informational → Medium depending on data)
   ELSE:
     Note: introspection disabled (expected in production)

5. HTTP method testing (per endpoint — sample first 5)
   For each endpoint: try OPTIONS to get allowed methods
     curl -s -X OPTIONS {endpoint} -v 2>&1 | grep -i "allow:"
   Test unexpected methods: TRACE, CONNECT, PATCH on read-only endpoints
   FINDING candidate: TRACE enabled → XST (Low)

6. Authentication mechanism analysis
   From spec and live responses, identify:
     Bearer JWT → extract and decode: jwt_tool {token} --decode (or base64)
       Note: alg, exp, sub, custom claims, issuer
     API Key → where sent: header, query param, or body?
     Basic Auth → note (weak)
     OAuth2 → flows: authorization_code, client_credentials, implicit?
   Test: access endpoint without auth token
     FINDING candidate: unauthenticated access → Critical if data returned

7. API versioning
   Try older API versions:
     /v0/, /v1/, /v2/, /api/v0/, /api/v1/
     If v1 is current, test v0 for deprecated endpoints still active
   FINDING candidate: old API version active with different security posture → Medium-High

8. Endpoint fuzzing (if ffuf/katana available and scan-profile != light)
   ffuf -u {api-base-url}/FUZZ \
        -w /usr/share/wordlists/api-wordlist.txt \
        -mc 200,201,401,403 \
        -t 10 -rate 20 \
        -H "Content-Type: application/json"
   Common API wordlists: /usr/share/seclists/Discovery/Web-Content/api/

9. Write recon output
   engagements/{id}/recon/api.md

10. Notify
    "API recon complete.
     Endpoints: {n} | Auth: {type} | GraphQL: {yes/no}
     Spec: {found at {path} | not found}
     Report: engagements/{id}/recon/api.md"
```

---

## Output

**Writes to**: `engagements/{id}/recon/api.md`

```markdown
# API Recon — {api-base-url}

> Engagement: {engagement-id} | Date: {DATE}

## API Specification

| Source | Path | Status |
|---|---|---|
| OpenAPI | /openapi.json | Found — {n} endpoints |
| Swagger | /swagger.json | Not found |
| GraphQL | /graphql | {Found — introspection {on/off} | Not found} |

## Endpoints ({n} total)

| Method | Endpoint | Auth | Notes |
|---|---|---|---|
| GET | /api/v1/users | Bearer | Returns user list |
| POST | /api/v1/users/login | None | Auth endpoint |
| GET | /api/v1/users/{id} | Bearer | BOLA candidate |
| DELETE | /api/v1/users/{id} | Bearer | Destructive — test carefully |

## Authentication

- **Type**: {bearer | api-key | basic | oauth2 | none}
- **JWT Claims**: {sub, exp, role, ...} if applicable
- **Token location**: {Authorization header | query param | cookie}

## GraphQL

{Disabled | Enabled — schema at evidence/api/graphql-schema.json}
{If enabled: list of queries and mutations}

## Unauthenticated Access Tests

| Endpoint | Without Auth | Finding |
|---|---|---|
| GET /api/v1/users | 200 — data returned | CRITICAL: no auth required |
| GET /api/v1/profile | 401 | OK |

## Old API Versions

| Version | Active | Notes |
|---|---|---|
| v0 | {yes/no} | {endpoints active} |
| v1 | yes (current) | — |

## Attack Surface Summary

BOLA candidates:    {n} (endpoints with {id} parameter)
Auth bypass points: {n}
Unauthenticated:    {n}
Mutations (POST/PUT/DELETE): {n}
GraphQL mutations:  {n | N/A}

---
*Next step: api-exploit skill for BOLA, auth, and injection testing*
```

---

## Error Handling

| Condition | Action |
|---|---|
| API spec not found | Note: no documentation available. Rely on JS analysis and fuzzing. |
| All endpoints return 401 | Note: authentication required for all testing. Confirm credentials with user. |
| GraphQL introspection returns partial schema | Save partial schema, note limitation. |
| Rate limiting detected | Reduce request rate, add delays. Note in recon output. |
