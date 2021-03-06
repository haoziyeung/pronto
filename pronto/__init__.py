# coding: utf-8
"""
a Python frontend to ontologies
"""
from __future__ import absolute_import
from __future__ import unicode_literals

__version__ = 'dev'
__author__ = 'Martin Larralde'
__author_email__ = 'martin.larralde@ens-cachan.fr'
__all__ = list(map(str, [
    "Ontology", "Term", "TermList", "Relationship", "Synonym", "SynonymType"
]))

from .ontology import Ontology
from .term import Term, TermList
from .relationship import Relationship
from .synonym import Synonym, SynonymType

# Dynamically get the version of the installed module
try:
    import pkg_resources
    __version__ = pkg_resources.get_distribution(__name__).version
except Exception:
    pkg_resources = None
finally:
    del pkg_resources
