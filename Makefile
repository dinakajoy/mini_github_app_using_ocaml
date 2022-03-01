install:
	opam install . --deps-only    

build:
	dune build  

start: 
	dune build  
	dune exec ./server/server.exe 

run-server-only:  
	dune exec ./server/server.exe 