"""Smoke tests for plugin-level Python scripts.

Covers 5 scripts across the business + lifestyle marketplaces:
- macro-calc            (official-lifestyle-plugins/health-wellness)
- retirement-projection (official-lifestyle-plugins/personal-finance)
- debt-payoff-calc      (official-lifestyle-plugins/personal-finance)
- power-calc            (official-business-plugins/data-science)
- cvp-calc              (official-business-plugins/economics)

Each test invokes the script with a small valid input and asserts:
- Exit code 0 (or expected non-zero for error cases)
- Some expected substring in stdout / stderr

Run from the repo root:

    python -m pytest tests/scripts/test_smoke.py -v

Or without pytest:

    python tests/scripts/test_smoke.py

Pure stdlib — no third-party deps.
"""
from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]


def run(script: str, *args: str, stdin: str | None = None) -> subprocess.CompletedProcess:
    """Invoke a plugin script and return the completed-process result."""
    cmd = [sys.executable, str(REPO_ROOT / script), *args]
    return subprocess.run(
        cmd,
        input=stdin,
        capture_output=True,
        text=True,
        check=False,
        timeout=30,
    )


class TestMacroCalc(unittest.TestCase):
    """official-lifestyle-plugins/health-wellness/scripts/macro-calc.py"""

    SCRIPT = "official-lifestyle-plugins/health-wellness/scripts/macro-calc.py"

    def test_maintenance_male(self):
        r = run(self.SCRIPT, "--sex", "M", "--age", "34", "--kg", "80",
                "--cm", "180", "--activity", "1.55", "--goal", "maintenance")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("TDEE", r.stdout)
        self.assertIn("Protein", r.stdout)
        self.assertIn("Carbs", r.stdout)

    def test_recomp_female(self):
        r = run(self.SCRIPT, "--sex", "F", "--age", "30", "--kg", "65",
                "--cm", "168", "--activity", "1.55", "--goal", "recomp")
        self.assertEqual(r.returncode, 0)
        self.assertIn("Target", r.stdout)

    def test_aggressive_loss_warns(self):
        r = run(self.SCRIPT, "--sex", "M", "--age", "40", "--kg", "100",
                "--cm", "175", "--activity", "1.2", "--goal", "agg_loss")
        self.assertEqual(r.returncode, 0)
        self.assertIn("WARNING", r.stderr)


class TestRetirementProjection(unittest.TestCase):
    """official-lifestyle-plugins/personal-finance/scripts/retirement-projection.py"""

    SCRIPT = "official-lifestyle-plugins/personal-finance/scripts/retirement-projection.py"

    def test_sustained_scenario(self):
        r = run(self.SCRIPT,
                "--age", "35", "--retire", "65",
                "--super", "120000", "--salary", "110000",
                "--contrib_pct", "0.115", "--return", "0.07",
                "--inflation", "0.025", "--drawdown_pct", "0.04",
                "--years_drawdown", "25")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("Nominal:", r.stdout)
        self.assertIn("Outcome:", r.stdout)

    def test_depleted_scenario(self):
        # Tiny balance + high drawdown should deplete quickly
        r = run(self.SCRIPT,
                "--age", "65", "--retire", "66",
                "--super", "50000", "--salary", "60000",
                "--contrib_pct", "0.115", "--return", "0.04",
                "--inflation", "0.025", "--drawdown_pct", "0.20",
                "--years_drawdown", "25")
        self.assertEqual(r.returncode, 0)
        self.assertIn("depleted", r.stdout)


class TestDebtPayoffCalc(unittest.TestCase):
    """official-lifestyle-plugins/personal-finance/scripts/debt-payoff-calc.py"""

    SCRIPT = "official-lifestyle-plugins/personal-finance/scripts/debt-payoff-calc.py"

    def _make_csv(self) -> str:
        return (
            "name,balance,apr,min_payment\n"
            "CC1,5000,0.21,150\n"
            "Personal,8000,0.10,200\n"
            "Car,12000,0.08,350\n"
        )

    def test_both_strategies(self):
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, encoding="utf-8") as f:
            f.write(self._make_csv())
            path = f.name
        try:
            r = run(self.SCRIPT, "--csv", path, "--extra_monthly", "500",
                    "--strategy", "both")
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn("Avalanche:", r.stdout)
            self.assertIn("Snowball:", r.stdout)
        finally:
            os.unlink(path)

    def test_avalanche_only(self):
        with tempfile.NamedTemporaryFile("w", suffix=".csv", delete=False, encoding="utf-8") as f:
            f.write(self._make_csv())
            path = f.name
        try:
            r = run(self.SCRIPT, "--csv", path, "--extra_monthly", "300",
                    "--strategy", "avalanche")
            self.assertEqual(r.returncode, 0)
            self.assertIn("Avalanche", r.stdout)
            self.assertNotIn("Snowball", r.stdout)
        finally:
            os.unlink(path)


class TestPowerCalc(unittest.TestCase):
    """official-business-plugins/data-science/scripts/power-calc.py"""

    SCRIPT = "official-business-plugins/data-science/scripts/power-calc.py"

    def test_standard_ab_test(self):
        r = run(self.SCRIPT, "--baseline", "0.05", "--mde", "0.005",
                "--alpha", "0.05", "--power", "0.8", "--two_sided")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("Sample per group:", r.stdout)
        self.assertIn("Total sample:", r.stdout)

    def test_smaller_mde_needs_more_sample(self):
        r1 = run(self.SCRIPT, "--baseline", "0.10", "--mde", "0.01", "--two_sided")
        r2 = run(self.SCRIPT, "--baseline", "0.10", "--mde", "0.005", "--two_sided")

        def n_from(out):
            for line in out.splitlines():
                if "Total sample:" in line:
                    return int(line.split(":")[1].strip().replace(",", ""))
            return None
        n1 = n_from(r1.stdout)
        n2 = n_from(r2.stdout)
        self.assertGreater(n2, n1, "smaller MDE should require more sample")


class TestCvpCalc(unittest.TestCase):
    """official-business-plugins/economics/scripts/cvp-calc.py"""

    SCRIPT = "official-business-plugins/economics/scripts/cvp-calc.py"

    def test_basic_break_even(self):
        r = run(self.SCRIPT, "--fixed", "100000", "--variable_per_unit", "20",
                "--price", "50", "--target_profit", "0")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("Break-even units:", r.stdout)
        self.assertIn("Sensitivity", r.stdout)

    def test_negative_margin_errors(self):
        r = run(self.SCRIPT, "--fixed", "100000", "--variable_per_unit", "60",
                "--price", "50", "--target_profit", "0")
        # cm_per_unit = 50 - 60 = -10; should print error and exit non-zero
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("ERROR", r.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
