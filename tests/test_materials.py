import pytest            # Import pytest to write unit tests
import jax.numpy as jnp  #
import numpy as np       # Import numpy (python library for working with arrays)
import scipy.constant as scic   # Range of mathematical and physical constants


from jaxlayerlumos import materials.json

LIST_MATERIALS = [ 
    "Mat1",
    "Mat2",
    "Mat3",
    "Mat4",
    "Mat5",
    "Mat6",
    "Mat7",
    "Mat8",
    "Mat9",
    "Mat10",
    "Mat11",
    "Mat12",
    "Mat13",
    "Mat14",
    "Mat15",
    "Mat16"
]

def test_load_json():    # Validates loading material indices from a JSON file returns a dictionary and its length matches number of materials listed
    material_indices, str_directory = utils_materials.load_json()
    assert isinstance(material_indices, dict)
    assert len(material_indices) == len(LIST_MATERIALS)


def test_return_materials():   # Checks the function returns a list of materials that exactly matches LIST_MATERIALS.
    all_materials = utils_materials.get_all_materials()
    assert len(all_materials) == len(LIST_MATERIALS)
    for material in all_materials:
        assert material in LIST_MATERIALS
    for material in LIST_MATERIALS:
        assert material in all_materials

def test_load_material_success():   # Tests the successful loading of each material in LIST_MATERIALS. It asserts that returned data are JAX arrays with correct dimensions and shapes
    for material in LIST_MATERIALS:
        data_n, data_k = utils_materials.load_material(material)
        assert isinstance(data_n, jnp.ndarray)
        assert isinstance(data_k, jnp.ndarray)
        assert data_n.ndim == 2         # WHAT SHOULD THESE VALUES BE
        assert data_k.ndim == 2
        assert data_n.shape[0] > 0
        assert data_k.shape[0] > 0
        assert data_n.shape[1] == 2
        assert data_k.shape[1] == 2
