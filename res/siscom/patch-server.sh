#!/usr/bin/env bash
# Bakes the Siscom server and key into libs/hbb_common (a submodule shared with
# upstream), so the build needs no fork of hbb_common. Run after checkout.
set -euo pipefail
SERVER="${SISCOM_SERVER:-rdp.sismanager.cloud}"
KEY="${SISCOM_KEY:-o6gWRlgufIlaPSeJDJdB7lDjeEE6EK9DooZaVzNGZO8=}"
CONFIG="$(dirname "$0")/../../libs/hbb_common/src/config.rs"
sed -i.bak \
  -e "s|^pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[.*\];|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&[\"${SERVER}\"];|" \
  -e "s|^pub const RS_PUB_KEY: &str = \".*\";|pub const RS_PUB_KEY: \&str = \"${KEY}\";|" \
  "$CONFIG"
rm -f "$CONFIG.bak"
grep -q "\"${SERVER}\"" "$CONFIG" && grep -q "\"${KEY}\"" "$CONFIG" || { echo "patch-server: config.rs not patched" >&2; exit 1; }
echo "patch-server: ${SERVER} / ${KEY}"
