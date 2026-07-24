#!/usr/bin/env python3
"""
Callback server — catches OAuth redirects and other webhooks.
Listens on port 9121. Saves callback data to /opt/data/callbacks/.
"""
import json
import os
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path

CALLBACK_DIR = Path("/opt/data/callbacks")
CALLBACK_DIR.mkdir(parents=True, exist_ok=True)

HTML_PAGE = """<!DOCTYPE html>
<html>
<head><title>Callback Received</title>
<style>
  body { font-family: -apple-system, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #111; color: #eee; }
  .box { text-align: center; padding: 40px; border-radius: 12px; background: #1a1a1a; }
  h1 { color: #4ade80; }
  p { color: #888; }
</style>
</head>
<body>
<div class="box">
  <h1>✓ Success</h1>
  <p>Callback received. You can close this window.</p>
</div>
</body>
</html>"""


class CallbackHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)

        # ── Google OAuth callback ──────────────────────────────────
        if parsed.path == "/oauth/google":
            code = params.get("code", [None])[0]
            state = params.get("state", [None])[0]
            scope = params.get("scope", [None])[0]

            if code:
                data = {
                    "code": code,
                    "state": state,
                    "scope": scope.split() if scope else [],
                    "timestamp": self.date_time_string(),
                }
                (CALLBACK_DIR / "google-oauth.json").write_text(json.dumps(data, indent=2))
                print(f"[oauth/google] Saved code (state={state})")
                self._respond(200, HTML_PAGE)
            else:
                error = params.get("error", ["unknown"])[0]
                print(f"[oauth/google] Error: {error}")
                (CALLBACK_DIR / "google-oauth-error.json").write_text(
                    json.dumps({"error": error, "timestamp": self.date_time_string()}, indent=2)
                )
                self._respond(400, f"Error: {error}")

        # ── Health check ───────────────────────────────────────────
        elif parsed.path == "/health":
            self._respond(200, "ok")

        # ── 404 ────────────────────────────────────────────────────
        else:
            self._respond(404, "not found")

    def _respond(self, code, body):
        self.send_response(code)
        self.send_header("Content-Type", "text/html" if code == 200 else "text/plain")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(body.encode())

    def log_message(self, format, *args):
        print(f"[callback-server] {args[0]}")


if __name__ == "__main__":
    port = int(os.environ.get("CALLBACK_PORT", "9121"))
    print(f"[callback-server] Listening on :{port}")
    HTTPServer(("0.0.0.0", port), CallbackHandler).serve_forever()
