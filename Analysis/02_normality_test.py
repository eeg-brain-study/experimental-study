"""
Shapiro-Wilk normality test for the Frontal channel across each frequency band and activity.
Tests BL01–BL04 within Alpha, Beta, Delta, and Theta bands.
"""

import pandas as pd
from scipy import stats
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "REG", "EEG_ALL_WAVES_REG.csv")

df = pd.read_csv(DATA_FILE)

tasks = ["BL01", "BL02", "BL03", "BL04"]
waves = df["Wave"].unique()

for wave in waves:
    print(f"\n===== Wave: {wave} =====")
    df_wave = df[df["Wave"] == wave]

    for task in tasks:
        frontal = df_wave[df_wave["Atividade"] == task]["Frontal"]
        stat, p = stats.shapiro(frontal)
        result = "normal" if p > 0.05 else "NOT normal"
        print(f"  {task} — Frontal: stat={stat:.3f}, p={p:.4f} → {result}")
