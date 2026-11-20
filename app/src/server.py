"""
Application minimale — Groupe Leman Finance SA
Port 8080 — Sprint 2
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json


class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/health":
            self._respond(200, {"status": "ok", "service": "leman-portail"})
        elif self.path == "/":
            self._respond_html(200, self._index_html())
        else:
            self._respond(404, {"error": "not found"})

    def _respond(self, code, body):
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def _respond_html(self, code, html):
        payload = html.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("X-Frame-Options", "DENY")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        self.wfile.write(payload)

    def _index_html(self):
        return """<!DOCTYPE html>
<html lang="fr">
<head><meta charset="utf-8"><title>Leman Finance SA</title></head>
<body>
  <h1>Portail Groupe Leman Finance SA</h1>
  <p>Service operationnel.</p>
  <a href="/health">Health check</a>
</body>
</html>"""

    def log_message(self, fmt, *args):
        pass


def run(host="0.0.0.0", port=8080):
    server = HTTPServer((host, port), Handler)
    print(f"Serveur demarre sur {host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    run()
