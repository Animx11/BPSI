require 'openssl'

plaintext = "test message"

cipher = OpenSSL::Cipher.new('AES-256-CBC')
cipher.encrypt

key = cipher.random_key
iv = cipher.random_iv

encrypted = cipher.update(plaintext) + cipher.final


decipher = OpenSSL::Cipher.new('AES-256-CBC')
decipher.decrypt

decipher.key = key
decipher.iv = iv

decrypted_message = decipher.update(encrypted) + decipher.final

puts decrypted_message


