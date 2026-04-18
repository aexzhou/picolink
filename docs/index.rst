PicoLink Protocol Specification
===============================

PicoLink is a simplified cache-coherency protocol based on TileLink, using the
MESI coherence model and a two-channel (A / B) directory-based topology with
no Probes and no Release.

This documentation is the authoritative specification for the PicoLink
verification IP.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   introduction
   channels
   message_fields
   mesi_states
   coherency_manager
   races_ordering
   sequence_diagrams
   glossary

Indices
-------

* :ref:`genindex`
* :ref:`search`
