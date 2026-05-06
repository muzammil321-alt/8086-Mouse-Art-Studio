# 8086 Mouse-Driven ASCII Art Studio

## 1. Project Concept
This is a low-level interactive utility that allows users to draw using a mouse in a DOS-like environment. It bypasses standard text-output APIs to write directly to the hardware's video segment.

## 2. Technical Logic (How it works)
* **Coordinate Mapping:** The mouse driver returns X (0-639) and Y (0-199). Since the text mode is 80x25, we use **Bit-Shifting (`SHR CX, 3`)** for rapid division by 8 to map pixels to text cells.
* **Direct Video Access:** Instead of using BIOS interrupts for every pixel, we calculate the memory offset using the formula: `Offset = (Y * 80 + X) * 2`.
* **Hardware Interrupts:** 
  * `INT 33h, AX=0000h`: Hardware Initialization.
  * `INT 33h, AX=0003h`: Real-time Polling of Button States and Coordinates.

## 3. Register Allocation
* `B800h`: Base Segment for Video Memory.
* `ES:[DI]`: Direct pointer for writing character (ASCII 219) and attributes (Color 0Fh).
* `CX/DX`: Real-time Mouse Coordinate Registers.
