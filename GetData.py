import sys
import telnetlib

HOST = "128.149.23.134"
port = "6775"

eph = telnetlib.Telnet(HOST,port)

eph.read_all()

eph.close
