ALL: launch

launch: launch.c
	gcc -static -std=c99 -Wall launch.c -o launch

segfault: segfault.c
	gcc -static -std=c99 -Wall segfault.c -o segfault

test: segfault launch
	./bad.sh
	./good.sh

clean:
	rm -f segfault launch
