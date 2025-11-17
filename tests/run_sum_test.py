#!/usr/bin/env python3
"""Basic stdin-driven regression test for the Apple Silicon sum program."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print(f"Usage: {Path(sys.argv[0]).name} /path/to/sum_binary", file=sys.stderr)
        return 2

    exe = Path(sys.argv[1])
    if not exe.is_file():
        print(f"error: executable '{exe}' was not found", file=sys.stderr)
        return 2

    # Feed two integers via stdin and capture the prompts/result.
    proc = subprocess.run(
        [str(exe)],
        input="10\n-4\n".encode("utf-8"),
        capture_output=True,
        check=True,
    )

    output = proc.stdout.decode("utf-8", errors="replace").strip()
    expected_fragment = "Sum: 6"
    if expected_fragment not in output:
        print("Program output did not contain expected sum.\n" f"Output was:\n{output}", file=sys.stderr)
        return 1

    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
