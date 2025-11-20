import time
from socket import *

# Server information
SERVER_IP = "127.0.0.1"   # Change this if server runs on another PC
SERVER_PORT = 12000

clientSocket = socket(AF_INET, SOCK_DGRAM)
clientSocket.settimeout(1)   # 1 second timeout

print("UDP Pinger Client Started...\n")

num_pings = 10
rtts = []
lost_packets = 0

for i in range(1, num_pings + 1):
    send_time = time.time()
    message = f"Ping {i} {send_time}"

    try:
        clientSocket.sendto(message.encode(), (SERVER_IP, SERVER_PORT))

        data, server = clientSocket.recvfrom(1024)
        recv_time = time.time()

        rtt = recv_time - send_time
        rtts.append(rtt)

        print(f"Ping {i}: Reply from server, RTT = {rtt:.5f} seconds")

    except timeout:
        lost_packets += 1
        print(f"Ping {i}: Request timed out")

clientSocket.close()

print("\n----- Ping Statistics -----")
print(f"Total Pings Sent: {num_pings}")
print(f"Packets Lost: {lost_packets}")
print(f"Packet Loss Rate: {(lost_packets / num_pings) * 100:.2f}%")

if rtts:
    print(f"Minimum RTT: {min(rtts):.5f} seconds")
    print(f"Maximum RTT: {max(rtts):.5f} seconds")
    print(f"Average RTT: {sum(rtts)/len(rtts):.5f} seconds")
else:
    print("No successful replies received.")
