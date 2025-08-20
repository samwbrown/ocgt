import socketserver
import os

DIR= os.path.dirname(__file__)

class FileHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data=self.request.recv(2000).decode("utf-8")
        
        code,_,path= data.partition(" ")
        if code != "FILE":
            print(data)
            return
            
        fname=DIR+"/"+os.path.basename(path)
        
        if not os.path.isfile(fname):
            print("Bad path: "+fname)
            return
        
        with open(fname, "rb") as f:
            self.request.sendall(f.read())
            print("Sent "+fname)
            

if __name__ == "__main__":
    HOST, PORT = "0.0.0.0", 20222
    
    server= socketserver.TCPServer((HOST, PORT), FileHandler)
    server.serve_forever()