# Haskell ANU QRNG
A Haskell interface for the ANU's quantum random number generator (https://qrng.anu.edu.au).

I wrote this to learn more about writing code in Haskell. I also took notes while I was doing so, which are [here](http://blog.matthewja.com/post/108812034379/haskell-anu-qrng).

I don't suggest using this for anything that requires security, because I couldn't get Haskell to recognise the ANU's TLS certificate, so I had to disable authentication. If anyone knows how to fix that in a less-terrible way than disabling authentication entirely, please do submit a pull request.
