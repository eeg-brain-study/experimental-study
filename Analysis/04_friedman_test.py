"""
Friedman test on Frontal EEG power across testing activities (BL01–BL04) within each frequency band.
Computes Kendall's W as effect size and applies Nemenyi post-hoc when p < 0.05.
"""

import pandas as pd
import numpy as np
from scipy.stats import friedmanchisquare
import scikit_posthocs as sp
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "REG", "EEG_ALL_WAVES_REG.csv")

df = pd.read_csv(DATA_FILE)

ACTIVITIES = ["BL01", "BL02", "BL03", "BL04"]
WAVES = ["Alpha", "Beta", "Delta", "Theta"]

df_bl = df[df["Atividade"].isin(ACTIVITIES)]

print("=" * 65)
print("  FRIEDMAN TEST — Frontal Channel by Activity (per Band)")
print("=" * 65)
print(f"\n  Blocks     : Participants (N = {df_bl['Participante'].nunique()})")
print(f"  Treatments : {ACTIVITIES}\n")

results = []

for wave in WAVES:
    pivot = (
        df_bl[df_bl["Wave"] == wave]
        .pivot(index="Participante", columns="Atividade", values="Frontal")[ACTIVITIES]
    )

    n = pivot.shape[0]
    k = pivot.shape[1]

    stat, p = friedmanchisquare(*[pivot[c] for c in ACTIVITIES])
    W = stat / (n * (k - 1))

    if W >= 0.5:
        magnitude = "Large"
    elif W >= 0.3:
        magnitude = "Medium"
    elif W >= 0.1:
        magnitude = "Small"
    else:
        magnitude = "Negligible"

    sig = "**  p < 0.01" if p < 0.01 else ("*   p < 0.05" if p < 0.05 else "ns  n.s.")
    results.append({"Wave": wave, "stat": stat, "p": p, "W": W, "magnitude": magnitude})

    print(f"  {'─' * 55}")
    print(f"  Band       : {wave}")
    print(f"  χ²({k-1}) = {stat:.4f}   p = {p:.4f}   {sig}")
    print(f"  Kendall's W = {W:.4f}   ({magnitude})")
    print(f"\n  Activity means (µV):")
    for act in ACTIVITIES:
        print(f"    {act}: {pivot[act].mean():+.4f}  (SD = {pivot[act].std():.4f})")

    if p < 0.05:
        print(f"\n  Post-hoc Nemenyi (p-values):")
        ph = sp.posthoc_nemenyi_friedman(pivot.values)
        ph.index = ACTIVITIES
        ph.columns = ACTIVITIES
        print(ph.round(4).to_string())
    else:
        print(f"\n  Post-hoc not applied (result not significant).")

    print()

print("=" * 65)
print("  SUMMARY")
print("=" * 65)
print(f"  {'Band':<10} {'χ²':>8} {'p-value':>10} {'Sig.':>6} {'W':>8} {'Magnitude'}")
print(f"  {'─' * 60}")
for r in results:
    sig = "**" if r["p"] < 0.01 else ("*" if r["p"] < 0.05 else "ns")
    print(f"  {r['Wave']:<10} {r['stat']:>8.4f} {r['p']:>10.4f} {sig:>6} {r['W']:>8.4f}  {r['magnitude']}")

print()
print("  Legend: ** p<0.01  * p<0.05  ns not significant")
print("  Effect size (Kendall's W): >0.5 Large | 0.3–0.5 Medium | 0.1–0.3 Small")
print("=" * 65)
