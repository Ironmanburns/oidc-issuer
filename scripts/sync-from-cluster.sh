#!/usr/bin/env bash
set -euo pipefail
ISSUER="${OIDC_ISSUER:-https://ironmanburns.github.io/oidc-issuer}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
export PATH="/run/wrappers/bin:/home/jason/.nix-profile/bin:/run/current-system/sw/bin:$PATH"

echo "Fetching JWKS from cluster..."
JWKS=$(kubectl get --raw /openid/v1/jwks)
echo "$JWKS" | jq -e '.keys | length > 0' >/dev/null

mkdir -p "$ROOT/.well-known" "$ROOT/openid/v1"
cat > "$ROOT/.well-known/openid-configuration" <<JSON
{
  "issuer": "$ISSUER",
  "jwks_uri": "$ISSUER/openid/v1/jwks",
  "response_types_supported": ["id_token"],
  "subject_types_supported": ["public"],
  "id_token_signing_alg_values_supported": ["RS256"]
}
JSON
echo "$JWKS" | jq '.' > "$ROOT/openid/v1/jwks"
echo "Wrote discovery + JWKS to $ROOT"
