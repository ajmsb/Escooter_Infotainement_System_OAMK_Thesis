# E-Scooter Infotainment System

A Qt 6 / QML embedded dashboard application for electric scooters, developed as a Bachelor's thesis at Oulu University of Applied Sciences.


---

## Overview

This project is a software‑only prototype of an infotainment system designed for e‑scooters. It simulates a complete ride experience with real‑time speed visualisation, battery monitoring, GPS map navigation (OpenStreetMap), media playback, live weather data, and ride statistics. The application follows a clean model‑view architecture, separating the C++ backend from the declarative QML frontend.

The UI is fixed at **640 × 360 pixels**, making it suitable for small embedded displays (e.g., 5‑inch touchscreens). The codebase is ready for cross‑compilation to a Raspberry Pi 4 running Embedded Linux.

---

## Features

- **Speed & Battery Display** – animated bars with colour‑coded warnings.
- **Riding Mode Selector** – ECO (18 km/h) and TRB (25 km/h) speed limits.
- **Map Navigation** – OpenStreetMap integration with route planning and geocoding.
- **Vehicle Tracking** – real‑time position and heading‑up map rotation.
- **Media Player** – local audio playback with playlist management and volume control.
- **Live Weather** – current temperature and icon from Open‑Meteo API.
- **Ride Statistics** – speed‑over‑time and battery‑level charts with summary cards.
- **Dark / Light Theme** – one‑tap toggle for readability in any light condition.
- **Start / Stop Ride** – simulated physics model with battery drain.
- **Lock & Headlight Controls** – UI toggles ready for hardware integration.

---

## Technology Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Qt 6.9.3 |
| **UI Language** | QML (declarative) |
| **Backend** | C++ (Qt Core, QObject, Q_PROPERTY) |
| **Build System** | CMake |
| **Map & Routing** | Qt Location (OpenStreetMap / OSRM) |
| **Media Playback** | Qt Multimedia |
| **Charts** | Qt Charts |
| **Positioning** | Qt Positioning |
| **Compatibility** | Qt 5 / Qt 6 (via preprocessor guards) |


