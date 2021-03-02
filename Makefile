SRCS=$(wildcard src/*.d)

akzcc: $(OBJS)
	dmd -of=akzcc $(SRCS)

test: akzcc
	./test.sh

clean: 
	rm -f akzcc *.o *~ tmp*

.PHONY: test clean
