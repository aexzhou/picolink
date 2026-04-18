Coherency Manager (CM) Behavior
===============================

Directory State
---------------

The CM maintains a directory entry for each cache line that is present in any
core's L1 cache. Each entry tracks:

* **Sharer bitmask**: which cores hold a copy of the line.
* **State**: the coherence state from the CM's perspective (``I``, ``S``,
  ``E``, or ``M``).
* **Owner**: the core ID of the exclusive/modified owner (if applicable).

CM Response Logic
-----------------

.. list-table::
   :header-rows: 1
   :widths: 20 25 55

   * - Incoming Request
     - Directory State
     - CM Action
   * - ``ReadShared``
     - No sharers (``I``)
     - Fetch from memory, respond ``GrantE``.
   * - ``ReadShared``
     - Other sharers exist (``S``)
     - Fetch from memory, respond ``GrantS``, add requester to sharers.
   * - ``ReadShared``
     - Another core has ``E``
     - Send ``Invalidate`` to ``E`` holder, wait for ``InvAck``, fetch from
       memory, respond ``GrantS`` (or ``GrantE`` if now the sole copy).
   * - ``ReadShared``
     - Another core has ``M``
     - Send ``Invalidate`` to ``M`` holder, wait for ``WriteBack``, commit to
       memory, respond ``GrantS`` to requester.
   * - ``ReadExclusive``
     - No sharers (``I``)
     - Fetch from memory, respond ``GrantE``.
   * - ``ReadExclusive``
     - Other sharers exist (``S``)
     - Send ``Invalidate`` to all sharers, wait for all ``InvAcks``, fetch
       from memory, respond ``GrantE``.
   * - ``ReadExclusive``
     - Another core has ``E``
     - Send ``Invalidate`` to ``E`` holder, wait for ``InvAck``, fetch from
       memory, respond ``GrantE``.
   * - ``ReadExclusive``
     - Another core has ``M``
     - Send ``Invalidate`` to ``M`` holder, wait for ``WriteBack``, commit
       to memory, respond ``GrantE``.
   * - ``Upgrade``
     - Requester is sole sharer
     - Respond ``GrantM`` immediately.
   * - ``Upgrade``
     - Other sharers exist
     - Send ``Invalidate`` to other sharers, wait for all ``InvAcks``,
       respond ``GrantM``.
   * - ``WriteBack``
     - Core is ``M`` owner
     - Commit data to memory, respond ``WriteBackAck``, remove core from
       directory.
