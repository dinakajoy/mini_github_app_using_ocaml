install:
	opam install . --deps-only    

build:
	rm -rf repos/
	dune build  

start: 
	rm -rf repos/
	dune build  
	dune exec ./server/server.exe 

run-server-only:  
	rm -rf repos/
	dune exec ./server/server.exe 