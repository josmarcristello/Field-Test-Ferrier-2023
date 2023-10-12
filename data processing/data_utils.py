import os
import tempfile
import pandas as pd
import matplotlib.pyplot as plt

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

import matplotlib.pyplot as plt

def plot_data(data_frame, column_names=["CH5"], start_time=None, end_time=None, transparency=1,
              title=None, xlabel='Time [s]', ylabel='Value [V]', figsize=None):
    # If no column names provided, default to an empty list.
    if not column_names:
        column_names = []

    # If only a single column name is provided, wrap it in a list.
    if isinstance(column_names, str):
        column_names = [column_names]

    # Default to using all data if start_time or end_time isn't specified.
    if start_time is None:
        start_time = data_frame['time'].min()
    if end_time is None:
        end_time = data_frame['time'].max()

    # Filter data_frame based on the provided start and end times.
    mask = (data_frame['time'] >= start_time) & (data_frame['time'] <= end_time)
    filtered_data = data_frame.loc[mask, column_names]

    # Create a wide plot if figsize is specified, else use default size.
    if figsize is not None:
        plt.figure(figsize=figsize)

    # Plot the columns with time_values as the x-axis
    for column in filtered_data.columns:
        plt.plot(data_frame.loc[mask, 'time'], filtered_data[column], label=column, alpha=transparency)

    # Customize the plot
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    if title:
        plt.title(title)
    plt.legend(filtered_data.columns, loc='best')

    # Set x-axis limits
    plt.xlim(start_time, end_time)

    # Show the plot
    plt.show()
