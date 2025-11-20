##  **1. Project Title**

**UDP Pinger Lab Using Python Socket Programming**


## **2. Project Description**

The UDP Pinger Lab is a simple client-server application that demonstrates how the UDP protocol works in network communication.
In this project:

* The **client** sends multiple ping requests to the **server**.
* The **server** replies to each ping message.
* The **client** measures the *Round-Trip Time (RTT)* for each ping.
* At the end, the client calculates network statistics such as:

  * Average RTT
  * Minimum & Maximum RTT
  * Packet loss rate

This project helps beginners understand:

* How UDP sockets work
* How real-world ping (ICMP-like) behavior can be simulated
* Timeout handling
* Measuring network delay


## **3. How It Works**

### ** Server Side**

1. The server creates a UDP socket.
2. It binds to a specific port and waits for incoming messages.
3. When a ping arrives:

   * The server extracts the data.
   * Optionally adds random delay (to simulate network lag).
   * Sends the same message back to the client.

### **Client Side**

1. The client creates a UDP socket.
2. It sends a series of ping messages (e.g., 10 pings).
3. Each ping contains:

   * A ping number
   * A timestamp
4. The client waits for a response.
5. If the server responds:

   * The client calculates RTT.
6. If the server does **not** respond within the timeout:

   * The client marks the packet as **lost**.

### **After All Pings**

The client prints:

* Total sent pings
* Packets lost
* Packet loss percentage
* Minimum RTT
* Maximum RTT
* Average RTT


##  **4. Calculation**

### **1. Round-Trip Time (RTT) Calculation**

RTT = recv_time − send_time


### **2. Packet Loss Calculation**

If total sent pings = N
And total lost pings = L

Packet Loss (%) = (L / N) × 100


### **3. Average RTT**

If successful RTT values are: r1, r2, r3 … r(k):

Average RTT = (r1 + r2 + ... + rk) / k


### **4. Minimum & Maximum RTT**

Directly computed from RTT list using:

min(RTT_list)
max(RTT_list)
