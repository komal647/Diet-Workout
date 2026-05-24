import os
import sys

# Ensure the root directory containing app.py and antigravity.py is in the Python load path
root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.append(root_dir)

# Import the AntiGravity WSGI app instance
from app import app
