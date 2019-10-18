test: test.s
	as -g -o test.o test.s
	ld -o test test.o

dump: test
	objdump --section=.data -s test
	objdump -d test

clean:
	rm test test.o