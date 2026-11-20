"""
Tests unitaires — server.py
Couverture cible : >= 80 % (ADR-005)
"""
import io
import sys
import os
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))
from server import Handler


class MockRequest:
    def makefile(self, *args, **kwargs):
        return io.BytesIO(b"")


class MockServer:
    def __init__(self):
        self.server_address = ("127.0.0.1", 8080)


def make_handler(path):
    raw = f"GET {path} HTTP/1.1\r\nHost: localhost\r\n\r\n".encode()
    output = io.BytesIO()
    handler = Handler.__new__(Handler)
    handler.rfile = io.BytesIO(raw)
    handler.wfile = output
    handler.server = MockServer()
    handler.client_address = ("127.0.0.1", 12345)
    handler.request = MockRequest()
    handler.path = path
    handler.command = "GET"
    handler.request_version = "HTTP/1.1"
    handler.headers = {}
    return handler, output


class TestHealth(unittest.TestCase):
    def test_200(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("200", o.getvalue().decode())

    def test_json(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("application/json", o.getvalue().decode())

    def test_status_ok(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn('"status": "ok"', o.getvalue().decode())


class TestIndex(unittest.TestCase):
    def test_200(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("200", o.getvalue().decode())

    def test_html(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("text/html", o.getvalue().decode())

    def test_title(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("Leman Finance SA", o.getvalue().decode())


class TestNotFound(unittest.TestCase):
    def test_404(self):
        h, o = make_handler("/inexistant")
        h.do_GET()
        self.assertIn("404", o.getvalue().decode())


class TestSecurityHeaders(unittest.TestCase):
    def test_xframe(self):
        h, o = make_handler("/health")
        h.do_GET()
        self.assertIn("X-Frame-Options", o.getvalue().decode())

    def test_xcontent(self):
        h, o = make_handler("/")
        h.do_GET()
        self.assertIn("X-Content-Type-Options", o.getvalue().decode())


if __name__ == "__main__":
    unittest.main()
