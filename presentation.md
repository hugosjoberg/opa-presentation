---
theme:
  override:
    footer:
      style: template
      left:
        image: opa.png
      center: '**API Authorization with Open Policy Agent (OPA)**'
      right: "{current_slide} / {total_slides}"
      height: 2
    palette:
      classes:
        noice:
          foreground: red
---

<!-- newlines: 12 -->

<!-- column_layout: [1, 3]-->

<!-- column: 0 -->

![](opa.png)

<!-- column: 1 -->

<!-- newlines: 3 -->

<!-- alignment: center -->
<span style="color: blue">Decoupling Policy</span>

<span style="color: green">API Authorization with Open Policy Agent (OPA)</span>

Hugo Sjöberg

<!-- end_slide -->

Why Policy as Code for APIs?
===
---
<!-- newlines: 1 -->
# The Problem: Hard-Coded Policy
<!-- newlines: 3 -->
### Policy Sprawl
Logic is hard-coded and duplicated across every microservice. (e.g., `if user.role == 'admin'`)
<!-- newlines: 3 -->

### Slow to Change
Simple policy updates (e.g., "add a 'manager' role") require a full re-deploy of the service.
<!-- newlines: 3 -->

### Inconsistent & Opaque
No single way to see "who can do what." It's impossible to audit and hard to maintain.
<!-- newlines: 3 -->
<!-- end_slide -->

What is "Policy as Code"?
===
---
<!-- newlines: 1 -->
# What is "Policy as Code"?
<!-- newlines: 3 -->
Treating your authorization policies just like your application code.
<!-- newlines: 3 -->
*   **Declarative:** Policies are code (`.rego`), not just settings in a UI.
<!-- newlines: 1 -->
*   **Versioned:** Store and manage policies in version control.
<!-- newlines: 1 -->
*   **Auditable:** Use `git blame` to see why a policy was changed.
<!-- newlines: 1 -->
*   **Testable:** Write unit tests for your policies before you deploy them.
<!-- newlines: 1 -->
*   **Automated:** Integrate policy tests and deployment into your CI/CD pipeline.
<!-- end_slide -->

The Solution: Open Policy Agent (OPA)
===
---
<!-- newlines: 3 -->
*   An open-source, general-purpose policy engine.
<!-- newlines: 1 -->
*   A CNCF Graduated project, just like Kubernetes and Prometheus.
<!-- newlines: 1 -->
*   Decouples policy logic from your service's code.
<!-- newlines: 1 -->
*   Your service asks OPA a simple question: "Can user X do Y on resource Z?"
<!-- newlines: 1 -->
*   OPA returns a simple JSON decision (e.g., `{"allow": true}`).

<!-- end_slide -->

Where OPA Fits in API Stacks
===
---
<!-- newlines: 3 -->
# Flexible Deployment
<!-- newlines: 1 -->
OPA is a lightweight binary that can run anywhere. Common patterns include:

*   **API Gateway Plugin:** Enforces policy at the edge (e.g., Kong, Apisix, Envoy).
<!-- newlines: 1 -->
*   **Service Mesh Sidecar:** Enforces policy for east-west traffic (e.g., Istio).
<!-- newlines: 1 -->
*   **Microservice Library:** Called directly from your Go, Python, or Java app.

<!-- end_slide -->

Why OPA?
===
---
<!-- newlines: 8 -->
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
<span style="color: blue">Decoupled & Fast</span>
<!-- alignment: center -->
Policies are compiled and evaluated in-memory. Your service just makes a simple, fast API call to its local OPA instance.

<!-- column: 1 -->
<span style="color: green">Unified & Declarative</span>

Use one language (Rego) to manage policy across your entire cloud-native stack: Kubernetes, APIs, IaC security, CI/CD, Compliance and Regulatory Requirement Enforcement, and more.

<!-- end_slide -->

Writing & Enforcing API Policies
===
---
<!-- newlines: 3 -->
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
# A Crash Course in Rego
Rego is a declarative language, purpose-built for writing policies.
*   `default allow = false` sets a "deny-by-default" stance.
*   `allow { ... }` defines a rule. The rule is `true` if all statements inside are `true`.
*   `input` is the JSON data you send to OPA.
*   `data` is external info (e.g., user roles).
<!-- column: 1 -->
```rego
package api.authz

# By default, deny the request
default allow = false

# Allow if...
allow {
    # ...the request method is GET
    input.method == "GET"
    
    # ...and the path starts with /public/
    startswith(input.path, "/public/")
}

# Also allow if...
allow {
    # ...the user is an admin
    input.user.role == "admin"
}
```
<!-- end_slide -->

Demo - Allow public GET
===
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
```rego
package api.authz

# By default, deny the request
default allow = false

# Allow if...
allow if {
	input.method == "GET"
	...
}

# Allow DELETE requests only for admins
allow if {
	input.method == "DELETE"
	...
}
```
<!-- column: 1 -->
```bash +exec
# REQUEST: GET /public/status (Role: user)
curl -sS -X POST http://localhost:8181/v1/data/api/authz/allow -d '{
  "input": {
    "method": "GET",
    "path": "/public/status",
    "user": {
      "role": "user"
    }
  }
}' -H "Content-Type: application/json" | jq
```

<!-- end_slide -->

Demo - Deny public DELETE
===
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
```rego
package api.authz

# By default, deny the request
default allow = false

# Allow if...
allow if {
	input.method == "GET"
	...
}

# Allow DELETE requests only for admins
allow if {
	input.method == "DELETE"
	...
}
```
<!-- column: 1 -->
```bash +exec
# REQUEST: GET /public/status (Role: user)
curl -sS -X POST http://localhost:8181/v1/data/api/authz/allow -d '{
  "input": {
    "method": "DELETE",
    "path": "/public/status",
    "user": {
      "role": "user"
    }
  }
}' -H "Content-Type: application/json" | jq
```

<!-- end_slide -->

Demo - Allow admin DELETE
===
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
```rego
package api.authz

# By default, deny the request
default allow = false

# Allow if...
allow if {
	input.method == "GET"
	...
}

# Allow DELETE requests only for admins
allow if {
	input.method == "DELETE"
	...
}
```
<!-- column: 1 -->
```bash +exec
# REQUEST: GET /public/status (Role: user)
curl -sS -X POST http://localhost:8181/v1/data/api/authz/allow -d '{
  "input": {
    "method": "DELETE",
    "path": "/public/status",
    "user": {
      "role": "admin"
    }
  }
}' -H "Content-Type: application/json" | jq
```

<!-- end_slide -->
Example: JWT Scope Validation
===
---
<!-- newlines: 3 -->
<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
# JWT crash-course
A JSON Web Token (JWT) is a secure, tamper-proof string which you receive after logging in. The JWT has information encoded which tells you who you are and what you are allowed to do, without the server having to check the database every single time.

## Common API Task: JWTs

A very common API task is ensuring a user has the correct scope in their access token.

Rego has built-in helpers (io.jwt...) to decode and verify tokens, then check their claims.
<!-- column: 1 -->
```rego
package api.jwt

import rego.v1

default allow := false

allow if {
	bearer := input.token
	decoded := io.jwt.decode(bearer)
	payload := decoded[1]

	payload.scope == "admin"
}
```
<!-- end_slide -->

Demo: JWT Scope Validation
===
---

<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
<!-- newlines: 3 -->
- Get input token
<!-- newlines: 1 -->
- Decode input token
<!-- newlines: 1 -->
- Verify that the scope asscoiated with the token is `"admin"`
<!-- column: 1 -->
```rego
package api.jwt

import rego.v1

default allow := false

allow if {
	bearer := input.token
	decoded := io.jwt.decode(bearer)
	payload := decoded[1]

	payload.scope == "admin"
}
```

<!-- end_slide -->

Case 1: Allow (scope: "admin")
===
---

<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
```bash +exec +id:request_admin
# REQUEST: GET /v1/admin
# { "scope": "admin" }
curl -sS -X POST http://localhost:8181/v1/data/api/jwt -d '{
  "input": {
    "path": "/v1/admin/",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6ImFkbWluIn0.CRBAqFSFSEx_x-ZIdZjW6dEVXpabkO5u88wR3xm3gkA"
  }
}' -H "Content-Type: application/json" | jq
```
<!-- column: 1 -->
<!-- snippet_output: request_admin -->

<!-- end_slide -->

Case 2: Deny (scope: "user")
===
---

<!-- column_layout: [1, 1] -->     
<!-- column: 0 -->
```bash +exec +id:request_user
# REQUEST: GET /v1/admin
# { "scope": "user" }
curl -sS -X POST http://localhost:8181/v1/data/api/jwt -d '{
  "input": {
    "path": "/v1/admin/",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6InVzZXIifQ.FgH-m-ie-GSN2JY1aE-E-Kk-m-e-z-k-c-J-y-s-w-Q"
  }
}' -H "Content-Type: application/json" | jq
```
<!-- column: 1 -->
<!-- snippet_output: request_user -->

<!-- end_slide -->

External Data OPA May Need
===
---
<!-- newlines: 3 -->
* User/role/group mappings
<!-- newlines: 1 -->
* Resource metadata (owner)
<!-- newlines: 1 -->
* API keys and their permissions
<!-- newlines: 1 -->
* Subscription tier or business rules
<!-- newlines: 1 -->
* Kubernetes labels / environment context
<!-- newlines: 1 -->
* etc.

<!-- end_slide -->
Keeping OPA in Sync with External Data
===
---
<!-- newlines: 6 -->
# Bundle
When your external authorization data (like user roles or resource attributes) changes infrequently, the best approach is using OPA's Bundle feature. This mechanism allows OPA to periodically download a gzipped bundle from a central server(S3). This bundle contains both your policies (Rego) and the necessary data.
<!-- newlines: 2 -->
# Push
Instead of waiting for OPA to pull a full bundle, you can build a dedicated replicator service that pushes external data directly into OPA using its REST API.

<!-- end_slide -->

Closing: The State of OPA
===
---
<!-- newlines: 6 -->
* Graduated & Stable: A top-level CNCF project, battle-tested and ready for production.
<!-- newlines: 1 -->
* Wide Adoption: Used by companies such as Netflix, Pinterest, etc.
<!-- newlines: 1 -->
* Active Community: A large, growing community with strong vendor support.
<!-- newlines: 1 -->
* Apple "acquired" Styra the company behind OPA
    * This confirms the technology's value!
    * OPA itself remains a CNCF-governed, open-source project.

<!-- end_slide -->

Questions?
===
---
<!-- alignment: center -->
<!-- newlines: 6 -->
<!-- column_layout: [1, 3]-->
<!-- column: 0 -->
![](opa.png)
<!-- column: 1 -->
<!-- newlines: 4 -->
Thank you!

Slides: https://github.com/hugosjoberg/opa-presentation
