package api.authz

import rego.v1

default allow := false

# Allow rule for authenticated users accessing READ operations.
allow if {
	input.method == "GET"
	input.path == "/public/status"
	input.user.role == "user"
}

# Allow DELETE requests only for admins
allow if {
	input.method == "DELETE"
	input.user.role == "admin"
}
