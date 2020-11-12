require 'openssl'
require 'socket'

bytes = 0
cipher_list = ['DES3', 'AES-256-CBC']

puts "Enter ip address:"
address_ip = gets.to_s.strip

socket = TCPSocket.new(address_ip, 6666)

# Sending available ciphers and getting one of them which alice and bob will be using to communicate
socket.puts cipher_list.to_s.unpack("B*")
chosen_cipher = [socket.gets.gsub(/\n$/, '')].pack("B*")

# Choosing how many bytes key we need
if chosen_cipher == 'DES3'
  bytes = 23
elsif chosen_cipher == 'AES-256-CBC'
  bytes = 31
end

# Loading data from file
data = ""
File.open("data.txt").each do |line|
  data = data + line
end

# Diffie-Hellman
dh = OpenSSL::PKey::DH.new(512)
der = dh.public_key.to_der
socket.puts der.to_s.unpack("B*")
socket.puts dh.pub_key.to_s.unpack("B*")

# Receiving Diffie-Hellman public key to compute summary key
public_key = (([socket.gets.gsub(/\n$/, '')].pack("B*")).to_i).to_bn
summary_key = dh.compute_key(public_key)

#Encrypt
cipher = OpenSSL::Cipher.new(chosen_cipher)
cipher.encrypt
cipher.key = summary_key[0..bytes]

encrypted = cipher.update(data) + cipher.final

#Send key and encrypted data
socket.puts encrypted.unpack("B*")
puts 'Message was send to Bob'

socket.close