import os
import re
import sys

from socket import socket, create_server

TX_DIR= os.path.dirname(__file__)+"/../proj/"
SUB_DIRS=["", "lib", "modules", "rom"]
RX_DIR= os.path.dirname(__file__)+"/received/"

LISTEN_PORT = 20222
ALLOWED_IPS = ["158.179.20.11", "103.115.209.188"]

def make_connection(server: socket) -> socket:
    while True:
        try:
            socket, addr = server.accept()
        except(TimeoutError):
            continue

        if addr[0] not in ALLOWED_IPS:
            print(f"Unauthorised connection from {addr}", file=sys.stderr)
            socket.close()
            continue

        return socket


def read(conn: socket, timeout) -> bytes:
    conn.settimeout(timeout)
    while True:
        try:
            data= conn.recv(10000)
        except(TimeoutError):
            return None
        
        except(Exception) as e:
            print("Failed to read:"+str(e), file=sys.stderr)
            return None

        return data
    
def receive_file(conn, path, data):
    if not re.match(r"^\w+\.\w+$", path):
        print(f"Suspicious path rx: {path}", file=sys.stderr)
        return

    fname=os.path.join(RX_DIR, path)
    with open(fname, "wb") as f:
        while True:
            count=0
            data= read(conn, 1)
            if data == None:
                print(f"Wrote {count} bytes to {fname}", file=sys.stderr)
                return

            count+=f.write(data)

    
def send_file(conn, path):
    if not re.match(r"^\w+/?\w+\.lua$", path):
        print(f"Suspicious path tx: {path}", file=sys.stderr)
        return

    for dir in SUB_DIRS:
        fname=os.path.join(TX_DIR, dir, path)
        if not os.path.isfile(fname):
            continue

        # Send file
        with open(fname, "rb") as f:
            conn.sendfile(f)
            print("Sent "+fname, file=sys.stderr)
            return
        
    # invalid
    print(f"Not a valid file tx: {path}", file=sys.stderr)
    return


def main():
    server= create_server(('0.0.0.0', LISTEN_PORT), reuse_port=True)
    server.settimeout(10)

    while True:
        with make_connection(server) as conn:
            data= read(conn, 1)
            if data == None:
                print("No data", file=sys.stderr)
                continue
                
            arg=data.decode(errors="replace").split(maxsplit=2)
            code= len(arg)>0 and arg[0] or ""
            path= len(arg)>1 and arg[1] or ""
            rest= len(arg)>2 and arg[2] or ""

            if code == "FILE":
                send_file(conn, path)
                conn.close()
                continue

            if code == "PUT":
                receive_file(conn, path, rest)
                conn.close()
                continue
                        
            # Raw data
            while True:
                data= read(conn, 1)
                if data == None: break
                print(data.decode(errors="replace"), file=sys.stdout)
                
            conn.close()
    


if __name__ == "__main__":
    main()
