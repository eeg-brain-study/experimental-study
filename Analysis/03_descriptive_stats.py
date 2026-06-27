"""
Descriptive statistics for EEG regional power data:
  1. Mean per frequency band across all channels
  2. Mean per frequency band and activity (Wave × Atividade)
  3. Overall mean (average of all 4 channels) per frequency band
  4. Frontal channel pivot table (Wave × Activity)
"""

import pandas as pd
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "REG", "EEG_ALL_WAVES_REG.csv")

CHANNELS = ["Frontal", "TempDir", "TempEsq", "Ocipita"]

df = pd.read_csv(DATA_FILE)

print("=" * 55)
print("  1. Mean per Wave (all channels)")
print("=" * 55)
mean_by_wave = df.groupby("Wave")[CHANNELS].mean()
print(mean_by_wave.round(4))

print("\n" + "=" * 55)
print("  2. Mean per Wave × Activity (all channels)")
print("=" * 55)
mean_wave_activity = df.groupby(["Wave", "Atividade"])[CHANNELS].mean()
print(mean_wave_activity.round(4))

print("\n" + "=" * 55)
print("  3. Overall Mean (avg of 4 channels) per Wave")
print("=" * 55)
df["media_geral"] = df[CHANNELS].mean(axis=1)
overall_mean = df.groupby("Wave")["media_geral"].mean()
print(overall_mean.round(4))

print("\n" + "=" * 55)
print("  4. Frontal Channel Pivot (Wave × Activity)")
print("=" * 55)
pivot = df.groupby(["Wave", "Atividade"])["Frontal"].mean().unstack("Atividade")
pivot = pivot[["BL01", "BL02", "BL03", "BL04"]]
print(pivot.round(2))
