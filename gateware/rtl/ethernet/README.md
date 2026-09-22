# Ethernet

The gigabit Ethernet MAC/IP/UDP stack that carries openHPSDR protocol 1 traffic between the radio and
host software. Several of these files carry "HPSDR ... Metis code" file headers — they're inherited
from the original openHPSDR Metis Ethernet-interface board (see
[`../../../docs/HISTORY.md`](../../../docs/HISTORY.md)) rather than written from scratch for
Hermes-Lite.

- `rgmii_recv.v` / `rgmii_send.v`, `ddio_in.v` / `ddio_out.v` — RGMII PHY interface: double-data-rate
  I/O primitives and the receive/transmit framing built on them.
- `mac_recv.v` / `mac_send.v`, `crc32.v` — Ethernet MAC frame receive/transmit and the CRC32 check they
  share.
- `ip_recv.v` / `ip_send.v` — IPv4 packet handling.
- `udp_recv.v` / `udp_send.v` — UDP datagram handling; carries the openHPSDR protocol 1 payload
  (`dsopenhpsdr1.v`/`usopenhpsdr1.v` in the parent `rtl/` directory).
- `arp.v` — ARP request/response, so the radio is reachable by IP on the local segment.
- `dhcp.v` — DHCP client, used when the radio is configured to obtain its address automatically rather
  than use a fixed/EEPROM-stored IP.
- `icmp.v` / `icmp_fifo.v` — ICMP echo (ping) support; `icmp_fifo.v` is a Quartus-generated dual-clock
  FIFO used to cross the ICMP responder into the transmit clock domain.
- `mdio.v` — MDIO bus master for reading/writing the Ethernet PHY's management registers.
- `phy_cfg.v` — PHY configuration/initialization sequencing over MDIO.
- `network.v` — top-level module wiring the pieces above together; instantiated directly by
  `hermeslite_core.v`.

`ethernet.v` also exists in this directory but is dead/stale code: it is not referenced by any board's
`files.tcl`/`.qsf`, so it isn't compiled into any build, and its own instantiation of `network` no longer
matches `network.v`'s current port list.
