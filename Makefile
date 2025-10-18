install:
	opam switch create . ocaml-base-compiler.4.14.1
	eval $$(opam env)
	opam install . --deps-only -y 

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