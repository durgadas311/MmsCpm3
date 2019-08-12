**CP/NET Node ID conventions**

 1. Node ID 0x00 is reserved for a local CP/NET server. Since this is the default server for CP/NET commands, this provides the maximum convenience for accessing the “primary” local server. This server must not be accessible on the internet (e.g. it’s port must not be exposed, and should not be in the range 0x3100-0x31FF).
 1. Node IDs 0xF0-0xFE are reserved for private networks and should not be used for nodes that interact (are visible) on the internet. They may be used as servers or clients.
 1. Publicly accessible nodes should use TCP/IP port 0x31nn, where ‘nn’ is the hexadecimal node ID. This equates to decimal port numbers 12544-12799. WIZCFG on clients will use this convention for the source port numbers of sockets to servers.
 1. Node IDs 0x01 upward will be registered for servers that are accessible on the internet. These servers will use (listen on) TCP/IP port 0x31nn, where ‘nn’ is the node ID.
 1. Node IDs 0xEF downward will be registered for clients that will access servers on the internet.

```
00    (private network) Your primary server
01    Douglas Miller<durgadas311@gmail.com>  Serving software updates
C9    Douglas Miller<durgadas311@gmail.com>  Virtual CP/M 3 Client
EF    Norby<norberto.collado@koyado.com>     Test client for WIZ850io bringup
F0-FE (private network) Your clients and servers
```
