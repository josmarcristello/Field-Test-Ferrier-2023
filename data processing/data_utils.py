import os
import tempfile
import pandas as pd


def import_lvm_file(file_path, chunksize=100000):
    # Find the header row number
    header_row = -1
    with open(file_path, 'r') as f:
        for i, line in enumerate(f):
            if line.startswith('X_Value'):
                header_row = i
                break

    if header_row == -1:
        raise ValueError("Header row not found")
    
    # Create a temporary file
    temp_file = tempfile.NamedTemporaryFile(delete=False)
    
    # Read the original file, skip comment lines and write to temporary file
    with open(file_path, 'r') as f, open(temp_file.name, 'w') as temp_f:
        for i, line in enumerate(f):
            if i >= header_row and not line.startswith('%'):
                temp_f.write(line)

    temp_file.close()  # Ensure that the temporary file is closed

    chunks = []
    # Read the LVM file using pandas read_csv function with C engine
    for chunk in pd.read_csv(
        temp_file.name,
        sep='\t',          # LVM files use tab as a delimiter
        header=0,          # Use the first row as header
        na_values=[''],    # Missing values are represented by empty strings
        chunksize=chunksize,
    ):
        # Drop the last column (it's just NaNs because of the trailing tab)
        chunk = chunk.drop(chunk.columns[-1], axis=1)
        chunks.append(chunk)
    
    # Delete the temporary file
    os.unlink(temp_file.name)
    
    data = pd.concat(chunks, ignore_index=True)
    return data
