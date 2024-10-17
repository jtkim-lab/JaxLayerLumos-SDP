import unittest

material_paths = {   # Dictionary named material_paths is defined, mapping material names ("Mat1", "Mat2", ...) to corresponding CSV file paths
    "Mat1": "materialsRAM/Mat1-Michielssen-20.csv",
    "Mat2": "materialsRAM/Mat2-Michielssen-20.csv",
    "Mat3": "materialsRAM/Mat3-Michielssen-20.csv",
    "Mat4": "materialsRAM/Mat4-Michielssen-20.csv",
    "Mat5": "materialsRAM/Mat5-Michielssen-20.csv",
    "Mat6": "materialsRAM/Mat6-Michielssen-20.csv",
    "Mat7": "materialsRAM/Mat7-Michielssen-20.csv",
    "Mat8": "materialsRAM/Mat8-Michielssen-20.csv",
    "Mat9": "materialsRAM/Mat9-Michielssen-20.csv",
    "Mat10": "materialsRAM/Mat10-Michielssen-20.csv",
    "Mat11": "materialsRAM/Mat11-Michielssen-20.csv",
    "Mat12": "materialsRAM/Mat12-Michielssen-20.csv",
    "Mat13": "materialsRAM/Mat13-Michielssen-20.csv",
    "Mat14": "materialsRAM/Mat14-Michielssen-20.csv",
    "Mat15": "materialsRAM/Mat15-Michielssen-20.csv",
    "Mat16": "materialsRAM/Mat16-Michielssen-20.csv"
}

class TestMaterialPaths(unittest.TestCase):   # Subclass of unittest.TestCase that contains test methods to validate contents and correctness of material_paths dictionary

    def test_material_exists(self):     # Test that specific materials exist in the dictionary
        self.assertIn("Mat1", material_paths)
        self.assertIn("Mat2", material_paths)
        self.assertIn("Mat3", material_paths)
        self.assertIn("Mat4", material_paths)
        self.assertIn("Mat5", material_paths)
        self.assertIn("Mat6", material_paths)
        self.assertIn("Mat7", material_paths)
        self.assertIn("Mat8", material_paths)
        self.assertIn("Mat9", material_paths)
        self.assertIn("Mat10", material_paths)
        self.assertIn("Mat11", material_paths)
        self.assertIn("Mat12", material_paths)
        self.assertIn("Mat13", material_paths)
        self.assertIn("Mat14", material_paths)
        self.assertIn("Mat15", material_paths)
        self.assertIn("Mat16", material_paths)

    def test_material_path_correctness(self):   # Test that specific materials have the correct paths
        self.assertEqual(material_paths["Mat1"], "materialsRAM/Mat1-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat2"], "materialsRAM/Mat2-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat3"], "materialsRAM/Mat3-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat4"], "materialsRAM/Mat4-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat5"], "materialsRAM/Mat5-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat6"], "materialsRAM/Mat6-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat7"], "materialsRAM/Mat7-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat8"], "materialsRAM/Mat8-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat9"], "materialsRAM/Mat9-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat10"], "materialsRAM/Mat10-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat11"], "materialsRAM/Mat11-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat12"], "materialsRAM/Mat12-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat13"], "materialsRAM/Mat13-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat14"], "materialsRAM/Mat14-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat15"], "materialsRAM/Mat15-Michielssen-20.csv")
        self.assertEqual(material_paths["Mat16"], "materialsRAM/Mat16-Michielssen-20.csv")

    def test_non_existent_material(self):   # Test that a non-existent material returns an appropriate response
        self.assertNotIn("NonExistentMaterial", material_paths)

    def test_material_count(self):     # Test that the total number of materials is as expected
        self.assertEqual(len(material_paths), 16)  # Adjust count based on the provided data

if __name__ == '__main__':
    unittest.main()