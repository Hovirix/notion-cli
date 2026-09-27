#!/usr/bin/env python3

import argparse
import base64
import hashlib
import os
import re
import tempfile
from pathlib import Path
from urllib.request import Request, urlopen

BASE_URL = os.environ.get("NTN_BASE_URL", "https://ntn.dev")
PACKAGE_FILE = Path(__file__).parent / "package.nix"
TARGETS = (
    "x86_64-unknown-linux-musl",
    "aarch64-unknown-linux-musl",
    "x86_64-apple-darwin",
    "aarch64-apple-darwin",
)


def download(url: str) -> bytes:
    request = Request(url, headers={"User-Agent": "ntn-nix-update"})
    with urlopen(request) as response:
        return response.read()


def sri_hash(contents: bytes) -> str:
    digest = hashlib.sha256(contents).digest()
    return f"sha256-{base64.b64encode(digest).decode()}"


def release_version() -> str:
    version = download(f"{BASE_URL}/latest.txt").decode().strip()
    match = re.fullmatch(r"v?(\d+\.\d+\.\d+)", version)
    if match is None:
        raise ValueError(f"invalid release version: {version}")
    return match.group(1)


def release_hashes(version: str) -> dict[str, str]:
    hashes = {}
    for target in TARGETS:
        archive = f"ntn-{target}.tar.gz"
        url = f"{BASE_URL}/releases/v{version}/{archive}"
        contents = download(url)
        checksum = download(f"{url}.sha256").decode().strip().split()
        if len(checksum) != 2 or checksum[1].lstrip("*") != archive:
            raise ValueError(f"invalid checksum file for {archive}")
        if hashlib.sha256(contents).hexdigest() != checksum[0]:
            raise ValueError(f"checksum mismatch for {archive}")
        hashes[target] = sri_hash(contents)
    return hashes


def replace_once(contents: str, pattern: str, replacement: str) -> str:
    contents, replacements = re.subn(pattern, replacement, contents)
    if replacements != 1:
        raise ValueError(f"expected one replacement for {pattern!r}, got {replacements}")
    return contents


def update_package(version: str, hashes: dict[str, str]) -> str:
    contents = PACKAGE_FILE.read_text()
    contents = replace_once(
        contents,
        r'version = "[^"]+";',
        f'version = "{version}";',
    )
    for target, hash_ in hashes.items():
        contents = replace_once(
            contents,
            rf'(target = "{re.escape(target)}";\n\s+hash = ")[^"]+(";)',
            rf'\g<1>{hash_}\g<2>',
        )
    return contents


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    version = release_version()
    contents = update_package(version, release_hashes(version))

    if args.dry_run:
        return

    with tempfile.NamedTemporaryFile("w", dir=PACKAGE_FILE.parent, delete=False) as file:
        file.write(contents)
        temporary_path = Path(file.name)
    temporary_path.replace(PACKAGE_FILE)


if __name__ == "__main__":
    main()
