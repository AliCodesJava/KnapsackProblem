iterate(0).
iterate(N) :- write(N), N1 is N - 1, iterate(N1), !.