"""
Merge wave-specific CSV files from data/REG into a single EEG_ALL_WAVES_REG.csv.
Identifies wave type from filename and extracts Participante/Atividade from the Name column.
"""

import pandas as pd
import os
import glob

DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "REG")
OUTPUT_FILE = os.path.join(DATA_PATH, "EEG_ALL_WAVES_REG.csv")

WAVE_KEYWORDS = {
    "alpha": "Alpha",
    "beta": "Beta",
    "delta": "Delta",
    "theta": "Theta",
}

COLS_TO_DROP = ["#Epochs", "#Ephocs", "Central", "RightTemporal", "LeftTemporal", "Parietal", "Occipital"]

files = glob.glob(os.path.join(DATA_PATH, "*.csv"))
dfs = []

for file in files:
    filename = os.path.basename(file).lower()

    wave = next((label for key, label in WAVE_KEYWORDS.items() if key in filename), None)
    if wave is None:
        print(f"  Wave not identified: {filename}")
        continue

    df = pd.read_csv(file, header=1, sep=";")
    df = df.drop(columns=[c for c in COLS_TO_DROP if c in df.columns], errors="ignore")

    name_clean = df["Name"].str.replace(".set", "", regex=False)
    df["Participante"] = name_clean.str.split("_").str[0]
    df["Atividade"] = name_clean.str.split("_").str[1]
    df["Wave"] = wave
    df = df.drop(columns=["Name"])

    dfs.append(df)

df_final = pd.concat(dfs, ignore_index=True)
df_final.to_csv(OUTPUT_FILE, index=False)
print(f"Saved: {OUTPUT_FILE}")
print(f"Shape: {df_final.shape}")
print(df_final.head())
