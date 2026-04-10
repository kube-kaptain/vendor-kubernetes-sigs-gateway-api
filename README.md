# Vendor Kubernetes Sigs Gateway API

Pre packaged [Kubernetes Gateway API](https://github.com/kubernetes-sigs/gateway-api)
CRD manifests for use in Kaptain deployments.


## Contents

Individual CRD manifests split from the upstream `standard-install.yaml` release
asset, committed to `src/kubernetes/` with consistent naming in the form of:
`<kind-lowercased>-<resource-short-name>.yaml` where short name is the `metadata.name`
prefix before the following: `.gateway.networking.k8s.io`.


## Versioning

Version tracks upstream Gateway API releases with an additional patch part for
packaging iterations. For example, `1.5.1.1` is the first packaging of upstream
`v1.5.1`, `1.5.1.2` would be a packaging improvement without an upstream change.

The upstream version is stored in `src/config/gateway-api-version` and can be
listed with `kaptain list config` if you have the kaptain user scripts available.


## Scripts

**`.github/bin/update-gateway-api.bash`** - Downloads `standard-install.yaml`
for the version in `src/gateway-api/version`, splits it into individual
manifests in `src/kubernetes/`. Also runs in CI as a pre-tagging hook to
validate that generated files match what the branch/commits contain.

**`src/bin/bump-gateway-api.bash`** - Finds the next stable upstream release,
updates `src/gateway-api/version`, and runs the update script to fetch the new
manifests.


## Upstream

- Repository: [kubernetes-sigs/gateway-api](https://github.com/kubernetes-sigs/gateway-api)
- Supported version range: 1.0.0 to at least 1.5.1 (earlier versions totally different)
- Channel: standard (GA and Beta APIs only)
