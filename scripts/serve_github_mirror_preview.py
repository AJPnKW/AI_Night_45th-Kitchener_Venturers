"""
serve_github_mirror_preview.py
Version: 1.0.0
Purpose: Serve the github/ mirror locally under a /AI_Night_1st-Stanley-Park_Venture-Company/ URL prefix so preview URLs match GitHub Pages path structure.
"""

from __future__ import annotations

import argparse
import functools
import http.server
from pathlib import Path
from urllib.parse import urlsplit


REPO_ROOT = Path(__file__).resolve().parent.parent
SITE_ROOT = REPO_ROOT / "github"
PREFIX = "/AI_Night_1st-Stanley-Park_Venture-Company"


class PrefixedHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path in {"/", ""}:
            self.send_response(302)
            self.send_header("Location", f"{PREFIX}/")
            self.end_headers()
            return
        super().do_GET()

    def translate_path(self, path: str) -> str:
        raw_path = urlsplit(path).path
        if raw_path.startswith(PREFIX):
            raw_path = raw_path[len(PREFIX) :]
        if not raw_path.startswith("/"):
            raw_path = "/" + raw_path
        return super().translate_path(raw_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=8018)
    args = parser.parse_args()

    handler = functools.partial(PrefixedHandler, directory=str(SITE_ROOT))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), handler)
    print(f"Serving {SITE_ROOT} at http://127.0.0.1:{args.port}{PREFIX}/")
    server.serve_forever()


if __name__ == "__main__":
    main()


