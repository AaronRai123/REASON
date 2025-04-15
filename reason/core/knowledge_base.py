"""
Knowledge Base module for the REASON system
Provides access to structured biological and medical knowledge
"""

import os
import logging
import json
import time

logger = logging.getLogger("REASON.KnowledgeBase")

class KnowledgeBase:
    """
    Knowledge Base for the REASON system
    Provides structured access to biological and medical knowledge
    """
    
    def __init__(self, data_dir="data"):
        """
        Initialize the knowledge base
        
        Args:
            data_dir (str): Directory containing knowledge data
        """
        self.data_dir = data_dir
        self.cache = {}
        
        # Create knowledge directories if they don't exist
        self.knowledge_dirs = [
            os.path.join(data_dir, "diseases"),
            os.path.join(data_dir, "pathways"),
            os.path.join(data_dir, "drugs"),
            os.path.join(data_dir, "targets"),
            os.path.join(data_dir, "publications")
        ]
        
        for directory in self.knowledge_dirs:
            os.makedirs(directory, exist_ok=True)
        
        logger.info("Knowledge Base initialized")
    
    def get_disease_information(self, disease_name):
        """
        Get comprehensive information about a disease
        
        Args:
            disease_name (str): Name of the disease
            
        Returns:
            dict: Disease information
        """
        cache_key = f"disease_{disease_name}"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        # Check if we have a stored file for this disease
        disease_file = os.path.join(self.data_dir, "diseases", f"{disease_name.replace(' ', '_')}.json")
        
        if os.path.exists(disease_file):
            try:
                with open(disease_file, 'r') as f:
                    disease_info = json.load(f)
                self.cache[cache_key] = disease_info
                return disease_info
            except Exception as e:
                logger.error(f"Error loading disease information: {str(e)}")
        
        # If no data file exists, create placeholder data
        logger.info(f"Creating placeholder data for disease: {disease_name}")
        disease_info = self._generate_disease_placeholder(disease_name)
        self.cache[cache_key] = disease_info
        return disease_info
    
    def _generate_disease_placeholder(self, disease_name):
        """
        Generate placeholder disease data for demonstration
        
        Args:
            disease_name (str): Name of the disease
            
        Returns:
            dict: Placeholder disease information
        """
        # Simulate processing time
        time.sleep(0.5)
        
        return {
            "name": disease_name,
            "description": f"A condition characterized by abnormal function or structure.",
            "categories": ["example_category"],
            "icd10": "X00.0",
            "symptoms": [
                {"name": "Symptom 1", "prevalence": "common"},
                {"name": "Symptom 2", "prevalence": "uncommon"},
                {"name": "Symptom 3", "prevalence": "rare"}
            ],
            "associated_genes": [
                {"id": "GENE1", "name": "Gene 1", "evidence": "strong"},
                {"id": "GENE2", "name": "Gene 2", "evidence": "moderate"},
                {"id": "GENE3", "name": "Gene 3", "evidence": "weak"}
            ],
            "prevalence": "5 in 100,000",
            "risk_factors": ["Risk factor 1", "Risk factor 2"],
            "treatments": [
                {"id": "TREATMENT1", "name": "Treatment 1", "type": "drug"},
                {"id": "TREATMENT2", "name": "Treatment 2", "type": "procedure"}
            ],
            "is_placeholder": True
        }
    
    def get_pathway_information(self, pathway_id):
        """
        Get information about a biological pathway
        
        Args:
            pathway_id (str): ID of the pathway
            
        Returns:
            dict: Pathway information
        """
        cache_key = f"pathway_{pathway_id}"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        # Generate placeholder data
        pathway_info = {
            "id": pathway_id,
            "name": f"Pathway {pathway_id}",
            "description": "Biological pathway involved in cellular function",
            "genes": ["GENE1", "GENE2", "GENE3", "GENE4"],
            "interactions": [
                {"source": "GENE1", "target": "GENE2", "type": "activation"},
                {"source": "GENE2", "target": "GENE3", "type": "inhibition"},
                {"source": "GENE3", "target": "GENE4", "type": "binding"}
            ],
            "is_placeholder": True
        }
        
        self.cache[cache_key] = pathway_info
        return pathway_info
    
    def get_drug_information(self, drug_id):
        """
        Get information about a drug
        
        Args:
            drug_id (str): ID of the drug
            
        Returns:
            dict: Drug information
        """
        cache_key = f"drug_{drug_id}"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        # Generate placeholder data
        drug_info = {
            "id": drug_id,
            "name": f"Drug {drug_id}",
            "description": "Pharmaceutical compound used for treatment",
            "mechanism": "Inhibits protein function",
            "targets": ["TARGET1", "TARGET2"],
            "indications": ["Disease 1", "Disease 2"],
            "contraindications": ["Condition 1", "Condition 2"],
            "side_effects": ["Side effect 1", "Side effect 2"],
            "is_placeholder": True
        }
        
        self.cache[cache_key] = drug_info
        return drug_info
    
    def search_literature(self, query, max_results=10):
        """
        Search scientific literature for information
        
        Args:
            query (str): Search query
            max_results (int): Maximum number of results to return
            
        Returns:
            list: Publication information
        """
        # Generate placeholder data
        publications = []
        for i in range(1, min(max_results + 1, 6)):
            publications.append({
                "id": f"PUB{i}",
                "title": f"Research on {query} - Study {i}",
                "authors": ["Author A", "Author B"],
                "journal": "Journal of Medical Research",
                "year": 2020 + i % 3,
                "abstract": f"This study investigates {query} and its effects on health.",
                "url": f"https://example.com/publication{i}",
                "is_placeholder": True
            })
        
        return publications
    
    def get_validation_data(self, disease_name):
        """
        Get validation data for a disease
        
        Args:
            disease_name (str): Name of the disease
            
        Returns:
            dict: Validation data
        """
        return {
            "known_genes": ["GENE1", "GENE2"],
            "known_pathways": ["PW1", "PW2"],
            "known_treatments": ["TREATMENT1"],
            "is_placeholder": True
        }
    
    def clear_cache(self):
        """Clear the knowledge cache"""
        self.cache = {}
        logger.debug("Knowledge cache cleared")
    
    def close(self):
        """Clean up resources"""
        self.clear_cache()
        logger.info("Knowledge Base resources released") 