import numpy as np
import matplotlib.pyplot as plt

# Frequency range in GHz
f_GHz = np.arange(0.1, 1.01, 0.01)
f = f_GHz * 1e9  # Convert to Hz
numFrequencies = len(f)

# Material indices and thicknesses
xValues = [2]  # Thicknesses in mm
yValues = [3]  # Material indices

nVar = len(xValues)
M = nVar  # Number of layers

# Initialize arrays for M_epsr and M_mur
num_materials = 16
M_epsr = np.zeros((num_materials, numFrequencies), dtype=complex)
M_mur = np.zeros((num_materials, numFrequencies), dtype=complex)

# Materials 1 to 5
M_epsr[0:5, :] = np.array([[10], [50], [15], [15], [15]])

# Materials 6 to 8 with frequency-dependent permittivity
M_epsr[5, :] = 5 / (f_GHz ** 0.861) - 1j * (8 / (f_GHz ** 0.569))
M_epsr[6, :] = 8 / (f_GHz ** 0.778) - 1j * (10 / (f_GHz ** 0.682))
M_epsr[7, :] = 10 / (f_GHz ** 0.778) - 1j * (6 / (f_GHz ** 0.861))

# Materials 9 to 16
M_epsr[8:16, :] = 15

# Materials 1 and 2
M_mur[0:2, :] = 1

# Materials 3 to 5 with frequency-dependent permeability
M_mur[2, :] = 5 / (f_GHz ** 0.974) - 1j * (10 / (f_GHz ** 0.961))
M_mur[3, :] = 3 / (f_GHz ** 1.0) - 1j * (15 / (f_GHz ** 0.957))
M_mur[4, :] = 7 / (f_GHz ** 1.0) - 1j * (12 / (f_GHz ** 1.0))

# Materials 6 to 8
M_mur[5:8, :] = 1

# Materials 9 to 16 with frequency-dependent permeability
def frequency_dependent_mur(A, f0):
    return (A * (f0 ** 2)) / (f_GHz ** 2 + f0 ** 2) - 1j * (A * f0 * f_GHz) / (f_GHz ** 2 + f0 ** 2)

params = [
    (35, 0.8),   # Material 9
    (35, 0.5),   # Material 10
    (30, 1.0),   # Material 11
    (18, 0.5),   # Material 12
    (20, 1.5),   # Material 13
    (30, 2.5),   # Material 14
    (30, 2.0),   # Material 15
    (25, 3.5),   # Material 16
]

for idx, (A, f0) in enumerate(params):
    M_mur[8 + idx, :] = frequency_dependent_mur(A, f0)

# Adjust indices for zero-based indexing
material_indices = np.array(yValues) - 1  # Adjust for zero-based indexing

# Build epsr and mur arrays (shape: [M+2, Nf])
epsr = np.zeros((nVar + 2, numFrequencies), dtype=complex)
mur = np.zeros((nVar + 2, numFrequencies), dtype=complex)

# Infinite medium and air
epsr[0, :] = 1  # Infinite medium
epsr[-1, :] = 1  # Air
mur[0, :] = 1
mur[-1, :] = 1

# Layer materials
for a in range(nVar):
    epsr[a + 1, :] = M_epsr[material_indices[a], :]
    mur[a + 1, :] = M_mur[material_indices[a], :]

# Convert thickness from mm to meters
d = np.array(xValues) * 1e-3  # Thickness in meters

# Angle of incidence
theta_inc = 0.0

# Backing layer code (0 for PEC)
backing_code = 0

# Calculate reflection coefficients
rSlab_TE_abs_full, rSlab_TM_abs_full = calculate_reflection_coefficients_full(
    M, theta_inc, epsr, mur, f, d, backing_code
)

# Extract the reflection coefficient at the last interface
a = rSlab_TE_abs_full[M, :]  # Shape: (Nf,)

# Convert to dB
rSlab_TE_db = 10 * np.log10(a)

# Plotting
plt.figure(figsize=(8, 6))
plt.semilogx(f_GHz, rSlab_TE_db, 'r', linewidth=2.5)
plt.xlabel('Frequency (GHz)')
plt.ylabel('Reflection in dB')
plt.title('Total Reflection vs Frequency for TE Wave')
plt.grid(True)
plt.show()
