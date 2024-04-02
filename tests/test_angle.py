import unittest
import jax.numpy as jnp
import scipy.constants as scic
import numpy as np
from jaxlayerlumos.utils_materials import load_material, interpolate_material
from jaxlayerlumos.jaxlayerlumos import stackrt

class TestJaxLayerLumosStackrt(unittest.TestCase):
    def test_stackrt_with_angles(self):
        # Load material data for TiO2
        TiO2_data = load_material('TiO2')

        # Define wavelength range (in meters)
        wavelengths = jnp.linspace(300e-9, 900e-9, 3)  # 3 points from 300nm to 900nm
        frequencies = scic.c / wavelengths  # Convert wavelengths to frequencies

        # Interpolate n and k values for TiO2 over the specified frequency range
        n_k_TiO2 = interpolate_material(TiO2_data, frequencies)
        n_TiO2 = n_k_TiO2[:, 0] + 1j * n_k_TiO2[:, 1]  # Combine n and k into a complex refractive index

        # Define stack configuration
        n_air = jnp.ones_like(wavelengths)  # Refractive index of air is approximately 1
        n_stack = jnp.vstack([n_air, n_TiO2, n_air]).T  # Transpose to match expected shape (Nlayers x Nfreq)
        d_stack = jnp.array([0, 2e-8, 0])  # Stack thickness for air-TiO2-air
        thetas = jnp.linspace(0, 89, 3)  # Incident angles from 0 to 89 degrees

        # Calculate R and T over the frequency range for different incident angles
        R_TE, T_TE, R_TM, T_TM = stackrt(n_stack, d_stack, frequencies, thetas)

        # Calculate average R and T
        R_avg = (R_TE + R_TM) / 2
        T_avg = (T_TE + T_TM) / 2
        # print(R_avg)
        # print(T_avg)

        # Expected results should be updated based on actual TiO2 data and calculation methods
        expected_R_avg = jnp.array([
            [0.50752076, 0.18726596, 0.08370757],
            [0.49468394, 0.20636282, 0.09914127],
            [0.95155563, 0.98174179, 0.96171754]
        ])

        expected_T_avg = jnp.array([
            [0.17838769, 0.81273404, 0.91629243],
            [0.19032342, 0.79363718, 0.90085873],
            [0.00645613, 0.01825821, 0.03828246]
        ])

        # Verify the results with JAX's testing utilities
        np.testing.assert_allclose(R_avg, expected_R_avg, rtol=1e-3, atol=1e-8, err_msg="Reflectance values do not match expected results")
        np.testing.assert_allclose(T_avg, expected_T_avg, rtol=1e-3, atol=1e-8, err_msg="Transmittance values do not match expected results")

if __name__ == "__main__":
    unittest.main()

