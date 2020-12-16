require 'openssl'
require 'socket'

socket = TCPServer.new(7777)
client = socket.accept

alice_dsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_rsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_sig = [client.gets.gsub(/\n$/, '')].pack("B*")

dsa = OpenSSL::PKey::DSA.new(2048)
digest = OpenSSL::Digest::SHA1.digest(alice_rsa_pub_key_pem)

puts dsa.sysverify(digest, alice_sig)


socket.close
