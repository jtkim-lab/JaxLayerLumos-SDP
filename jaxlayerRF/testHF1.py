import numpy as np
import matplotlib.pyplot as plt
import jax.numpy as jnp
from jaxlayerRF import calculate_reflection_coefficients
from utils import initialize_epsr_mur, add_incident_and_backing_layers

# Frequency range in GHz
f_GHz = np.arange(0.1, 10.01, 0.01)  # From 0.1 to 10 GHz
f = f_GHz * 1e9  # Convert to Hz

# Material indices and thicknesses
thicknessMM = [1.155, 0.885, 1.272, 1.446, 0.486]  # Thicknesses in mm
materialInd = [2, 11, 5, 6, 16]  # Material indices

# Number of layers
M = len(thicknessMM)  # Number of finite slabs

# Initialize epsr and mur for the material layers
epsr_layers, mur_layers = initialize_epsr_mur(materialInd, f_GHz)

# Add incident medium and backing material
epsr, mur = add_incident_and_backing_layers(epsr_layers, mur_layers, f_GHz, incident_medium='air', backing_material='PEC')

# Convert thickness from mm to meters
d = np.array(thicknessMM) * 1e-3  # Thickness in meters
# Note: d has length M and does not include incident medium or backing layer

# Angle of incidence
theta_inc = 0.0

# Convert arrays to jax.numpy arrays
f_jax = jnp.array(f)
d_jax = jnp.array(d)

# Calculate reflection coefficients using JAX function
rSlab_TE_abs, rSlab_TM_abs = calculate_reflection_coefficients(
    theta_inc, epsr, mur, f_jax, d_jax
)

# Convert reflection coefficient to dB
rSlab_TE_db = 10 * jnp.log10(rSlab_TE_abs)

# Convert to numpy arrays for plotting
f_GHz_np = np.array(f_GHz)
rSlab_TE_db_np = np.array(rSlab_TE_db)

# Plotting
plt.figure(figsize=(8, 6))
plt.semilogx(f_GHz_np, rSlab_TE_db_np, 'r', linewidth=2.5)
plt.xlabel('Frequency (GHz)')
plt.ylabel('Reflection (dB)')
plt.title('Total Reflection vs Frequency for TE Wave')
plt.grid(True)
plt.show()