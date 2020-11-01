require 'openssl'
require 'socket'
require 'digest'

puts "Enter ip address:"
addressIp = gets
addressIp = addressIp.strip

socket = TCPSocket.new(addressIp, 6666)

a = rand 1..100000000
b = rand 1..100000000

r = rand 0..1

sha256 = OpenSSL::Digest::SHA256.new

sha256 << a.to_s
sha256 << b.to_s
sha256 << r.to_s

digest = sha256.digest

socket.puts a.to_s.unpack("B*")
socket.puts digest.to_s.unpack("B*")

socket.puts a.to_s.unpack("B*")
socket.puts b.to_s.unpack("B*")
socket.puts r.to_s.unpack("B*")
