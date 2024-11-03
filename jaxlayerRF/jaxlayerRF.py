import jax.numpy as jnp

def calculate_reflection_coefficients(Theta_inc, epsr, mur, f, d, backing_code):
    """
    Calculates the reflection coefficients for TE and TM polarization
    from a multilayer slab structure using JAX for automatic differentiation.

    Parameters:
    Theta_inc (float): Angle of incidence (degrees)
    epsr (array): Relative permittivity array for each slab (shape: [M+2, Nf])
    mur (array): Relative permeability array for each slab (shape: [M+2, Nf])
    f (array): Frequency array (Hz)
    d (array): Thickness of each slab (m), length M
    backing_code (int): Numeric code for backing layer (0 for PEC, 1 for air)

    Returns:
    rSlab_TE_abs (array): Absolute value squared of the total reflection coefficient for TE polarization
    rSlab_TM_abs (array): Absolute value squared of the total reflection coefficient for TM polarization
    """
    # Constants
    e0 = 8.854187817e-12  # Permittivity of free space [F/m]
    u0 = 1.256637061e-6   # Permeability of free space [H/m]
    Theta_inc_rad = jnp.deg2rad(Theta_inc)
    
    # Ensure inputs are JAX arrays
    f = jnp.atleast_1d(f).reshape(1, -1)  # Shape: (1, Nf)
    d = jnp.atleast_1d(d)
    epsr = jnp.atleast_2d(epsr)
    mur = jnp.atleast_2d(mur)
    
    Nf = f.shape[1]  # Number of frequency points
    M = d.size       # Number of slabs
    
    # Convert relative permittivity and permeability to absolute values
    eps = epsr * e0
    mu = mur * u0
    
    # Initialize arrays
    sinTh = jnp.zeros((M + 2, Nf), dtype=eps.dtype)
    sinTh = sinTh.at[M + 1, :].set(jnp.sin(Theta_inc_rad))
    
    # Calculate wave numbers
    k = 2 * jnp.pi * f * jnp.sqrt(eps * mu)
    kz = jnp.zeros((M + 2, Nf), dtype=eps.dtype)
    kz = kz.at[M + 1, :].set(k[M + 1, :] * jnp.cos(Theta_inc_rad))
    
    # Calculate sin(theta) for each layer using Snell's Law
    for i in range(1, M + 2):
        sinTh = sinTh.at[M + 1 - i, :].set(
            (k[M + 2 - i, :] * sinTh[M + 2 - i, :]) / k[M + 1 - i, :]
        )
    
    # Calculate kz for each layer
    kz = kz.at[:M + 1, :].set(k[:M + 1, :] * jnp.sqrt(1 - sinTh[:M + 1, :] ** 2))
    
    # Calculate Fresnel reflection coefficients
    rFresnel = jnp.zeros((M + 1, Nf), dtype=eps.dtype)
    rFresnelH = jnp.zeros((M + 1, Nf), dtype=eps.dtype)
    for i in range(M + 1):
        numerator_TE = mu[i, :] * kz[i + 1, :] - mu[i + 1, :] * kz[i, :]
        denominator_TE = mu[i, :] * kz[i + 1, :] + mu[i + 1, :] * kz[i, :]
        rFresnel = rFresnel.at[i, :].set(numerator_TE / denominator_TE)
    
        numerator_TM = kz[i, :] * eps[i + 1, :] - kz[i + 1, :] * eps[i, :]
        denominator_TM = kz[i, :] * eps[i + 1, :] + kz[i + 1, :] * eps[i, :]
        rFresnelH = rFresnelH.at[i, :].set(numerator_TM / denominator_TM)
    
    # Initialize total reflection coefficients
    rSlab_TE = jnp.zeros((M + 1, Nf), dtype=eps.dtype)
    rSlab_TM = jnp.zeros((M + 1, Nf), dtype=eps.dtype)
    
    # Compute initial reflection coefficients based on backing_code
    r_back_TE = jnp.where(backing_code == 0, -1.0, rFresnel[0, :])
    r_back_TM = jnp.where(backing_code == 0, -1.0, rFresnelH[0, :])
    
    rSlab_TE = rSlab_TE.at[0, :].set(r_back_TE)
    rSlab_TM = rSlab_TM.at[0, :].set(r_back_TM)
    
    # Compute total reflection coefficients
    for i in range(1, M + 1):
        exp_term = jnp.exp(-2j * kz[i, :] * d[i - 1])
        denominator_TE = 1 + rFresnel[i, :] * rSlab_TE[i - 1, :] * exp_term
        rSlab_TE = rSlab_TE.at[i, :].set(
            (rFresnel[i, :] + rSlab_TE[i - 1, :] * exp_term) / denominator_TE
        )
    
        denominator_TM = 1 + rFresnelH[i, :] * rSlab_TM[i - 1, :] * exp_term
        rSlab_TM = rSlab_TM.at[i, :].set(
            (rFresnelH[i, :] + rSlab_TM[i - 1, :] * exp_term) / denominator_TM
        )
    
    # Calculate absolute values squared
    rSlab_TE_abs = jnp.abs(rSlab_TE[M, :]) ** 2
    rSlab_TM_abs = jnp.abs(rSlab_TM[M, :]) ** 2
    
    return rSlab_TE_abs, rSlab_TM_abs
