#!/bin/bash
# Start callback server in background
python3 /opt/callback/callback_server.py &
# Exec the original hermes entrypoint
exec hermes "$@"
