# FPGA-Based Temperature Processing Pipeline

![Language](https://img.shields.io/badge/language-VHDL-blue)
![Platform](https://img.shields.io/badge/platform-Xilinx%20Basys3-red)
![Architecture](https://img.shields.io/badge/architecture-AXI4--Stream-green)

## Project Overview
This project implements a **hardware-based real-time data acquisition and digital signal processing (DSP) system**
on a Xilinx Artix-7 FPGA (Basys 3). The system acquires temperature data via UART, validates and buffers the data using
an **AXI4-Stream pipeline**, applies DSP filtering, and outputs processed results to a hardware display.

## Design Objectives
- Implement a streaming FPGA architecture for real-time sensor data processing
- Ensure reliable data transfer using AXI4-Stream flow control
- Optimize arithmetic operations for FPGA resource efficiency
- Handle invalid data and pipeline stalls
- Demonstrate production-quality RTL design practices

### Key Modules
* **UART Receiver:** Implements a stable state machine for **8N1 serial communication** at 9600 baud, handling Start/Stop bit detection and synchronization.
* **Packet Decoder:** Validates data integrity using a custom frame structure: `[0xAA] [MSB] [LSB] [0x55]`, ensuring only complete frames are processed.
* **AXI4-Stream Data FIFO:** Decouples the processing domains using a circular buffer to prevent data loss during high-load operations or display refreshes.
* **Sliding Average:** A hardware-optimized filter with a window size of $N=16$, utilizing bit-shifting logic.
* **Statistics Unit:** Tracks global **Minimum and Maximum** temperature values since power-up, resettable via user input.

## Technical Implementation Highlights

### 1. Efficient DSP Filtering
To minimize FPGA resource usage (LUTs/DSP slices), the Moving Average module avoids standard division. Instead, it uses an iterative **"Add-Subtract-Shift"** algorithm.

### 2. AXI4-Stream Compliance
The internal pipeline strictly adheres to the **AXI4-Stream** protocol:
* **Flow Control:** Data transfer occurs only when `TVALID` (Master) and `TREADY` (Slave) are high simultaneously.
* **Backpressure Handling:** The AXI FIFO handles potential stalls if the display controller is busy, preventing data drops.

### 3. Robust Error Handling
* **Packet Integrity:** If the decoder detects a framing error (missing headers or invalid checksum), the display indicates **"Err"**.
* **Buffer Overflow:** If the FIFO fills up due to backpressure, a **"FULL"** status is flagged to the user.

## Repository Structure

```text
├── VHDL_components/
│   ├── Sources/
│   │   ├── UART_receiver.vhd       # Serial Interface Logic
│   │   ├── Packet_Decoder.vhd      # Frame parsing & Validation
│   │   ├── UART_to_AXI.vhd         # Protocol conversion
│   │   ├── AXI_FIFO.vhd            # Stream Buffering
│   │   ├── Sliding_Average_AXI.vhd # DSP Filtering Core
│   │   ├── Register_32b.vhd        # Pipeline storage
│   │   ├── Top_Basys3.vhd          # Top Level Integration
│   │   └── ...
├── Simulation/                     # Vivado Testbenches
├── Docs/
│   └── Documentatie.pdf            # Full documentation
└── README.md
```

## Hardware Setup
* **FPGA:** Digilent Basys 3 (Artix-7 XC7A35T)
* **MCU:** Arduino Uno (UART Bridge)
* **Sensor:** DHT11 Temperature Sensor

## Verification and Testing
- Individual modules verified using Vivado testbenches
- UART receiver validated against timing-accurate serial waveforms
- Packet decoder tested with valid and invalid frame sequences

## Potential Extensions
- Parameterizable filter window size
- Resource utilization and timing analysis
- Support for additional sensors
- Migration to higher-speed interfaces (SPI / I2C)
