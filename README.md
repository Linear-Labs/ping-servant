# ping-servant

Sends a ping to an address and then waits for a response.


See
https://github.com/haskell-servant/servant/issues/1101
...
stack new <MYPROJ> servant

creates a servant template

And then 
    stack build
And then 
    stack exec ping-server-exe

allows running the template

curl http://localhost:8080/users
