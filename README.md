# Asynchronous-FIFO

This repository contains the Verilog implementation of an Asynchronous First-In, First-Out (FIFO) Synchronizer. This design is crucial for enabling reliable and ordered data transfer between digital circuits operating on independent or asynchronous clock domains, effectively mitigating the risks associated with Clock Domain Crossing (CDC) such as metastability and data corruption.

## Project Modules
The project is composed of the following Verilog modules:<br>
<ins>asyncfifo.v</ins>: The top-level module integrating all sub-components.<br>
<ins>dp_ram.v</ins>: Implements the dual-port memory block.<br>
<ins>write_ctrl.v</ins>: Manages write operations, tail pointer updates, and iready generation.<br>
<ins>read_ctrl.v</ins>: Manages read operations, head pointer updates, and ovalid generation.<br>
<ins>BFsync.v</ins>: A generic two-flip-flop synchronizer module for cross-clock domain signal transfer.<br>
<ins>gray_count.v</ins>: Converts Gray code to binary, increments it and then converts it back to Gray<br>

## Design Details
The asyncfifo module instantiates a dp_ram for data storage. The write_ctrl module manages incoming data (din, ivalid) and updates the tail pointer (write pointer), while the read_ctrl module handles outgoing data (dout, oready) and updates the head pointer (read pointer). Critical to the asynchronous operation, the BFsync modules synchronize the head pointer from the read domain to the write domain (head_i) and the tail pointer from the write domain to the read domain (tail_o). This synchronized pointer information is then used by the respective control modules to determine the FIFO's full (iready) and empty (ovalid) states

### Design Choices
<ins>FIFO RAM (dp_ram.v)</ins> <br>
The memory block implemented is an 8x8 synchronous write, asynchronous read dual-port RAM. This means data is written on the positive edge of the input/sender clock (clkin), while data can be read combinatorially from any address at any time. 

This specific type of RAM was chosen as it aligns with common asynchronous FIFO design patterns and was a direct reference from "Digital Design Using VHDL: A Systems Approach". While other approaches, such as fully asynchronous dual-port RAMs that latch data, exist (as seen in University of Oslo IN3160/IN4160 lecture slides), the synchronous write/asynchronous read model offered a straightforward and effective solution for the initial implementation. Future work may explore the fully asynchronous RAM for comparison.
<br>  

<ins>Full and Empty Logic</ins> <br>
- The implemented full and empty logic utilizes 3-bit write (tail) and read (head) pointers.
* The empty condition is detected when the write pointer (tail) is equal to the synchronized read pointer in the write domain (head_i).
+ The full condition is detected when the synchronized read pointer in the write domain (head_i) is equal to the incremented value of the current write pointer (inc_tail).
This "one-empty-location" scheme is a simple and reliable method for asynchronous FIFO control. A known drawback of this approach is that one RAM location will always remain unused to distinguish between the full and empty states. My primary objective was to achieve a functional and understandable solution, leading to the selection of this simpler logic. Alternative solutions, such as using an (N+1)-bit pointer for a 2 
N
  depth FIFO (as described by Clifford E. Cummings) or employing dedicated state flip-flops, can utilize all memory locations and will be considered for future enhancements.

# Simulation Waveform
<img width="2324" height="1226" alt="image" src="https://github.com/user-attachments/assets/6ebe9cd7-c86d-45b8-81e2-c734db87bfe0" />





