import numpy as np
import jax.numpy as jnp
import matplotlib.pyplot as plt
from jaxlayerRF import calculate_reflection_coefficients
from utils import initialize_epsr_mur, add_backing_material

# Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f_GHz = np.arange(0.1, 1.01, 0.01)
f = f_GHz * 1e9  # Convert to Hz

# Thickness of the films [mm]
thicknessMM = [1.0]  # Single layer of 1 mm thickness
materialInd = [6]    # Material index 6

# Initialize epsr and mur using JAX arrays
epsr, mur = initialize_epsr_mur(materialInd, f_GHz)

# Add backing material (PEC or air)
backing_material = 'PEC'  # Options: 'PEC' or 'air'
epsr, mur = add_backing_material(epsr, mur, backing_material)

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

# Calculate refractive index (n) and extinction coefficient (k) for the selected material
# Adjust index to account for air layer at the beginning
material_idx = 1  # The material is at index 1 after the air layer

material_epsr = epsr[material_idx, :]
material_mur = mur[material_idx, :]

# Calculate refractive index n = sqrt(epsr * mur)
nk = jnp.sqrt(material_epsr * material_mur)
n = jnp.real(nk)
k = -jnp.imag(nk)

# Convert frequency from GHz to wavelength in microns
c = 299792458  # Speed of light in m/s
lambda_microns = (c / (f_GHz_np * 1e9)) * 1e6  # Wavelength in microns

# Plot n and k versus wavelength
# plt.figure(figsize=(8, 6))
# plt.plot(lambda_microns, n, label='n')
# plt.plot(lambda_microns, k, label='k')
# plt.xlabel('Wavelength (microns)')
# plt.ylabel('Refractive Index')
# plt.title('Refractive Index and Extinction Coefficient vs Wavelength')
# plt.legend()
# plt.grid(True)
# plt.show()