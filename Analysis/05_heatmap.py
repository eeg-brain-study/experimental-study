"""
Heatmap of average EEG Frontal power across testing activities and frequency bands.
Saves the figure as eeg_heatmap.png in the project root.
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "REG", "EEG_ALL_WAVES_REG.csv")
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), "..", "eeg_heatmap.png")

df = pd.read_csv(DATA_FILE)

tabela = df.groupby(["Wave", "Atividade"])["Frontal"].mean().unstack("Atividade")
tabela = tabela[["BL01", "BL02", "BL03", "BL04"]].round(2)

BAND_ORDER = ["Alpha", "Beta", "Theta", "Delta"]
tabela = tabela.reindex(BAND_ORDER)

BAND_LABELS = {
    "Alpha": "Alpha\n(8–13 Hz)",
    "Beta":  "Beta\n(13–30 Hz)",
    "Theta": "Theta\n(4–7 Hz)",
    "Delta": "Delta\n(1–4 Hz)",
}

ACTIVITY_LABELS = {
    "BL01": "BL01\nTest Code\nComprehension",
    "BL02": "BL02\nSyntax Error\nIdentification",
    "BL03": "BL03\nLogic Error\nIdentification",
    "BL04": "BL04\nTest Case\nDesign",
}

fig, ax = plt.subplots(figsize=(10, 6))
fig.patch.set_facecolor("white")

norm = mcolors.TwoSlopeNorm(vmin=-6, vcenter=0, vmax=7)
cmap = plt.cm.RdBu_r

im = ax.imshow(tabela.values, cmap=cmap, norm=norm, aspect="auto")

ax.set_xticks(range(len(tabela.columns)))
ax.set_xticklabels(
    [ACTIVITY_LABELS[c] for c in tabela.columns],
    fontsize=13, ha="center", va="top",
)
ax.xaxis.set_ticks_position("bottom")
ax.tick_params(axis="x", length=0, pad=8)

ax.set_yticks(range(len(tabela.index)))
ax.set_yticklabels(
    [BAND_LABELS[b] for b in tabela.index],
    fontsize=15, ha="right", va="center", fontweight="bold",
)
ax.tick_params(axis="y", length=0, pad=10)

ax.set_xlabel("Testing Activity", fontsize=15, fontweight="bold", labelpad=45)
ax.set_ylabel("Frequency Band", fontsize=15, fontweight="bold", labelpad=10)

for i in range(len(tabela.index)):
    for j in range(len(tabela.columns)):
        val = tabela.values[i, j]
        brightness = norm(val)
        color = "white" if brightness < 0.3 or brightness > 0.72 else "#333333"
        ax.text(j, i, f"{val:.2f}", ha="center", va="center",
                fontsize=15, color=color, fontweight="bold")

for x in range(tabela.shape[1] + 1):
    ax.axvline(x - 0.5, color="white", linewidth=2)
for y in range(tabela.shape[0] + 1):
    ax.axhline(y - 0.5, color="white", linewidth=2)

cbar = fig.colorbar(im, ax=ax, fraction=0.035, pad=0.02, aspect=20)
cbar.set_label("Average Power (µV)", fontsize=15, labelpad=10)
cbar.ax.tick_params(labelsize=9)
cbar.outline.set_visible(False)

ax.set_title(
    "Average EEG Activity Across Testing Activities and Frequency Bands",
    fontsize=15, fontweight="bold", pad=20, loc="center",
)
ax.spines[:].set_visible(False)

plt.tight_layout()
plt.savefig(OUTPUT_FILE, dpi=150, bbox_inches="tight", facecolor="white")
plt.show()
print(f"Saved: {OUTPUT_FILE}")
