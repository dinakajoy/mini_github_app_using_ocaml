install:
	opam install . --deps-only    

run-client:
	dune build --root . client/client.bc.js  
	mkdir -p ./static/  
	cp _build/default/client/client.bc.js static/client.js  

run-server:
	dune build --root . server/server.exe  
	dune exec --root . server/server.exe   
	