# Tests

Smoke tests for plugin-level Python scripts across the two marketplaces.

## Run

```bash
# Pure stdlib unittest (no pytest required)
python tests/scripts/test_smoke.py

# Or via pytest if installed
python -m pytest tests/scripts/test_smoke.py -v
```

## Coverage (11 tests)

| Script | Test class | Cases |
|---|---|---|
| `official-lifestyle-plugins/health-wellness/scripts/macro-calc.py` | `TestMacroCalc` | maintenance / recomp / aggressive-loss-warn |
| `official-lifestyle-plugins/personal-finance/scripts/retirement-projection.py` | `TestRetirementProjection` | sustained / depleted |
| `official-lifestyle-plugins/personal-finance/scripts/debt-payoff-calc.py` | `TestDebtPayoffCalc` | both / avalanche-only |
| `official-business-plugins/data-science/scripts/power-calc.py` | `TestPowerCalc` | standard A/B / smaller-MDE-bigger-N |
| `official-business-plugins/economics/scripts/cvp-calc.py` | `TestCvpCalc` | basic break-even / negative-margin-errors |

Pure stdlib only — no third-party dependencies.
