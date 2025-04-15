#!/bin/bash
# REASON: Rational Empirical Analysis and Scientific Observation Network
# Dependency installation script

set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "Detected macOS system"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "Detected Linux system"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
    echo "Detected Windows system"
else
    OS="unknown"
    echo "Unknown operating system: $OSTYPE"
    echo "The script will try to continue, but may fail."
fi

# Check for Python
echo "Checking for Python 3..."
if command -v python3 &>/dev/null; then
    PYTHON="python3"
elif command -v python &>/dev/null; then
    PYTHON="python"
    # Check if it's Python 3
    PY_VERSION=$($PYTHON --version 2>&1)
    if [[ $PY_VERSION != *"Python 3"* ]]; then
        echo "Python 3 is required but not found. Please install Python 3."
        exit 1
    fi
else
    echo "Python 3 not found. Please install Python 3."
    exit 1
fi

echo "Using $PYTHON: $($PYTHON --version)"

# Create virtual environment
echo "Creating virtual environment..."
$PYTHON -m venv reason_env

# Activate virtual environment
echo "Activating virtual environment..."
if [[ "$OS" == "windows" ]]; then
    source reason_env/Scripts/activate
else
    source reason_env/bin/activate
fi

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install core requirements
echo "Installing core dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Core Python dependencies installed successfully."

# Create required directories
echo "Creating necessary directories..."
mkdir -p data/diseases data/pathways data/drugs data/targets data/publications
mkdir -p models
mkdir -p results

echo "Installation complete."
echo ""
echo "To activate the environment and use REASON, run:"
echo "  source reason_env/bin/activate  # On Linux/macOS"
echo "  reason_env\\Scripts\\activate     # On Windows"
echo ""
echo "Then run the REASON system with:"
echo "  python run_real_reason.py --disease \"Disease name\""

# OS-specific installations
if [[ "$OS" == "macos" ]]; then
    echo "MacOS detected. Installing system-level dependencies..."
    
    # Install Homebrew if not already installed
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Install OpenBabel
    echo "Installing OpenBabel..."
    brew install open-babel
    
    # Install other system dependencies
    brew install rdkit

    # Install pymol
    brew install pymol
    
    # Install autodock-vina
    if ! command -v vina &>/dev/null; then
        echo "Installing AutoDock Vina..."
        if brew list --versions autodock-vina >/dev/null; then
            brew upgrade autodock-vina
        else
            # The homebrew formula might have changed, try different options
            if brew search autodock-vina | grep -q "autodock-vina"; then
                brew install autodock-vina
            else
                # If not found in homebrew, try to install from source
                echo "AutoDock Vina not found in Homebrew. Installing from source..."
                mkdir -p ~/tmp
                cd ~/tmp
                curl -O https://vina.scripps.edu/wp-content/uploads/sites/55/2020/12/autodock_vina_1_1_2_mac_64bit.tar.gz
                tar -xzf autodock_vina_1_1_2_mac_64bit.tar.gz
                sudo cp autodock_vina_1_1_2_mac_64bit/bin/vina /usr/local/bin/
                echo "Added vina to /usr/local/bin/"
                cd - > /dev/null
            fi
        fi
    else
        echo "✓ AutoDock Vina already installed"
    fi
    
elif [[ "$OS" == "linux" ]]; then
    echo "Linux detected. Installing system-level dependencies..."
    
    # For Ubuntu/Debian
    if command -v apt &>/dev/null; then
        echo "Ubuntu/Debian detected."
        sudo apt-get update
        
        # Install OpenBabel
        sudo apt-get install -y libopenbabel-dev openbabel
        
        # Install RDKit
        sudo apt-get install -y librdkit1 rdkit-data python3-rdkit
        
        # Install PyMol
        sudo apt-get install -y pymol
        
        # Install autodock-vina
        if ! command -v vina &>/dev/null; then
            echo "Installing AutoDock Vina..."
            if apt-cache search autodock-vina | grep -q autodock-vina; then
                sudo apt-get install -y autodock-vina
            else
                # Manual installation if not in repositories
                echo "AutoDock Vina not found in repositories. Installing from source..."
                mkdir -p ~/tmp
                cd ~/tmp
                # Determine architecture
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    curl -O https://vina.scripps.edu/wp-content/uploads/sites/55/2020/12/autodock_vina_1_1_2_linux_x86.tar.gz
                    tar -xzf autodock_vina_1_1_2_linux_x86.tar.gz
                    sudo cp autodock_vina_1_1_2_linux_x86/bin/vina /usr/local/bin/
                else
                    echo "Warning: Architecture $ARCH not supported for pre-built AutoDock Vina. You may need to compile it from source."
                fi
                echo "Added vina to /usr/local/bin/"
                cd - > /dev/null
            fi
        else
            echo "✓ AutoDock Vina already installed"
        fi
        
    # For Fedora/RHEL/CentOS
    elif command -v dnf &>/dev/null; then
        echo "Fedora/RHEL/CentOS detected."
        sudo dnf update
        
        # Install OpenBabel
        sudo dnf install -y openbabel openbabel-devel
        
        # Install PyMol
        sudo dnf install -y pymol
        
        # Install autodock-vina 
        if ! command -v vina &>/dev/null; then
            echo "Installing AutoDock Vina..."
            if dnf search autodock-vina 2>/dev/null | grep -q autodock-vina; then
                sudo dnf install -y autodock-vina
            else
                # Try from EPEL repository
                sudo dnf install -y epel-release
                if dnf search autodock-vina 2>/dev/null | grep -q autodock-vina; then
                    sudo dnf install -y autodock-vina
                else
                    # Manual installation
                    echo "AutoDock Vina not found in repositories. Installing from source..."
                    mkdir -p ~/tmp
                    cd ~/tmp
                    # Determine architecture
                    ARCH=$(uname -m)
                    if [[ "$ARCH" == "x86_64" ]]; then
                        curl -O https://vina.scripps.edu/wp-content/uploads/sites/55/2020/12/autodock_vina_1_1_2_linux_x86.tar.gz
                        tar -xzf autodock_vina_1_1_2_linux_x86.tar.gz
                        sudo cp autodock_vina_1_1_2_linux_x86/bin/vina /usr/local/bin/
                    else
                        echo "Warning: Architecture $ARCH not supported for pre-built AutoDock Vina. You may need to compile it from source."
                    fi
                    echo "Added vina to /usr/local/bin/"
                    cd - > /dev/null
                fi
            fi
        else
            echo "✓ AutoDock Vina already installed"
        fi
        
    elif command -v yum &>/dev/null; then
        echo "RHEL/CentOS detected."
        sudo yum update
        
        # Install OpenBabel
        sudo yum install -y openbabel openbabel-devel
        
        # Install PyMol
        sudo yum install -y pymol
        
        # Try to install AutoDock Vina
        if ! command -v vina &>/dev/null; then
            echo "Installing AutoDock Vina..."
            # Try EPEL
            sudo yum install -y epel-release
            if yum search autodock-vina 2>/dev/null | grep -q autodock-vina; then
                sudo yum install -y autodock-vina
            else
                echo "AutoDock Vina not found in repositories. Installing from source..."
                mkdir -p ~/tmp
                cd ~/tmp
                # Determine architecture
                ARCH=$(uname -m)
                if [[ "$ARCH" == "x86_64" ]]; then
                    curl -O https://vina.scripps.edu/wp-content/uploads/sites/55/2020/12/autodock_vina_1_1_2_linux_x86.tar.gz
                    tar -xzf autodock_vina_1_1_2_linux_x86.tar.gz
                    sudo cp autodock_vina_1_1_2_linux_x86/bin/vina /usr/local/bin/
                else
                    echo "Warning: Architecture $ARCH not supported for pre-built AutoDock Vina. You may need to compile it from source."
                fi
                echo "Added vina to /usr/local/bin/"
                cd - > /dev/null
            fi
        else
            echo "✓ AutoDock Vina already installed"
        fi
    fi
    
elif [[ "$OS" == "windows" ]]; then
    echo "Windows detected. Some dependencies need manual installation."
    echo "Please follow these steps manually:"
    echo ""
    echo "1. Install OpenBabel:"
    echo "   a. Download the installer from https://github.com/openbabel/openbabel/releases/latest"
    echo "   b. Run the installer and follow the instructions"
    echo "   c. Add the OpenBabel bin directory to your PATH (usually C:\\Program Files\\OpenBabel\\bin)"
    echo ""
    echo "2. Install PyMOL:"
    echo "   a. Download the installer from https://pymol.org/2/"
    echo "   b. Run the installer and follow the instructions"
    echo ""
    echo "3. Install AutoDock Vina:"
    echo "   a. Download the Windows version from https://vina.scripps.edu/downloads/"
    echo "   b. Extract the ZIP file to a folder (e.g., C:\\Program Files\\AutoDock Vina)"
    echo "   c. Add the folder containing vina.exe to your PATH"
    echo "   d. Verify installation by opening a new command prompt and typing 'vina --help'"
    echo ""
    echo "4. For RDKit and other Python packages:"
    echo "   a. We recommend using Anaconda for Windows to manage Python environments"
    echo "   b. After installing Anaconda, create a new environment:"
    echo "      conda create -n reason_env python=3.9"
    echo "   c. Activate the environment:"
    echo "      conda activate reason_env"
    echo "   d. Install RDKit via conda:"
    echo "      conda install -c conda-forge rdkit"
    echo "   e. Then install other Python dependencies using pip:"
    echo "      pip install -r requirements.txt"
    echo ""
    echo "After completing these steps, restart your command prompt and verify that"
    echo "all commands (openbabel, vina, python) are accessible."
    echo ""
fi

# Install Python bindings for external tools
echo "Installing Python bindings for external tools..."

# Install OpenBabel Python bindings
$PYTHON -m pip install openbabel

# Install other scientific libraries
$PYTHON -m pip install mdtraj openmm pdbfixer

# Try to install moleculekit
$PYTHON -m pip install moleculekit

# Install DeepChem and related libraries
$PYTHON -m pip install deepchem

# Install systems biology libraries
$PYTHON -m pip install tellurium cobra

# Install API clients
$PYTHON -m pip install pubchempy chembl_webresource_client

# Install machine learning libraries
$PYTHON -m pip install torch tensorflow scikit-learn

# Install visualization libraries
$PYTHON -m pip install seaborn plotly

echo ""
echo "Installation complete!"
echo ""
echo "To start using the REASON system with all dependencies, activate the virtual environment:"
echo "source reason_env/bin/activate  # On macOS/Linux"
echo "reason_env\\Scripts\\activate  # On Windows"
echo ""
echo "Then run REASON with:"
echo "python run_real_reason.py --disease \"Disease name\"" 