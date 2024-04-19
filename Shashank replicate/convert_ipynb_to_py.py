#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os
from nbconvert import NotebookExporter

def convert_notebooks_to_scripts(folder_path):
    # Iterate over all files in the folder
    for filename in os.listdir(folder_path):
        if filename.endswith('.ipynb'):
            # Path to the notebook file
            notebook_path = os.path.join(folder_path, filename)
            
            # Create an instance of NotebookExporter
            exporter = NotebookExporter()
            
            # Convert the notebook to Python script
            output, _ = exporter.from_filename(notebook_path)
            
            # Path to save the converted Python script
            python_script_path = os.path.splitext(notebook_path)[0] + '.py'
            
            # Write the converted Python script to a file
            with open(python_script_path, 'w', encoding='utf-8') as f:
                f.write(output)
            
            print(f"Converted '{filename}' to '{os.path.basename(python_script_path)}'")

# Specify the folder containing the notebooks
folder_path = 'C://Users/vickm/Downloads/shashank'

# Convert all notebooks to Python scripts within the specified folder
convert_notebooks_to_scripts(folder_path)

