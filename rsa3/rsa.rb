# http://www.lukaszielinski.de/blog/posts/2013/07/04/the-rsa-algorithm-in-ruby/
class Integer
  # This method to check for primes is not 100% reliable, but almost.
  # Advantage: speed
  # a^b mod c , using much quicker squaring-method
  # check out https://en.wikipedia.org/wiki/Modular_exponentiation
  # for more information.
  def self.mod_pow( base, power, mod )
    res = 1
    while power > 0
      res = (res * base) % mod if power & 1 == 1
      base = base ** 2 % mod
      power >>= 1
    end
    res
  end
end

class RSA
  class << self
    # Returns the public modulus, the public exponent and the private key.
    def generate_keys(bits)
      n, e, d = 0
      p = random_prime( bits )
      q = random_prime( bits )
      n = p * q
      d = get_d(p, q, e)
      [n, e, d]
    end

    # Encrypts a message with the public modulus (of the receiver).
    # First encode string as a (large) number.
    def encrypt(m, n, e)
      m = s_to_n( m )
      Integer.mod_pow(m, e, n)
    end

    # Decrypts using the private exponent
    def decrypt(c, n, d)
      m = Integer.mod_pow(c, d, n)
      n_to_s(m)
    end

    # Convert number to string
    def n_to_s( n )
      s = ""
      while( n > 0 )
        s = ( n & 0xFF ).chr + s
        n >>= 8
      end
      s
    end

    # Convert string to number
    def s_to_n( s )
      n = 0
      s.each_byte do |b|
        n = n * 256 + b
      end
      n
    end

    # Generate a random number and check if
    # it's prime until a prime is found.
    def random_prime( bits )
      begin
        n = random_number( bits )
        return n if n.prime?
      end while true
    end

    # Concatenate string (begins and ends with 1)
    # to get desired length and an uneven value.
    def random_number( bits )
      m = (1..bits-2).map{ rand() > 0.5 ? '1' : '0' }.join
      s = "1" + m + "1"
      s.to_i( 2 )
    end

    # Euler's totient function, φ(p,q)
    # needed so a multiplicative inverse (private key)
    # can be calculated. https://en.wikipedia.org/wiki/Euler%27s_totient_function
    def phi( a, b )
      (a - 1) * (b - 1)
    end

    # Check out https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm
    # for the maths.
    def extended_gcd( a, b )
      return [0,1] if a % b == 0
      x, y = extended_gcd( b, a % b )
      [y, x - y * (a / b)]
    end

    # Calculate the multiplicative inverse d with d * e = 1 (mod φ(p,q)),
    # using the extended euclidian algorithm.
    def get_d(p, q, e)
      t = phi( p, q )
      x, y = extended_gcd( e, t )
      x += t if x < 0
      x
    end
  end
end

# Unrelated copypasta
def extended_gcd(a, b)
  last_remainder, remainder = a.abs, b.abs
  x, last_x, y, last_y = 0, 1, 1, 0
  while remainder != 0
    last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
    x, last_x = last_x - quotient*x, x
    y, last_y = last_y - quotient*y, y
  end
  return last_remainder, last_x * (a < 0 ? -1 : 1)
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  if g != 1
    raise 'Multiplicative inverse modulo does not exist!'
  end
  x % et
end

def chinese_remainder(mods, remainders)
  max = mods.inject( :* )  # product of all moduli
  series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
  series.inject( :+ ) % max
end

class Integer
  def irootn(n)
    return nil if self < 0 && n.even?
    raise "root n is < 2 or not an Integer" unless n.is_a?(Integer) && n > 1
    num  = self.abs
    root, bitn_mask = 0, 1 << (num.bit_length/n + 2)
    until (bitn_mask >>= 1) == 0
      root |= bitn_mask
      root ^= bitn_mask if root**n > num
    end
    root *= (self < 0 ? -1 : 1)
  end
end
