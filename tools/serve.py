import socketserver
import os

DIR= os.path.dirname(__file__)
LISTEN_PORT = 20222
ALLOWED_IP = "158.179.20.11"

class FileHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data=self.request.recv(2000).decode("utf-8")
        
        if self.client_address[0] != ALLOWED_IP:
            print(f"Unauthorised msg from {self.client_address}")
            return 
        
        code,_,path= data.partition(" ")
        if code != "FILE":
            print(data)
            return
            
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
    server= socketserver.TCPServer(("0.0.0.0", LISTEN_PORT), FileHandler)
    server.serve_forever()