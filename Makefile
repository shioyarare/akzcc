akzcc: src/akzcc.d
	dmd -of=akzcc src/akzcc.d
test: akzcc
	./test.sh
clean: 
	rm -f akzcc *.o *~ tmp*
.PHONY: test clean
