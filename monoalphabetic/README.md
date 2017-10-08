To create a challenge:
* Write your message (with answer inside) and save as plaintext.txt
* Generate random key ./genkey >key.txt
* Run ./encrypt - it will generate ciphertext.txt file
* You can verify decryption by running ./decrypt
* You can run ./stats to see how easy/difficult would be breaking the challenge with simple frequency analysis

stats script requires:
  gem install hash-polyfill
