Introduction
============

Overview
--------

PicoLink is a simplified cache-coherency protocol designed around the following
principles:

* Based on **TileLink**, with a substantially reduced message set.
* Uses the **MESI** (Modified, Exclusive, Shared, Invalid) coherence model.
* Operates over **two channels**: ``A`` and ``B``.
* **No Probes.**
* **No Release.**

Architectural Assumptions
-------------------------

The protocol assumes the following system architecture:

* CPU cores each have their own **private L1 cache**.
* **Memory only stores clean data.**
* A **Coherency Manager (CM)** tracks sharers and ownership.
* The topology is **directory-based**.
* There are **no cache-to-cache transfers**: memory always supplies the data
  payload for ``GrantS`` and ``GrantE``.
