import jax.numpy as jnp

def initialize_epsr_mur(materialInd, f_GHz):
    """
    Initializes the relative permittivity (epsr) and permeability (mur)
    for the given material indices over the frequency range f_GHz using JAX.
    """
    # Ensure f_GHz is a JAX array
    f_GHz = jnp.array(f_GHz)
    Nf = f_GHz.size
    num_materials = 16  # Total number of materials defined

    # Initialize arrays
    M_epsr = jnp.zeros((num_materials, Nf), dtype=complex)
    M_mur = jnp.zeros((num_materials, Nf), dtype=complex)

    # Fill constant values for permittivity (epsr)
    M_epsr = M_epsr.at[0:5, :].set(jnp.array([[10], [50], [15], [15], [15]], dtype=complex))
    M_epsr = M_epsr.at[8:16, :].set(15.0 + 0j)

    # Frequency-dependent permittivity values for materials 6 to 8
    M_epsr = M_epsr.at[5, :].set(5 / (f_GHz ** 0.861) - 1j * (8 / (f_GHz ** 0.569)))
    M_epsr = M_epsr.at[6, :].set(8 / (f_GHz ** 0.778) - 1j * (10 / (f_GHz ** 0.682)))
    M_epsr = M_epsr.at[7, :].set(10 / (f_GHz ** 0.778) - 1j * (6 / (f_GHz ** 0.861)))

    # Fill constant values for permeability (mur)
    M_mur = M_mur.at[0:2, :].set(1.0 + 0j)
    M_mur = M_mur.at[5:8, :].set(1.0 + 0j)

    # Frequency-dependent permeability for materials 3 to 5
    M_mur = M_mur.at[2, :].set(5 / (f_GHz ** 0.974) - 1j * (10 / (f_GHz ** 0.961)))
    M_mur = M_mur.at[3, :].set(3 / (f_GHz ** 1.0) - 1j * (15 / (f_GHz ** 0.957)))
    M_mur = M_mur.at[4, :].set(7 / (f_GHz ** 1.0) - 1j * (12 / (f_GHz ** 1.0)))

    # Frequency-dependent permeability for materials 9 to 16
    def frequency_dependent_mur(A, f0):
        return ((A * (f0 ** 2)) / (f_GHz ** 2 + f0 ** 2)
                - 1j * (A * f0 * f_GHz) / (f_GHz ** 2 + f0 ** 2))

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

    for idx, (A, f0) in enumerate(params, start=8):
        M_mur = M_mur.at[idx, :].set(frequency_dependent_mur(A, f0))

    # Select materials based on indices
    material_indices = jnp.array(materialInd) - 1  # Adjust for zero-based indexing
    material_indices = material_indices.astype(int)  # Ensure integer indices

    # Gather epsr and mur for selected materials
    epsr_layers = M_epsr[material_indices, :]
    mur_layers = M_mur[material_indices, :]

    # Add air layer at the beginning (incident medium)
    epsr = jnp.vstack([jnp.ones((1, Nf), dtype=complex), epsr_layers])
    mur = jnp.vstack([jnp.ones((1, Nf), dtype=complex), mur_layers])

    return epsr, mur
