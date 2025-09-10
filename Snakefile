import glob
import os

# Directories
HEAVY_DIR = "/mnt/speedy/achavan/Fab_project/predict_all_complex_2025_08_19/heavy"
LIGHT_DIR = "/mnt/speedy/achavan/Fab_project/predict_all_complex_2025_08_19/light"
PDB_DIR = "/mnt/speedy/achavan/Fab_project/relax_all_mutants_2025_09_10/pdbs"

# Find all main CIFs (ignore seed subfolders)
def find_main_cifs(base_dir):
    pattern = os.path.join(base_dir, "*/output/*/*_model.cif")
    return glob.glob(pattern)

heavy_cifs = find_main_cifs(HEAVY_DIR)
light_cifs = find_main_cifs(LIGHT_DIR)

# Function to map CIF -> output PDB in OUTPUT_DIR
def make_pdb_targets(cif_files, suffix):
    return [os.path.join(PDB_DIR, os.path.basename(cif).replace("_model.cif", f"_{suffix}.pdb"))
            for cif in cif_files]

heavy_pdbs = make_pdb_targets(heavy_cifs, "heavy")
light_pdbs = make_pdb_targets(light_cifs, "light")

all_cifs = [(c, "heavy") for c in heavy_cifs] + [(c, "light") for c in light_cifs]

def name_for(cif, suffix):
    return os.path.basename(cif).replace("_model.cif", f"_{suffix}")

cif_map = {name_for(c, s): c for c, s in all_cifs}

rule all:
    input:
        expand(f"{PDB_DIR}/{{name}}.pdb", name=cif_map.keys())

rule convert:
    input:
        cif=lambda wc: cif_map[wc.name]
    output:
        pdb=f"{PDB_DIR}/{{name}}.pdb"
    shell:
        """
        mkdir -p "$(dirname {output.pdb})"
        pymol -cq -d "load {input.cif}; save {output.pdb}; quit"
        """



