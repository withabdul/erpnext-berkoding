#!/usr/bin/env bash
set -Eeuo pipefail

SITE_NAME="${1:-${FRAPPE_SITE_NAME_HEADER:-site.localhost}}"

docker compose exec -T backend bench --site "$SITE_NAME" migrate
docker compose exec -T backend bench --site "$SITE_NAME" clear-cache
