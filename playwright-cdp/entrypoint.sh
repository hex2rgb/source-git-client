#!/bin/sh
set -eu

exec /ms-playwright/chromium-*/chrome-linux64/chrome \
  --headless \
  --no-sandbox \
  --remote-debugging-address=0.0.0.0 \
  --remote-debugging-port=9222 \
  --user-data-dir=/data/profile
