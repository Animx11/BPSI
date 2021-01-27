require 'openssl'
require 'socket'

def egcd(a, b)
  mod = b
  s, t, u, v = 1, 0, 0, 1
  while 0 < b
    q = (a / b)[0]
    a, b, s, t, u, v = b, (a%b), u, v, (s-u*q), (t-v*q)
  end
  if s < 0 then
    s = s + mod
  end
  return [a, s, t]

end

def pow_bin_mod(mod, a, n)
  if n == 0 then
    return 0
  elsif n == 1 then
    return a
  elsif n%2 == 1 then
    return (a * (pow_bin_mod(mod, a, n-1)) % mod) % mod
  elsif n%2 == 0 then
    return pow_bin_mod(mod, (a*a) % mod, (n/2)[0])
  end
end

socket = TCPServer.new(7777)
puts ""
puts "Waiting for connection..."
client = socket.accept

puts "Connection established..."
puts "Waiting for Bob RSA Public Key..."
bob_rsa_pub_key_pem = [client.gets.gsub(/\n$/, '')].pack("B*")
rsa = OpenSSL::PKey::RSA.new(bob_rsa_pub_key_pem)
n = rsa.params.values_at("n").at(0)
e = rsa.params.values_at("e").at(0)
puts "Received Bob RSA Public Key..."

puts "Put your message: "
message = gets

puts "Preparing 100 Messages, K, Hi and Yi..."

m_list = []
k_list = []
h_list = []
y_list = []
for i in (0..99) do
  m_list[i] = message
  loop do
    k_list[i] = OpenSSL::BN.new(rand(2**511..2**512))
    if k_list[i].gcd(rsa.params.values_at("n").at(0))
      break
    end
  end
  h = OpenSSL::Digest::SHA1.hexdigest(m_list[i])
  h = OpenSSL::BN.new(h.to_i(16))
  h_list[i] = h

  y_list[i] = (h_list[i]*pow_bin_mod(n, k_list[i], e)) % n
end

puts "Sending 100 Yi To Bob..."
for i in (0..99) do
  client.puts y_list[i]
end

puts "Waiting for J from Bob..."
j = OpenSSL::BN.new(client.gets)
puts "Received J from Bob..."

puts "Sending Mi, Ki for i = 1, ..., 100, i != j to Bob..."
for i in (0..99) do
  if i != j then
    client.puts m_list[i].unpack("B*")
    client.puts k_list[i]
  else
    client.puts 1
    client.puts 1
  end
end

puts "Waiting for Z from Bob..."
z = OpenSSL::BN.new(client.gets)
puts "Received Z from Bob..."

puts "Calculating s = zk^-1 (mod n)..."
s = ((z * egcd(k_list[j], n)[1]) % n)
puts "Verifying signature..."
nh = OpenSSL::Digest::SHA1.hexdigest(message)
nh = OpenSSL::BN.new(nh.to_i(16))
xh = pow_bin_mod(n, s, e)
if nh == xh then
  puts "Verification was successful, s is a Bob blind signature under the M"
else
  puts "Verification was unsuccessful, s is not a Bob blind signature under the M"

end

socket.close
puts "Disconnecting server..."
puts "Disabling the program"
puts ""