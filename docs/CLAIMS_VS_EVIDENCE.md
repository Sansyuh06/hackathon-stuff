# CLAIMS_VS_EVIDENCE.md

Every headline claim in this project, what backs it, and what it does not show. Status key:
**Verified** (a test or script demonstrates it), **Simulated** (true inside the simulator only),
**Not claimed** (explicitly out of scope).

| # | Claim | Status | Evidence | What it does NOT show |
|---|---|---|---|---|
| 1 | Honest signatures are accepted | Verified | `test_pipeline.py::test_honest_pipeline_transfer_success`, `scripts/scoreboard.py` | Behaviour on real quantum hardware noise |
| 2 | Forgery by an uninformed guesser is rejected with P_forge about 9.4e-7 (n=64) | Verified (in the stated model) | `docs/BENCHMARKS.md`, `analysis/roc.py`, `test_roc.py` | Security against an attacker with partial information (see 3) |
| 3 | Detector strength against informed attackers | Verified | `docs/ROC_ANALYSIS.md`: with the Hoeffding threshold, a forger needs about 59% of the true syndromes; with the exact-binomial threshold about 90% | Physical means of obtaining that information |
| 4 | The detector is "blind" (does not read attack flags) | Verified | `test_attacks.py::test_impersonation_attack_vector`, `test_pqc_real.py`: impersonation is caught from the ML-DSA signature alone; the `actual_signer` label was removed | The demo harness still chooses which attack to run; detection itself uses no flags |
| 5 | Impersonation attribution | Verified | `test_pipeline.py::test_impersonator_account_is_quarantined_not_the_victim` | Attribution works only among registered keys |
| 6 | An attacker cannot lock out a victim by naming them | Verified | `test_pipeline.py::test_unauthenticated_forgeries_cannot_lock_victim_or_bank`, `test_stages.py::test_unattributed_events_never_reach_global_scope` | Protection against a flood from many real source addresses (rate limiting is not implemented) |
| 7 | Global lockdown needs evidence the sender cannot forge | Verified | `test_stages.py` (link evidence or attributed streak required) | In this repo "link evidence" is the simulated BB84 QBER |
| 8 | Stages recover without manual reset | Verified | `test_stages.py::test_trust_decay_*` (default 300 s, `SHORLYNOT_DECAY_SECONDS`) | Per-user risk scoring, human approval flow |
| 9 | Tamper-evident event log | Verified | `test_audit_chain.py`; `GET /v1/audit/verify` | Tail truncation is detected only against an externally anchored head hash. The bank's own SQLite ledger is not chained |
| 10 | Real ML-KEM-768 (FIPS 203) in the wrap key | Verified | `test_pqc_real.py`; `pqc/kem_interface.py` uses `kyber-py` | `kyber-py` is a pure-Python reference implementation, not constant-time. Use liboqs for production |
| 11 | Real ML-DSA-44 (FIPS 204) identity binding | Verified | `test_pqc_real.py` | The demo keystore holds signer secret keys in the verifier's process. In production they live in the signer's device or HSM |
| 12 | Hybrid wrap key (BB84 + ML-KEM) | Verified | `pqc/hybrid.py`, pipeline | BB84 itself is simulated in-process (no real channel, reconciliation or privacy amplification) |
| 13 | "Quantum digital signature" | Not claimed as a standalone signature | `docs/SECURITY_ANALYSIS.md` section 4 | The verifier reads its ground truth from a session store that simulates Bob's entanglement half. This is symmetric tamper-evidence between two parties, not a transferable signature with non-repudiation |
| 14 | Real Bell circuits on the sign & circuit-verify paths | Verified | `test_real_circuits.py` | Default fast gateway check uses analytic $O(n)$ Born-rule (`mode="circuit"` runs full Qiskit Aer circuits) |
| 15 | OpenWrt router guard | Verified (mock fw4 harness) | `ShorlyNot-Router-Firmware/tests/run_tests.sh` (7/7 suites, 41 assertions) | Live demo status uses `mock_kms.py` unless physical TP-Link Archer C6 is attached on `192.168.1.1` |
| 16 | SOC "hardware" panels | Simulated | `bank/static/js/soc.js` | Router rules, packet drops and device info shown there are generated, not observed |

## Known gaps (not fixed)

- `/v1/sign` signs for any registered key to any authenticated API caller (the "just ask the server to sign" case).
- The Bob-side session store is the root of trust for the statistical check.
- No rate limiting by source, no MFA, transaction limits, idempotency or regulatory mapping in the bank demo.
- Honest-noise independence is assumed; real hardware drifts and has correlated errors.
- Real-hardware validation is optional (`IBM_QUANTUM_TOKEN`) and has not been run.

## Reproduce

```bash
pip install -r requirements.txt -e skeleton
python -m pytest -q                 # full suite
python scripts/roc_benchmark.py     # regenerates docs/ROC_ANALYSIS.md and plots
python scripts/demo_attacks.py      # 8-step attack and defence walkthrough
```
