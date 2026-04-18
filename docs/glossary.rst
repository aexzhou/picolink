Glossary
========

.. glossary::

   CM
     Coherency Manager: central directory-based controller that tracks
     cache-line ownership and sharing.

   MESI
     Cache coherence protocol with four states: Modified, Exclusive,
     Shared, Invalid.

   M (Modified)
     Line is dirty (written to) and owned exclusively by this core.
     The only valid copy in the system.

   E (Exclusive)
     Line is clean and owned exclusively by this core. Memory also has
     a valid copy.

   S (Shared)
     Line is clean and may be held by multiple cores. Memory also has
     a valid copy.

   I (Invalid)
     Line is not present in this core's cache or has been invalidated.

   Silent transition
     A state change that occurs locally in the core without any message
     on the bus (e.g. ``E → M`` on write).

   Implicit InvAck
     When a core in ``M`` receives ``Invalidate``, its ``WriteBack``
     response serves as both data transfer and acknowledgment.

   Nack
     Negative acknowledgment: the CM denies a request due to a race
     condition; the core must retry.

   txn_id
     Transaction identifier: disambiguates multiple outstanding
     requests from the same core.

   Directory
     CM-maintained data structure mapping each cache-line address to its
     sharers and coherence state.
