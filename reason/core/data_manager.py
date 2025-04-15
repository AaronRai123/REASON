"""
Data Manager module for the REASON system
Handles loading, processing, and managing various types of data
"""

import os
import logging
import json

logger = logging.getLogger("REASON.DataManager")

class DataManager:
    """
    Manages data loading and processing for the REASON system
    """
    
    def __init__(self, data_dir="data"):
        """
        Initialize the data manager
        
        Args:
            data_dir (str): Directory containing the data files
        """
        self.data_dir = data_dir
        self.cache = {}
        logger.info(f"DataManager initialized with data directory: {data_dir}")
    
    def get_data_path(self, data_type, dataset_name=None):
        """
        Get the path to a specific data file or directory
        
        Args:
            data_type (str): Type of data (e.g., 'gene_expression', 'proteomics')
            dataset_name (str, optional): Specific dataset name
            
        Returns:
            str: Path to the data file or directory
        """
        base_path = os.path.join(self.data_dir, data_type)
        if dataset_name:
            return os.path.join(base_path, f"{dataset_name}.json")
        return base_path
    
    def load_dataset(self, data_type, disease=None, use_cache=True):
        """
        Load a dataset for a specific disease and data type
        
        Args:
            data_type (str): Type of data to load
            disease (str, optional): Disease name to filter data
            use_cache (bool, optional): Whether to use cached data
            
        Returns:
            dict: The loaded dataset
        """
        cache_key = f"{data_type}_{disease}" if disease else data_type
        
        if use_cache and cache_key in self.cache:
            logger.debug(f"Using cached data for {cache_key}")
            return self.cache[cache_key]
        
        data_path = self.get_data_path(data_type, disease)
        
        if os.path.exists(data_path):
            try:
                logger.info(f"Loading data from {data_path}")
                with open(data_path, 'r') as f:
                    data = json.load(f)
                
                if use_cache:
                    self.cache[cache_key] = data
                
                return data
            except Exception as e:
                logger.error(f"Error loading data from {data_path}: {str(e)}")
                return {"error": str(e)}
        else:
            logger.warning(f"Data file not found: {data_path}")
            # Return placeholder data for demonstration
            placeholder_data = self._generate_placeholder_data(data_type, disease)
            if use_cache:
                self.cache[cache_key] = placeholder_data
            return placeholder_data
    
    def _generate_placeholder_data(self, data_type, disease=None):
        """
        Generate placeholder data for demonstration purposes
        
        Args:
            data_type (str): Type of data to generate
            disease (str, optional): Disease name to customize data
            
        Returns:
            dict: Placeholder data
        """
        if data_type == "gene_expression":
            return {
                "type": "gene_expression",
                "disease": disease,
                "genes": ["GENE1", "GENE2", "GENE3"],
                "values": [1.2, -0.8, 2.5],
                "is_placeholder": True
            }
        elif data_type == "proteomics":
            return {
                "type": "proteomics",
                "disease": disease,
                "proteins": ["PROT1", "PROT2", "PROT3"],
                "values": [0.9, 1.5, -1.1],
                "is_placeholder": True
            }
        elif data_type == "pathways":
            return {
                "type": "pathways",
                "disease": disease,
                "pathways": [
                    {"id": "PW1", "name": "Inflammatory Response", "genes": ["GENE1", "GENE2"]},
                    {"id": "PW2", "name": "Cell Cycle", "genes": ["GENE3", "GENE4"]},
                    {"id": "PW3", "name": "Apoptosis", "genes": ["GENE2", "GENE5"]}
                ],
                "is_placeholder": True
            }
        else:
            return {
                "type": data_type,
                "disease": disease,
                "note": "Placeholder data",
                "is_placeholder": True
            }
    
    def save_dataset(self, data, data_type, dataset_name):
        """
        Save dataset to a file
        
        Args:
            data (dict): Data to save
            data_type (str): Type of data
            dataset_name (str): Name of the dataset
            
        Returns:
            bool: True if saved successfully, False otherwise
        """
        data_path = self.get_data_path(data_type, dataset_name)
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(data_path), exist_ok=True)
        
        try:
            with open(data_path, 'w') as f:
                json.dump(data, f, indent=2)
            logger.info(f"Data saved to {data_path}")
            return True
        except Exception as e:
            logger.error(f"Error saving data to {data_path}: {str(e)}")
            return False
    
    def clear_cache(self):
        """Clear the data cache"""
        self.cache = {}
        logger.debug("Data cache cleared")
    
    def close(self):
        """Clean up resources"""
        self.clear_cache()
        logger.info("DataManager resources released") 