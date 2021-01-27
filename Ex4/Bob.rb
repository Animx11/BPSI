require 'openssl'
require 'socket'

def egcd(a, b)
  mod = b
  # let A, B = a, b
  s, t, u, v = 1, 0, 0, 1
  while 0 < b
    # loop invariant: a = sA + tB and b = uA + vB and gcd(a,b) = gcd(A,B)
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

puts ""
puts "Enter ip address:"
address_ip = gets.to_s.strip

socket = TCPSocket.new(address_ip,7777)

puts "Connected to server..."
puts "Generating RSA Key Pair..."

rsa = OpenSSL::PKey::RSA.new(512)

bob_d = rsa.params.values_at("d").at(0)
bob_n = rsa.params.values_at("n").at(0)
bob_e = rsa.params.values_at("e").at(0)

rsa_pub_key_pem = rsa.public_key.to_pem

puts "Sending RSA Public Key to Alice..."
socket.puts rsa_pub_key_pem.unpack("B*")

puts "Waiting for 100 Yi from Alice..."
y_list = []
for i in (0..99) do
  y_list[i] = OpenSSL::BN.new(socket.gets)
end
puts "Received 100 Yi from Alice..."

puts "Generating Pseudo Random J..."
j = rand(99)
puts "Sending J to Alice..."
socket.puts j

puts "Waiting for Mi, Ki i = 1, ..., 100, i != j from Alice..."
m_list = []
k_list = []
for i in (0..99) do
  m_list[i] = [socket.gets.gsub(/\n$/, '')].pack("B*")
  k_list[i] = OpenSSL::BN.new(socket.gets)
end
puts "Received Mi, Ki i = 1, ..., 100, i != j from Alice..."

puts "Calculating h`i, hi and checking condition h`i == hi..."
h_prim = []
h_bis = []
con = true
for i in (0..99) do
  if i != j then
    h = OpenSSL::Digest::SHA1.hexdigest(m_list[i])
    h = OpenSSL::BN.new(h.to_i(16))
    h_prim[i] = h
    h_bis[i] = (y_list[i]*egcd(pow_bin_mod(bob_n, k_list[i], bob_e), bob_n)[1])%bob_n
    if h_bis[i] != h_prim[i] then
      con = false
      break
    end
  end
end

if con then
  puts "Calculating Z Value..."
  z = pow_bin_mod(bob_n, y_list[j], bob_d)
  puts "Sending Z to Alice..."
  socket.puts z
else
  puts "h`i != hi, condition test failed"
end
socket.close

puts "Disconnecting socket..."
puts "Disabling the program"
puts ""