Channels
========

PicoLink uses exactly two channels:

.. list-table::
   :header-rows: 1
   :widths: 15 25 60

   * - Channel
     - Direction
     - Purpose
   * - A
     - Core → CM
     - Requests, writebacks, and invalidation acknowledgments
   * - B
     - CM → Core
     - Grants, invalidations, acknowledgments, and denials

.. _a-channel-messages:

A Channel Messages (Core → CM)
------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Message Type
     - Meaning
   * - ``ReadShared``
     - Request Shared (S) permission for a cache line.
   * - ``ReadExclusive``
     - Request Exclusive (E) permission for a cache line.
   * - ``Upgrade``
     - Request S → M transition (core already holds line in S).
   * - ``WriteBack``
     - Evict a Modified (M) line: carries dirty data payload.
   * - ``InvAck``
     - Acknowledge a received ``Invalidate`` from the CM.

.. note::

   When a core in ``M`` state receives an ``Invalidate``, its ``WriteBack``
   response implicitly serves as the ``InvAck``. The CM **shall not** expect
   a separate ``InvAck`` in this case.

.. _b-channel-messages:

B Channel Messages (CM → Core)
------------------------------

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Message Type
     - Meaning
   * - ``GrantS``
     - Data + Shared permission.
   * - ``GrantE``
     - Data + Exclusive permission.
   * - ``GrantM``
     - Write permission only (no data): ``Upgrade`` response only.
   * - ``Invalidate``
     - Demand the core write back (if dirty) then go to ``I`` state.
   * - ``WriteBackAck``
     - Acknowledge the core's ``WriteBack`` (memory has committed data).
   * - ``Nack``
     - Request denied: core must retry as ``ReadExclusive``.

Grant Message Usage
-------------------

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Message
     - Carries Data?
     - Used For
   * - ``GrantS``
     - Yes
     - ``ReadShared`` response when other sharers exist.
   * - ``GrantE``
     - Yes
     - ``ReadShared`` response (no other sharers) **or**
       ``ReadExclusive`` response.
   * - ``GrantM``
     - No
     - ``Upgrade`` response only.
