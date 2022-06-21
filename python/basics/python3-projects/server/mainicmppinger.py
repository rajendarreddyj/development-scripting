#!/usr/bin/python3

from socket import *
import os
import sys
import struct
import time
import select
import binascii

ICMP_ECHO_REQUEST = 8


def checksum(string):
    csum = 0
    countTo = len(string) // 2 * 2

    count = 0
    while count < countTo:
        thisVal = ord(string[count + 1]) * 256 + ord(string[count])
        csum = csum + thisVal
        csum = csum & 0xffffffff
        count = count + 2

    if countTo < len(string):
        csum = csum + ord(string[len(string) - 1])
        csum = csum & 0xffffffff

    csum = (csum >> 16) + (csum & 0xffff)
    csum = csum + (csum >> 16)
    answer = ~csum
    answer = answer & 0xffff
    answer = answer >> 8 | answer << 8 & 0xff00

    return answer


def receiveOnePing(mySocket, ID, timeout, destAddr):
    timeLeft = timeout

    while 1:
        startedSelect = time.time()
        whatReady = select.select([mySocket], [], [], timeLeft)
        howLongInSelect = (time.time() - startedSelect)

        if whatReady[0] == []:
            print(whatReady[0])
            # Timeout
            return "Request timed out."

        timeReceived = time.time()
        recPacket, addr = mySocket.recvfrom(1024)

        # Fetch the IP packet header
        # ipVer = Version, IHL
        # servType = Services
        # length = Total length
        # ipID = ID
        # ipFlagsOff = Flags, Fragment Offset
        # ipTTL = Time to Live
        # ipProc = Protocol
        # ipChecksum = checksum
        # ipSrc = Source IP address
        # ipDest = Destination IP address
        ipHeader = recPacket[:20]
        ipVer, servType, length, ipID, ipFlagsOff, ipTTL, ipProc, ipChecksum, ipSrc, ipDest = struct.unpack("BBHHHBBHII", ipHeader)

        # Fill in start
        # Fetch the ICMP header from the IP packet
        # There are 8 bits in 1 byte so we start at index 20
        # The ICMP header starts after bit 160(20 byte) of the IP header (unless IP options are used).
        # Type : ICMP type.(160-167) bits/1 byte
        # Code : Subtype to the given ICMP type. (168-175) bits/1 byte
        # Checksum : Error checking data calculated from the ICMP header + data, with value 0 for this field. (176-183)(184-191) bits/2 bytes
        # ID - An ID value, should be returned in the case of echo reply. 2 bytes
        # Sequence - A sequence value, should be returned in the case of echo reply. 2 bytes

        # Fetch the ICMP header from the IP packet
        icmpHeader = recPacket[20:28]

        # struct.unpack(format, data) unpack the binary data string according to the given format
        type, code, checksum, id, sequence = struct.unpack("bbHHh", icmpHeader)

        # Filter the echo request
        if type != 8 and id == ID:
            timeSent = struct.unpack("d", recPacket[28:28 + struct.calcsize("d")])[0]
            packetSize = len(recPacket)
            if ((timeSent * 1000) < 1):
                print("Reply from " + destAddr + ": bytes=" + str(packetSize) + " time<=1ms TTL=" + str(ipTTL))
            else:
                print("Reply from " + destAddr + ": bytes=" + str(packetSize) + " time=" + str(int(round(timeSent * 1000, 1))) + "ms TTL=" + str(ipTTL))

            return timeReceived - timeSent

        # Fill in end
        timeLeft = timeLeft - howLongInSelect
        if timeLeft <= 0:
            return "Request timed out."


def sendOnePing(mySocket, destAddr, ID):
    # Header is type (8), code (8), checksum (16), id (16), sequence (16)
    myChecksum = 0
    # Make a dummy header with a 0 checksum
    # struct -- Interpret strings as packed binary data
    header = struct.pack("bbHHh", ICMP_ECHO_REQUEST, 0, myChecksum, ID, 1)
    data = struct.pack("d", time.time())
    # Calculate the checksum on the data and the dummy header.
    myChecksum = checksum(str(header + data))
    # Get the right checksum, and put in the header
    if sys.platform == 'darwin':
        # Convert 16-bit integers from host to network byte order
        myChecksum = htons(myChecksum) & 0xffff
    else:
        myChecksum = htons(myChecksum)

    header = struct.pack("bbHHh", ICMP_ECHO_REQUEST, 0, myChecksum, ID, 1)
    packet = header + data
    mySocket.sendto(packet, (destAddr, 1))  # AF_INET address must be tuple, not str
    # Both LISTS and TUPLES consist of a number of objects
    # which can be referenced by their position number within the object.


def doOnePing(destAddr, timeout):
    icmp = getprotobyname("icmp")
    # SOCK_RAW is a powerful socket type. For more details: http://sockraw.org/papers/sock_raw
    mySocket = socket(AF_INET, SOCK_RAW, icmp)
    myID = os.getpid() & 0xFFFF  # Return the current process i
    sendOnePing(mySocket, destAddr, myID)
    delay = receiveOnePing(mySocket, myID, timeout, destAddr)
    mySocket.close()
    return delay


def ping(host, timeout=1):
    # timeout=1 means: If one second goes by without a reply from the server,
    # the client assumes that either the client's ping or the server's pong is lost
    dest = gethostbyname(host)
    print("Pinging " + dest + " using Python:")
    print("")
    # Send ping requests to a server separated by approximately one second
    while 1 :
        delay = doOnePing(dest, timeout)
        print(delay)
        time.sleep(1)  # one second
    return delay


ping("127.0.0.1")
# ping("google.com")
