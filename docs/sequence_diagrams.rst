Message Sequence Diagrams
=========================

The following scenarios illustrate canonical PicoLink transactions. Requests
and commands use solid arrows (``->>``); data responses and acknowledgments
use dashed arrows (``-->>``).

Simple Read Miss: No Other Sharers
-----------------------------------

Core 0 reads an address not in any cache. CM grants ``Exclusive`` since
there are no other sharers.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant CM
       participant Memory

       Core0->>CM: ReadShared [addr=X, txn=1]
       CM->>Memory: Fetch addr X
       Memory-->>CM: Data for X
       CM-->>Core0: GrantE [addr=X, txn=1, data=...]

**Result:** Core 0 goes ``I → E``. CM directory: ``owner=Core0``,
``state=E``.

Read Miss: Shared Copy Exists
------------------------------

Core 1 reads address ``X`` while Core 0 already has it in ``S``.

.. mermaid::

   sequenceDiagram
       participant Core1
       participant CM
       participant Memory

       Core1->>CM: ReadShared [addr=X, txn=5]
       CM->>Memory: Fetch addr X
       Memory-->>CM: Data for X
       CM-->>Core1: GrantS [addr=X, txn=5, data=...]

**Result:** Core 1 goes ``I → S``. Core 0 stays in ``S``. CM directory:
``sharers={Core0, Core1}``, ``state=S``.

Read Miss: Another Core Has Line in E
--------------------------------------

Core 1 reads address ``X``. Core 0 has it in ``E``. CM invalidates Core 0
(no downgrade message exists in PicoLink).

.. mermaid::

   sequenceDiagram
       participant Core0
       participant Core1
       participant CM
       participant Memory

       Core1->>CM: ReadShared [addr=X, txn=6]
       CM->>Core0: Invalidate [addr=X, txn=20]
       Core0-->>CM: InvAck [addr=X, txn=20]
       CM->>Memory: Fetch addr X
       Memory-->>CM: Data for X
       CM-->>Core1: GrantE [addr=X, txn=6, data=...]

**Result:** Core 0 goes ``E → I``. Core 1 goes ``I → E`` (now sole copy).
CM directory: ``owner=Core1``, ``state=E``.

Write Miss: Line Not in Any Cache
----------------------------------

Core 0 writes to an address not in any cache.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant CM
       participant Memory

       Core0->>CM: ReadExclusive [addr=X, txn=2]
       CM->>Memory: Fetch addr X
       Memory-->>CM: Data for X
       CM-->>Core0: GrantE [addr=X, txn=2, data=...]
       Note over Core0: Writes to line<br/>(silent E → M transition)

**Result:** Core 0 goes ``I → E → M`` (silent). CM directory:
``owner=Core0``, ``state=E`` (CM is unaware of the silent ``E → M``; this is
safe since Core 0 has exclusive access).

Write Hit on Shared Line: Upgrade
----------------------------------

Core 0 has line in ``S`` and wants to write. Core 1 also has it in ``S``.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant Core1
       participant CM

       Core0->>CM: Upgrade [addr=X, txn=3]
       CM->>Core1: Invalidate [addr=X, txn=21]
       Core1-->>CM: InvAck [addr=X, txn=21]
       CM-->>Core0: GrantM [addr=X, txn=3, no data]

**Result:** Core 0 goes ``S → M``. Core 1 goes ``S → I``. CM directory:
``owner=Core0``, ``state=M``.

.. note::

   The CM waits for **all** ``InvAcks`` before sending ``GrantM``.

Read While Another Core is Modified: Forced WriteBack
------------------------------------------------------

Core 1 reads address ``X``. Core 0 has it in ``M`` (dirty). CM forces Core 0
to write back and invalidate.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant Core1
       participant CM
       participant Memory

       Core1->>CM: ReadShared [addr=X, txn=7]
       CM->>Core0: Invalidate [addr=X, txn=30]
       Core0-->>CM: WriteBack [addr=X, txn=30, data=dirty_line]
       Note over Core0,CM: WriteBack serves as implicit InvAck
       CM-->>Core0: WriteBackAck [addr=X, txn=30]
       CM->>Memory: Write dirty data
       CM->>Memory: Fetch addr X (now clean)
       Memory-->>CM: Data for X
       CM-->>Core1: GrantS [addr=X, txn=7, data=...]

**Result:** Core 0 goes ``M → I`` (forced writeback + invalidate).
Core 1 goes ``I → S``. CM directory: ``sharers={Core1}``, ``state=S``.

Voluntary WriteBack: Cache Eviction
------------------------------------

Core 0 needs to evict a dirty line to make room in its cache.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant CM
       participant Memory

       Core0->>CM: WriteBack [addr=X, txn=4, data=dirty_line]
       CM->>Memory: Write dirty data
       CM-->>Core0: WriteBackAck [addr=X, txn=4]

**Result:** Core 0 goes ``M → I``. CM directory: remove Core 0,
``state=I``.

Race Condition: Dual Upgrade
-----------------------------

Both Core 0 and Core 1 are in ``S`` and try to write simultaneously. CM
resolves by core index.

.. mermaid::

   sequenceDiagram
       participant Core0
       participant Core1
       participant CM

       Core0->>CM: Upgrade [addr=X, txn=10]
       Core1->>CM: Upgrade [addr=X, txn=15]
       Note over CM: Resolves by core index:<br/>Core0 wins (lower index)
       CM->>Core1: Invalidate [addr=X, txn=22]
       Core1-->>CM: InvAck [addr=X, txn=22]
       CM-->>Core1: Nack [addr=X, txn=15]
       CM-->>Core0: GrantM [addr=X, txn=10]
       Core1->>CM: ReadExclusive [addr=X, txn=16] (retry)

**Result:** Core 0 goes ``S → M``. Core 1 goes ``S → I`` (Nack'd), then
retries with ``ReadExclusive``.
