import sys
from socket import *
from fileinput import filename

[server_host, server_port, filename] = sys.argv[1:] \
    if len(sys.argv) == 4 else ['127.0.0.1', 8080, 'HelloWorld.html']
server_port = int(server_port)
try:
    # Create a TCP/IP socket
    socketClient = socket(AF_INET, SOCK_STREAM)

    # Connect the socket to the port where the server is listening
    server_addr = (server_host, server_port)
    socketClient.connect(server_addr)
except:
    print("Connection refused. Is the server up? Please Check")
    sys.exit();

try:
    print ("Connected to " + server_host + ":" + str(server_port) + "\n")
    # Send an HTTP request to the server
    message = "GET /" + filename + " HTTP/1.1\n\n"
    socketClient.sendall(message.encode())
    print("Request sent. Waiting for server response...\n")
    data = ''

    # Look for respondse
    while True:
        message = socketClient.recv(1024)
        if len(message) == 0:
            break
        data += message.decode()

    # Display the server response as an output
    print(data)

finally:
    socketClient.close()
