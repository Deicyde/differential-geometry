#!/usr/bin/env python3
"""Run official Comparator and record its verdict and unchanged-input evidence."""

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys


def positive_int(value):
    try:
        result = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError("must be a positive integer") from None
    if result < 1:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return result


def main():
    root = Path(__file__).resolve().parent.parent
    toolchain = (root / "lean-toolchain").read_text().strip()
    version = toolchain.split(":")[-1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tools", type=Path,
                        default=root / ".lake/comparator-tools" / version)
    parser.add_argument("--stream", action="store_true", help="Also print the log for CI")
    parser.add_argument("--fail-fast", action="store_true",
                        help="Stop this run on a reported build error, preserving completed artifacts")
    parser.add_argument("--threads", type=positive_int, default=2,
                        help="Lean worker threads (default: 2)")
    args = parser.parse_args()
    tools = args.tools.resolve()
    comparator = tools / ".lake/build/bin/comparator"
    exporter = tools / ".lake/packages/lean4export/.lake/build/bin/lean4export"
    launcher = os.environ.get("COMPARATOR_LANDRUN")
    if launcher is None:
        launcher = (str(tools / "scripts/fake-landrun.sh") if sys.platform == "darwin"
                    else shutil.which("landrun"))
    elif not Path(launcher).is_file():
        launcher = shutil.which(launcher)
    lake = shutil.which("lake")
    if not lake or not launcher:
        parser.error("lake and a Comparator launcher must be available")
    for path in (comparator, exporter, Path(launcher)):
        if not path.is_file():
            parser.error(f"Required executable missing: {path}")
    for name in ("Challenge.lean", "Solution.lean", "comparator.json"):
        if not (root / name).is_file():
            parser.error(f"Required project input missing: {name}")

    def hashes():
        paths = sorted(set(root.glob("*.lean")) |
                       set((root / "DifferentialGeometry").rglob("*.lean")) |
                       set((root / "ComparatorSupport").rglob("*.lean")) |
                       {root / name for name in (
                           "comparator.json", "lakefile.toml", "lake-manifest.json",
                           "lean-toolchain")})
        return {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
                for path in paths}

    def revision(directory):
        return subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=directory, text=True).strip()

    started = datetime.now(timezone.utc)
    output = root / ".lake/comparator" / started.strftime("%Y-%m-%dT%H%M%S.%fZ")
    output.mkdir(parents=True, exist_ok=False)
    command = [lake, "env", str(comparator), "comparator.json"]
    env = os.environ.copy()
    env.update(LC_ALL="C", LEAN_NUM_THREADS=str(args.threads), ELAN_TOOLCHAIN=toolchain,
               COMPARATOR_LANDRUN=launcher, COMPARATOR_LEAN4EXPORT=str(exporter))
    metadata = {
        "started_at": started.isoformat(), "toolchain": toolchain,
        "comparator_revision": revision(tools),
        "lean4export_revision": revision(tools / ".lake/packages/lean4export"),
        "project_revision": revision(root), "lean_num_threads": args.threads,
        "logical_cpu_count": os.cpu_count(),
        "heartbeat_override": False, "status": "starting",
        "platform": sys.platform,
        "launcher": ("official development launcher; no OS sandbox isolation"
                     if Path(launcher).name == "fake-landrun.sh" else launcher),
        "input_sha256": hashes(), "wrapper_pid": os.getpid(),
    }

    def save():
        temporary = output / "metadata.json.tmp"
        temporary.write_text(json.dumps(metadata, indent=2) + "\n")
        temporary.replace(output / "metadata.json")

    save()
    (root / ".lake/comparator/latest-run.txt").write_text(str(output) + "\n")
    print(f"Comparator evidence: {output}", flush=True)
    print(f"Logical CPUs detected: {metadata['logical_cpu_count']}; "
          f"Lean worker threads: {args.threads}", flush=True)
    with (output / "run.log").open("w") as log:
        capture = args.stream or args.fail_fast
        process = subprocess.Popen(command, cwd=root, env=env,
                                   stdout=subprocess.PIPE if capture else log,
                                   stderr=subprocess.STDOUT, text=True, start_new_session=True)
        metadata.update(pid=process.pid, status="running")
        save()
        if capture:
            for line in process.stdout:
                log.write(line)
                log.flush()
                if args.stream:
                    print(line, end="", flush=True)
                plain = re.sub(r"\x1b\[[0-9;]*m", "", line).lstrip()
                if (args.fail_fast and "stopped_on_build_error" not in metadata
                        and (plain.startswith("error:") or plain.startswith("✖ "))):
                    metadata["stopped_on_build_error"] = plain.strip()
                    save()
                    try:
                        os.killpg(process.pid, signal.SIGTERM)
                    except ProcessLookupError:
                        pass
        metadata["return_code"] = process.wait()
    metadata["finished_at"] = datetime.now(timezone.utc).isoformat()
    metadata["final_input_sha256"] = hashes()
    metadata["inputs_unchanged"] = metadata["input_sha256"] == metadata["final_input_sha256"]
    log_text = (output / "run.log").read_text(errors="replace")
    metadata["success_marker_found"] = "Your solution is okay!" in log_text
    metadata["kernel_acceptance_found"] = "Lean default kernel accepts the solution" in log_text
    passed = (metadata["return_code"] == 0 and metadata["inputs_unchanged"]
              and metadata["success_marker_found"] and metadata["kernel_acceptance_found"])
    metadata["status"] = "passed" if passed else "completed_without_pass"
    save()
    print(f"Comparator: {metadata['status']}; log: {output / 'run.log'}", flush=True)
    return 0 if passed else max(1, metadata["return_code"])


if __name__ == "__main__":
    sys.exit(main())
