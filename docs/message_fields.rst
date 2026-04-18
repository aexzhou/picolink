Message Field Definitions
=========================

Common Fields
-------------

Every message on both channels carries the following fields:

.. list-table::
   :header-rows: 1
   :widths: 22 18 60

   * - Field
     - Width (bits)
     - Description
   * - ``channel``
     - 1
     - ``0`` = A (Core → CM), ``1`` = B (CM → Core).
   * - ``opcode``
     - 4
     - Opcode identifying the message type.
   * - ``src_id`` / ``dst_id``
     - N
     - Source or destination identifier (core ID or CM ID).
   * - ``txn_id``
     - T
     - Transaction ID (required: multiple outstanding requests supported).
   * - ``addr``
     - A
     - Cache-line-aligned physical address.

A Channel Message Fields (Core → CM)
------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 16 12 12 12 10 16 22

   * - Message
     - ``msg_type``
     - ``src_id``
     - ``txn_id``
     - ``addr``
     - ``data``
     - Notes
   * - ``ReadShared``
     - ``0x0``
     - Core ID
     - Yes
     - Yes
     - (none)
     -
   * - ``ReadExclusive``
     - ``0x1``
     - Core ID
     - Yes
     - Yes
     - (none)
     -
   * - ``Upgrade``
     - ``0x2``
     - Core ID
     - Yes
     - Yes
     - (none)
     - Core must already be in ``S``.
   * - ``WriteBack``
     - ``0x3``
     - Core ID
     - Yes
     - Yes
     - Yes (dirty line)
     - Full cache-line payload.
   * - ``InvAck``
     - ``0x4``
     - Core ID
     - Yes
     - Yes
     - (none)
     - ``txn_id`` matches the ``Invalidate`` being ack'd.

B Channel Message Fields (CM → Core)
------------------------------------

.. list-table::
   :header-rows: 1
   :widths: 16 12 12 12 10 16 22

   * - Message
     - ``msg_type``
     - ``dst_id``
     - ``txn_id``
     - ``addr``
     - ``data``
     - Notes
   * - ``GrantS``
     - ``0x0``
     - Core ID
     - Yes
     - Yes
     - Yes (clean line)
     - Response to ``ReadShared``.
   * - ``GrantE``
     - ``0x1``
     - Core ID
     - Yes
     - Yes
     - Yes (clean line)
     - Response to ``ReadShared`` (no sharers) or ``ReadExclusive``.
   * - ``GrantM``
     - ``0x2``
     - Core ID
     - Yes
     - Yes
     - (none)
     - Response to ``Upgrade`` only.
   * - ``Invalidate``
     - ``0x3``
     - Core ID
     - Yes
     - Yes
     - (none)
     - Core must respond with ``InvAck`` or ``WriteBack``.
   * - ``WriteBackAck``
     - ``0x4``
     - Core ID
     - Yes
     - Yes
     - (none)
     - Confirms memory committed data.
   * - ``Nack``
     - ``0x5``
     - Core ID
     - Yes
     - Yes
     - (none)
     - Denied; retry as ``ReadExclusive``.

Field Sizing Notes
------------------

* ``src_id`` / ``dst_id``: ⌈log₂(num_cores + 1)⌉ bits: the ``+1`` accounts
  for the CM as an endpoint.
* ``txn_id``: width depends on max outstanding transactions per core
  (e.g. 4 bits = 16 outstanding requests).
* ``addr``: physical address width minus cache-line offset bits
  (e.g. 48 − 6 = 42 bits for 64-byte lines).
* ``data``: present only on ``WriteBack``, ``GrantS``, and ``GrantE``:
  full cache-line width (e.g. 512 bits for 64 B lines).
