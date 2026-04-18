Race Conditions, Ordering & Atomicity
=====================================

Message Ordering
----------------

* **Per-channel, per-source FIFO ordering** is guaranteed.
* **No per-address ordering** across channels.
* Cores may have multiple outstanding requests (``txn_id`` distinguishes them).

Dual Upgrade Race
-----------------

If two cores that are both in ``S`` send ``Upgrade`` simultaneously for the
same line, the CM resolves the race by **core index (lower index wins)**. The
denied core receives a ``Nack`` and must retry with ``ReadExclusive``.

ReadShared vs Upgrade Race
--------------------------

If Core 0 sends ``Upgrade`` and Core 1 sends ``ReadShared`` for the same line
simultaneously, the CM processes **Core 0's Upgrade first** (as it already
holds the line). Core 0's Upgrade invalidates Core 1's pending read. Core 1's
``ReadShared`` is processed afterwards, resulting in a fresh fetch from
memory.

Invalidate Crosses with Upgrade
-------------------------------

A core has a line in ``S`` and sends ``Upgrade``. Simultaneously, the CM
sends ``Invalidate`` for that line (due to another core's request). The core
receives the ``Invalidate`` and transitions to ``I``, but its ``Upgrade`` is
still in flight. The CM then receives an ``Upgrade`` for a line the core no
longer owns.

**Resolution:** if a core receives an ``Invalidate`` for a line with a
pending ``Upgrade``, it must treat the ``Upgrade`` as failed. The CM will
``Nack`` the stale ``Upgrade``. The core must reissue the request as
``ReadExclusive``.
