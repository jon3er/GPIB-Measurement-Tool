# GPIB-Measurement-Tool
Measurement tool to conduct Automated Measurement with a Rohde &amp; Schwarz FSU over the GPIB-BUS in conjunction with a 2D-Grid Plotter.

# Spektrum-Analyzer Automatisierung (R&S FSU)

## Projektübersicht
Dieses Projekt ermöglicht die computergestützte Steuerung und Datenerfassung eines **Rohde & Schwarz FSU Spektrumanalysators**. Die Kommunikation erfolgt über einen **Prologix GPIB-USB Controller** unter Verwendung der FTDI D2XX-Bibliothek.

## Features
* **GUI:** Cross-Plattform Interface basierend auf **wxWidgets**.
* **Architektur:** Implementierung nach dem **Document/View Pattern** zur Trennung von Messdaten und Visualisierung.
* **Hardware-Ansteuerung:** * Low-Level Zugriff via **FTDI D2XX Driver**.
    * Unterstützung des Prologix-Adapters im Controller-Modus.
    * Gerätespezifische SCPI-Kommandos für R&S FSU (Sweep, Trace-Daten, Marker, IQ-Messung).
* **Visualisierung:** Live-Plotting der Messkurven (wxMathPlot).
* **Datenexport:** Speicherung der Messergebnisse inkl. Gerätekonfiguration im CSV-Format.

## Systemvoraussetzungen
* **OS:** Linux (getestet unter Linux Mint 22.2)
* **Bibliotheken:** * `wxWidgets 3.2+`
    * `libftd2xx` (FTDI-D2XX Driver)
* **Hardware:** Prologix GPIB-USB Controller, R&S FSU Spektrumanalysator.

## Installation & Konfiguration

### 1. FTDI Treiber & Berechtigungen
Damit der Prologix-Adapter ohne Root-Rechte angesprochen werden kann, muss eine udev-Regel erstellt werden:

```bash
# Datei: /etc/udev/rules.d/99-ftdi.rules
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", RUN+="/bin/sh -c 'echo $kernel > /sys/bus/usb/drivers/ftdi_sio/unbind'"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660"
