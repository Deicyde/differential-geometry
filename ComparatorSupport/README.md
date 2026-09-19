# Hamilton Comparator pair

`Challenge.lean` imports only Mathlib and states the theorem under
`HamiltonPointwise.hamilton_positive_ricci`. Its single target proof hole is
intentional. `Solution.lean` imports the repository's original Hamilton proof
and transfers it through `HamiltonBridge.lean` to the same statement.

**Validation is in progress. A completed Comparator pass has not yet been recorded.**
The complete geometric bridge has passed its normal build, live Lean check,
and axiom audits; see `full-bridge-validation.json`. The original Hamilton proof
is still being rebuilt for the upgraded Mathlib and Lean versions.

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
remain unchanged. On macOS it uses the official development launcher, which
does not provide Linux sandbox isolation. The statement comparison, transitive
axiom audit, and Lean kernel replay still run.

The support files `validation.json`, `LEVI_CIVITA_STATUS.md`, and
`UPGRADE_PORT_STATUS.md` record earlier, limited checks and their scope. They are
not substitutes for the final Comparator verdict.
