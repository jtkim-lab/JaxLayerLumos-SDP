import jax.numpy as jnp
import jax

from jaxlayerlumos import stackrt
from jaxlayerlumos.utils_materials import get_n_k_surrounded_by_air
from jaxlayerlumos.utils_spectra import get_frequencies_visible_light
from jaxlayerlumos.utils_layers import (
    get_thicknesses_surrounded_by_air,
    convert_nm_to_m,
)


if __name__ == "__main__":
    #frequencies = get_frequencies_visible_light() #Uncomment if want to use original materials
    frequencies = jnp.arange(1e9, 1e10, 0.01e9)
    materials = ["Mat1", "Mat10", "Mat16"]
    thicknesses = jnp.array([20.0, 5.0, 30.0])
    angles = jnp.array([0.0, 45.0, 75.0, 89.0])

    n_k = get_n_k_surrounded_by_air(materials, frequencies)

    def R_TE(inputs):
        layers = convert_nm_to_m(get_thicknesses_surrounded_by_air(inputs))
        R_TE, _, _, _ = stackrt(n_k, layers, frequencies, thetas=angles)
        return R_TE[0, 0]

    gradients_R_TE = jax.grad(R_TE)(thicknesses)
    print(gradients_R_TE)
