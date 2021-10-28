#!/bin/bash
set -eo pipefail
mkdir -p nodejs
rm -rf node_modules nodejs/node_modules
npm install --production
mv node_modules nodejs/