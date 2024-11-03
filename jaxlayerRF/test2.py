import numpy as np
import matplotlib.pyplot as plt
import jax.numpy as jnp
from jaxlayerRF import calculate_reflection_coefficients
from utils import initialize_epsr_mur, add_incident_and_backing_layers

# Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f_GHz = np.arange(0.1, 1.01, 0.01)
f = f_GHz * 1e9  # Convert to Hz

# Thickness of the films [mm]
thicknessMM = [1.0]  # Single layer of 1 mm thickness
materialInd = [6]    # Material index 6

# Initialize epsr and mur for the material layers
epsr_layers, mur_layers = initialize_epsr_mur(materialInd, f_GHz)

# Number of frequency points
Nf = f_GHz.size

# Combine all layers
epsr, mur = add_incident_and_backing_layers(epsr_layers, mur_layers, f_GHz, incident_medium='air', backing_material='PEC')

# Convert thickness from mm to meters
d = np.array(thicknessMM) * 1e-3  # Thickness in meters

# Convert arrays to JAX arrays
f_jax = jnp.array(f)
d_jax = jnp.array(d)

# Angle of incidence in degrees
theta_inc = 0.0

# Calculate reflection coefficients using the function from jaxlayerRF.py
rSlab_TE_abs, rSlab_TM_abs = calculate_reflection_coefficients(
    theta_inc, epsr, mur, f_jax, d_jax
)

# Convert reflection coefficient to dB
rSlab_TE_db = 10 * jnp.log10(rSlab_TE_abs)

# Convert results to NumPy arrays for plotting
f_GHz_np = np.array(f_GHz)
rSlab_TE_db_np = np.array(rSlab_TE_db)

# Plot the results
plt.figure(figsize=(8, 6))
plt.semilogx(f_GHz_np, rSlab_TE_db_np, 'r', linewidth=2.5)
plt.xlabel('Frequency (GHz)')
plt.ylabel('Reflection in dB')
plt.title('Total Reflection vs Frequency for TE Wave')
plt.grid(True)
plt.show()
