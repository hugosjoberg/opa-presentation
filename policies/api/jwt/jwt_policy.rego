package api.jwt

import rego.v1

default allow := false

allow if {
	bearer := input.token
	decoded := io.jwt.decode(bearer)
	payload := decoded[1]

	payload.scope == "admin"
}
