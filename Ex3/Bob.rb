require 'openssl'
require 'socket'

socket = TCPServer.new(7777)
client = socket.accept

alice_dsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_rsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_sig = [client.gets.gsub(/\n$/, '')].pack("B*")

dsa = OpenSSL::PKey::DSA.new(alice_dsa_pub_key_pem)
digest = OpenSSL::Digest::SHA1.digest(alice_rsa_pub_key_pem)

ver = puts dsa.sysverify(digest, alice_sig)

if ver
  puts "Sign is correct, sending message to Alice"
  message = "Message to send"
  rsa = OpenSSL::PKey::RSA.new(alice_rsa_pub_key_pem)
  encrypted_message = rsa.private_encrypt(message)
  client.puts encrypted_message.unpack("B*")
  puts "Message was correctly encrypted and sent to Alice"

else
  puts "Sign was incorrect"
end

socket.close
