project = "PicoLink Protocol"
author = "PicoLink"
copyright = "2026, PicoLink"
release = "0.1"

extensions = [
    "sphinxcontrib.mermaid",
]

mermaid_output_format = "raw"


templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "sphinx_rtd_theme"
html_static_path = ["_static"]

master_doc = "index"
language = "en"
