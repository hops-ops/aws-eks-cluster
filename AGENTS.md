# Repository Guidelines

This Crossplane configuration targets Crossplane v2 conventions: namespaced XRDs, `.m.` managed resources, `managementPolicies`, and no `deletionPolicy`.

Avoid Upbound-hosted configuration packages because they have paid-account restrictions. Favor `crossplane-contrib` packages and provider-family packages already used by Hops.

Use the xrd-authoring skill when working on this package.
