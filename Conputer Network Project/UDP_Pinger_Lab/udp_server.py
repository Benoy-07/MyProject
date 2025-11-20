# udp_server.py
import random
import time
from socket import *

# Server IP and Port
SERVER_IP = "0.0.0.0"
SERVER_PORT = 12000

# Create UDP socket
serverSocket = socket(AF_INET, SOCK_DGRAM)
serverSocket.bind((SERVER_IP, SERVER_PORT))

print(f"UDP Pinger Server is running on port {SERVER_PORT}...")

while True:
    message, clientAddress = serverSocket.recvfrom(1024)

    # OPTIONAL: Introduce random delay to simulate network latency
    delay = random.random()  # value between 0 and 1 sec
    if delay < 0.3:  # 30% chance of delay
        time.sleep(delay)

    modifiedMessage = message  # echo back the same message
    serverSocket.sendto(modifiedMessage, clientAddress)
