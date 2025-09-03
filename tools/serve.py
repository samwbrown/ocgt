import socketserver
import os

DIR= os.path.dirname(__file__)
LISTEN_PORT = 20222
ALLOWED_IPS = ["158.179.20.11", "103.115.209.188"]

class FileHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data=self.request.recv(2000).decode("utf-8", "replace")
        
        if self.client_address[0] not in ALLOWED_IPS:
            print(f"Unauthorised msg from {self.client_address}")
            return 
        
        code,_,path= data.partition(" ")
        if code != "FILE":
            print(data)
            return
        
        filedir=""
        if "/" in path:
            filedir=path.split("/")[-2]
            if filedir != "os" and filedir != "rom":
                print(f"Bad path: {path}, {filedir}")
                return 

        fname=DIR+"/../"+filedir+"/"+os.path.basename(path)
        
        if not os.path.isfile(fname):
            print("Bad path: "+fname)
            return
        
        with open(fname, "rb") as f:
            self.request.sendall(f.read())
            print("Sent "+fname)



if __name__ == "__main__":
    server= socketserver.TCPServer(("0.0.0.0", LISTEN_PORT,), FileHandler)
    server.allow_reuse_address=True
    server.allow_reuse_port=True
    server.serve_forever()