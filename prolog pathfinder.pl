%Start of knowledge base
edge(outside, porch1).
edge(porch1, kitchen).
edge(kitchen, livingRoom).
edge(livingRoom, porch2).
edge(porch2, outside).
edge(livingRoom, corridor).
edge(corridor, wc).
edge(corridor, bedroom).
edge(corridor, masterBedroom).

room(outside).
room(porch1).
room(kitchen).
room(livingRoom).
room(porch2).
room(bedroom).
room(corridor).
room(wc).
room(masterBedroom).
%end of knowledge base

%Section 3.1
validRoom(X, Y):-
	room(X),
	room(Y).

connected(X, Y) :-
	edge(X, Y).
connected(X, Y) :-
	edge(Y, X).

path(O, D, Path):-
	(validRoom(O,D) -> find(O, D, [O], Way), reverse(Way, Path); write("Your room name is invalid (check the spelling)"), false).

%pathfinding algorithm using depth first search
find(A, B, Visited, [B|Visited]):-
	connected(A, B).
find(A, B, Visited, Way):-
	connected(A, C),
	C\==A,
	C\==B,
	\+ member(C, Visited),
	find(C, B, [C|Visited], Way).

%Section 3.2, returns a list of two seperate paths, one from O1 to D and another from O2 to D
meet(O1, O2, D, Path):-
	find(O1, D, [O1], P1),
	find(O2, D, [O2], P2),
	format(P1, D, P2, Path).

%providing a shortest meeting method, uses shortest pathfinder
shortestMeet(O1, O2, D, Path):-
	shortest(O1, D, R1),
	shortest(O2, D, R2),
	reverse(R2, P2),
	reverse(R1, P1),
	format(P1, D, P2,Path).

%uses already implemented path, setof/3 and recursive methods to return
%the shortest path based on length (the minimal solution).
shortest(A, B, Path):-
	setof(P, path(A, B, P), Set),
	minimal(Set, Path).

minimal([F|R], M):-
	min(R, F, M).
min([], M, M).
min([P|R], M, Min):-
	length(P, Pl),
	length(M, Ml),
	Pl < Ml, !,
	min(R, P, Min).
min([_|R], M, Min):-
	min(R, M, Min).


%formating method for meeting
format([_|P1], D, [_|P2], Path):-
	reverse(P1, R1),
	Path = [R1, D, P2].

%Section 3.3

edgel(outside, porch1, 1).
edgel(porch1, kitchen, 1).
edgel(kitchen, livingRoom, 3).
edgel(porch2, livingRoom, 5).
edgel(outside, porch2, 1).
edgel(corridor, livingRoom, 1).
edgel(bedroom, corridor, 2).
edgel(corridor, wc, 2).
edgel(corridor, masterBedroom, 2).

/*extra edges for testing
edgel(wc, heaven, 4).
edgel(heaven, porch2, 3).
*/

%connected that returns length of L
len(X, Y, L):-
	edgel(X, Y, L).
len(X, Y, L):-
	edgel(Y, X, L).

%error checking method, returns a set of ordered lists,
%each list has a path as its first entry and the length as its second entry
pathLen(O, D, Set):-
	(validRoom(O,D) -> returnSorted(O, D, Set); write("Your room name is invalid (check the spelling)"), false).

%makes a set of solutions, produces all possible permutations of that list, and checks if each one is sorted 
returnSorted(O, D, Set):-
	setof([P,L], findRev(O, D, P, L), S),
	lists:perm(S, Set),
	isSorted(Set).

%reverses the list made by findLen
findRev(A, B, Path, Length):-
	findLen(A, B, [A], Way, Length),
	reverse(Way, Path).

%The DFS from 3.1 thats been modified to return length aswell
findLen(A, B, Visited, [B|Visited], Length):-
	len(A, B, Length).
findLen(A, B, Visited, Way, Length):-
	len(A, C, L1),
	C\==A,
	C\==B,
	\+ member(C, Visited),
	findLen(C, B, [C|Visited], Way, L2),
	Length is L1 + L2.

%Recursive implementation for checking a list is smaller
isSorted([]).
isSorted([_]).
isSorted([X,Y|T]):-
	smallerThan(X, Y),
	isSorted([Y|T]).

%minor predicate to check two lengths in a nested list and return true is the first
%is smaller than the second.
smallerThan([_,L1],[_,L2]):-
	L1 =< L2.

%rewriting 3.2 for equal cost travel
equalMeet(O1, O2, D, [X|Path]):-
	returnSorted(O1, D, S1),
	returnSorted(O2, D, S2),
	checkEqual(S1, S2, R1, R2, X),
	reverse(R1, P1),
	reverse(R2, P2),
	format(P1, D, P2, Path).

checkEqual([[P1,X]|_], [[P2,Y]|_], P1, P2, X):-
	X == Y.
checkEqual([[_,X]|R1], [[P2,Y]|R2], Path1, Path2, Length):-
	X < Y,
	checkEqual(R1, [[P2, Y]|R2], Path1, Path2, Length).
checkEqual([[P1, X]|R1], [[_,_]|R2], Path1, Path2, Length):-
	checkEqual([[P1, X]|R1], R2, Path1, Path2, Length).