require 'openssl'
require 'socket'

bytes = 0
cipher_list = ['DES3', 'AES-256-CBC']

socket = TCPServer.new 6666
client = socket.accept

# Take available cipher algorithm and choose one
client_cipher_text = [client.gets.gsub(/\n$/, '')].pack("B*")
available_ciphers = (client_cipher_text.tr('[]','').tr('""','').split(/, /)) & cipher_list
chosen_cipher = available_ciphers[rand 0..1]
client.puts chosen_cipher.to_s.unpack("B*")

# Choosing how many bytes key we need
if chosen_cipher == 'DES3'
  bytes = 23
elsif chosen_cipher == 'AES-256-CBC'
  bytes = 31
end

#Received Diffie-Hellman der and public key
der = [client.gets.gsub(/\n$/, '')].pack("B*")
public_key = (([client.gets.gsub(/\n$/, '')].pack("B*")).to_i).to_bn

# Diffie-Hellman
dh = OpenSSL::PKey::DH.new(der)
dh.generate_key!

# Sending bob public key and computing summary key
client.puts dh.pub_key.to_s.unpack("B*")
summary_key = dh.compute_key(public_key)

# Get encrypted data
encrypted = [client.gets.gsub(/\n$/, '')].pack("B*")

# Decrypt data
decipher = OpenSSL::Cipher.new(chosen_cipher)
decipher.decrypt
decipher.key = summary_key[0..bytes]

decrypted = decipher.update(encrypted) + decipher.final

# Show decrypted data
puts decrypted

client.close