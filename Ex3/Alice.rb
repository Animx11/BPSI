require 'openssl'
require 'socket'

puts "Enter ip address:"
address_ip = gets.to_s.strip

socket = TCPSocket.new(address_ip,7777)

rsa = OpenSSL::PKey::RSA.new(2048)
dsa = OpenSSL::PKey::DSA.new(2048)

rsa_pub_key_pem = rsa.public_key.to_pem
dsa_pub_key_pem = dsa.public_key.to_pem

digest = OpenSSL::Digest::SHA1.digest(rsa_pub_key_pem)
sig = dsa.syssign(digest)


socket.puts dsa_pub_key_pem.unpack("B*")
socket.puts rsa_pub_key_pem.unpack("B*")
socket.puts sig.unpack("B*")

encrypted_message = [socket.gets.gsub(/\n$/, '')].pack("B*")

rsa.private_decrypt(encrypted_message)

socket.close
