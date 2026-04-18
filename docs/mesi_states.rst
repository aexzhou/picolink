MESI State Transitions
======================

Transition Table
----------------

.. list-table::
   :header-rows: 1
   :widths: 15 25 40 20

   * - Current State
     - Event
     - Resulting Action
     - Next State
   * - ``I``
     - CPU Read
     - Send ``ReadShared``
     - ``S`` (or ``E`` if no other sharers)
   * - ``I``
     - CPU Write
     - Send ``ReadExclusive``
     - ``E`` (then silent ``E → M`` on write)
   * - ``S``
     - CPU Read
     - (Cache hit, no action)
     - ``S``
   * - ``S``
     - CPU Write
     - Send ``Upgrade``
     - ``M``
   * - ``E``
     - CPU Read
     - (Cache hit, no action)
     - ``E``
   * - ``E``
     - CPU Write
     - (Silent transition)
     - ``M``
   * - ``M``
     - CPU Read
     - (Cache hit, no action)
     - ``M``
   * - ``M``
     - CPU Write
     - (Cache hit, no action)
     - ``M``
   * - ``M``
     - Eviction
     - Send ``WriteBack`` (dirty data)
     - ``I``
   * - ``S``
     - Eviction
     - (Silent drop, no ``WriteBack`` needed)
     - ``I``
   * - ``E``
     - Eviction
     - (Silent drop, no ``WriteBack`` needed)
     - ``I``
   * - ``S``
     - ``Invalidate`` (from CM)
     - Send ``InvAck``, drop line
     - ``I``
   * - ``E``
     - ``Invalidate`` (from CM)
     - Send ``InvAck``, drop line
     - ``I``
   * - ``M``
     - ``Invalidate`` (from CM)
     - Send ``WriteBack`` (implicit ``InvAck``), drop line
     - ``I``
