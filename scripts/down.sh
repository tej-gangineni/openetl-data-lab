#!/usr/bin/env bash
# Stop and remove the containers. Add -v to also delete the stored data.
cd "$(dirname "$0")/.." && docker compose down "$@"
