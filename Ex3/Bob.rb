require 'openssl'
require 'socket'

socket = TCPServer.new(7777)
puts "Waiting for connection"
client = socket.accept

puts "Connection established"
alice_dsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_rsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_sig = [client.gets.gsub(/\n$/, '')].pack("B*")
puts "Received DSA and RSA public keys and signed RSA public key"

puts "Creating hash from received RSA public key"
dsa = OpenSSL::PKey::DSA.new(alice_dsa_pub_key_pem)
digest = OpenSSL::Digest::SHA1.digest(alice_rsa_pub_key_pem)
puts "Verifying signed RSA public key"
ver = dsa.sysverify(digest, alice_sig)

if ver
  puts "Sign is correct, sending message to Alice"
  puts "Please write message to send"
  message = gets
  rsa = OpenSSL::PKey::RSA.new(alice_rsa_pub_key_pem)
  puts "Encrypting message with Alice RSA public key"
  encrypted_message = rsa.public_encrypt(message)
  puts "Sending message"
  client.puts encrypted_message.unpack("B*")
  puts "Message was correctly encrypted and sent to Alice"

else
  puts "Sign was incorrect"
end

socket.close
puts "Disconnecting server"
puts "Disabling the program"