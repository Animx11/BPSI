require 'openssl'
require 'socket'

puts "Enter ip address:"
address_ip = gets.to_s.strip

socket = TCPSocket.new(address_ip,7777)

puts "Creating RSA and DSA key pairs"
rsa = OpenSSL::PKey::RSA.new(2048)
dsa = OpenSSL::PKey::DSA.new(2048)

rsa_pub_key_pem = rsa.public_key.to_pem
dsa_pub_key_pem = dsa.public_key.to_pem

puts "Creating hash from RSA public key"
digest = OpenSSL::Digest::SHA1.digest(rsa_pub_key_pem)
puts "Signing RSA public key"
sig = dsa.syssign(digest)

puts "Sending DSA and RSA public keys and signed RSA public key"
socket.puts dsa_pub_key_pem.unpack("B*")
socket.puts rsa_pub_key_pem.unpack("B*")
socket.puts sig.unpack("B*")
puts "Waiting for Bob encrypted message"
encrypted_message = [socket.gets.gsub(/\n$/, '')].pack("B*")
puts "Received encrypted message"

puts "Decrypted message: " + rsa.private_decrypt(encrypted_message)

socket.close

puts "Disconnecting socket"
puts "Disabling the program"
