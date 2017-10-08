To create a challenge:
* Create plaintext.txt with message to encrypt
  (can't be too long, you might need to adjust key length if it is)
* Run ./genkey to generate random keys:
  private_key1.txt private_key2.txt private_key3.txt
  public_key1.txt public_key2.txt public_key3.txt
  It's going to take ~30s.
* To verify run ./decrypt

Include in the challenge:
  public_key1.txt public_key2.txt public_key3.txt
  ciphertext1.txt ciphertext2.txt ciphertext3.txt
