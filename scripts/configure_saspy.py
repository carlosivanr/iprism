# Configure SASPy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Carlos Rodriguez PhD. CU Dept of Family Medicine

# Configures SASPY to work with a local instantiation of SAS

# Configure SASPy Only needs to occur once for each configuration type and for
# each virtual environment
# Instructions are for Positron IDE
# END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Install SASPy ---------------------------------------------------------------
# Open Terminal tab
# Activate Virtual Environment, where venv is you virtual environment name
# - .\venv\Scripts\Activate.ps1
# Install saspy
# - pip install saspy
# Deactivate virtual environment
# - deactivate

# Check if venv is registered in powershell -----------------------------------
# Required for rendering quarto documents that specify a virtual environment
# Check if the virtual environment is available/registered
# - jupyter kernelspec list
# If not registered, execute the following command
# - python -m ipykernel install --user --name=venv --display-name="venv"

# Configure SASPy -------------------------------------------------------------
# Start a python CONSOLE
from saspy import autocfg

# Create a template personal cfg file that is used to configure SAS sessions
# This creates a file, the path will be listed upon execution. This file will
# need to be modified.
autocfg.main() 

# Navigate to the displayed directory and open the sascfg_personal.py file.
# Then set path to java in sascfg_personal.py so that "java" gets replaced with
# the path to java.exe
# The configuration should look something like this.
# autogen_winlocal = {
# 	"java"      : "C:\\Program Files (x86)\\Java\\jre1.8.0_431\\bin\\java.exe",
# 	"encoding"  : "windows-1252"}

# Check that SASPy can instantiate a session
import saspy

sas = saspy.SASsession(cfgname = 'autogen_winlocal')

# If it works great! If not, then there's another issue to sort out.
# -----------------------------------------------------------------------------
