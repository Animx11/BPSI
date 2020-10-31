require 'openssl'
require 'socket'

plaintext = "test message"

socket = TCPSocket.new("localhost",6666)

cipher = OpenSSL::Cipher.new('AES-256-CBC')
cipher.encrypt

key = cipher.random_key
iv = cipher.random_iv

encrypted = cipher.update(plaintext) + cipher.final

socket.puts encrypted
socket.puts key
socket.puts iv