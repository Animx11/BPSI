require 'openssl'
require 'socket'

socket = TCPServer.new 6666
client = socket.accept

encrypted_message = client.gets.gsub(/\n$/, '')
key = client.gets.gsub(/\n$/, '')
iv = client.gets.gsub(/\n$/, '')

decipher = OpenSSL::Cipher.new('AES-256-CBC')
decipher.decrypt

decipher.key = key
decipher.iv = iv

decrypted_message = decipher.update(encrypted_message) + decipher.final

puts decrypted_message
