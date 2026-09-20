# Hamilton Comparator pair

`Challenge.lean` imports only Mathlib and states the theorem under
`HamiltonPointwise.hamilton_positive_ricci`. Its single target proof hole is
intentional. `Solution.lean` imports the repository's original Hamilton proof
and transfers it through `HamiltonBridge.lean` to the same statement.

**The full Comparator check passed.** [Run 35475666721](https://github.com/Deicyde/differential-geometry/actions/runs/35475666721)
validated commit `c282651d95a6c07d7c531c68e6835e9f2128a4b1`, finishing on
September 20, 2026 UTC. The original Hamilton theorem and `Solution.lean` compiled,
and Comparator reported both “Lean default kernel accepts the solution” and
“Your solution is okay!” with exit code 0. All 3,944 recorded Lean/configuration
files matched the checked sources. See [comparator-pass.json](comparator-pass.json)
and its linked complete log, metadata, and source-hash verification.

The geometric bridge also passed its normal build, full live Lean check, and
separate axiom audits; see `full-bridge-validation.json`.

`comparator.json` permits only `propext`, `Quot.sound`, and `Classical.choice`.
It has no exempt definitions. `enable_nanoda: false` selects the builtin Lean
kernel replay; it does not disable kernel checking.

## Reproduce the check

The tools used for this version are the unmodified official `v4.34.0-rc2` releases:

- Comparator: `19e111e2141cf333c7daff0f64c5f24acc91dd2e`.
- lean4export: `cacf989bd75f608700820f6afc595f32e7a99a4d`.

For a fresh checkout, fetch the pinned Mathlib cache from the repository root:

```sh
lake exe cache get
```

Then prepare the tools once:

```sh
git clone --depth 1 --branch v4.34.0-rc2 https://github.com/leanprover/comparator.git .lake/comparator-tools/v4.34.0-rc2
cd .lake/comparator-tools/v4.34.0-rc2
env LEAN_NUM_THREADS=2 lake build lean4export comparator
```

Return to the repository root and run:

```sh
COMPARATOR_LANDRUN="$PWD/.lake/comparator-tools/v4.34.0-rc2/scripts/fake-landrun.sh" \
  python3 ComparatorSupport/run_comparator.py
```

The local default is two Lean worker threads. `--threads N` changes concurrency;
`--stream --fail-fast` streams diagnostics and stops the run on a build error.
Hosted CI uses up to four detected CPU cores and lets independent build jobs
finish after a compilation failure, so the log can report multiple errors in one
run. No heartbeat limit is changed.

The runner writes its log, exit status, tool revisions, and before/after source
hashes below `.lake/comparator/`. It reports a pass only after Comparator exits
successfully, prints its success and kernel-acceptance messages, and the inputs
remain unchanged. Both the local macOS run and hosted Ubuntu workflow use the
official development launcher without OS sandbox isolation. The statement
comparison, transitive axiom audit, and Lean kernel replay still run.

`comparator-pass.json` records the final official verdict. `validation.json`,
`LEVI_CIVITA_STATUS.md`, and `UPGRADE_PORT_STATUS.md` summarize the final result
and the earlier checks, retaining their precise scopes. This validates the
Hamilton pair and its proof dependencies; it is not a full-repository build.
