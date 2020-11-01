require 'openssl'
require 'socket'
require 'digest'

socket = TCPServer.new(6666)
client = socket.accept

alice_a1 = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_digest = [client.gets.gsub(/\n$/, '')].pack("B*")

alice_a = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_b = [client.gets.gsub(/\n$/, '')].pack("B*")
alice_r = [client.gets.gsub(/\n$/, '')].pack("B*")

if alice_a1 == alice_a

  sha256 = OpenSSL::Digest::SHA256.new
  sha256 << alice_a
  sha256 << alice_b
  sha256 << alice_r
  digest = sha256.digest

  if digest == alice_digest
    puts "Alice bit is correct"
  else
    puts "Alice bit is incorrect"
  end
else
  puts "Alice bit is incorrect"
end


