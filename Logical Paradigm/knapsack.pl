knapsack(Capacity, L_items_weight, L_items_value, Value, L_items_list).

cleanKnapsackData(Lines, L_len, Names_L, Weights_L, Values_L, Capacity, Cleaned_Lines) 
    :- nth0(0, Lines, StrLen), normalize_space(atom(NormStrLen), StrLen), 
       atom_number(NormStrLen, L_len),
       findall(Clean_line, cleanItemsData(Lines, Index, Clean_line), Cleaned_Lines).

/*
    Pour le knapsack_1.txt
    Dans le nth0/3 ici, Index prendra les valeurs 1,2,3,4
    car Line pour Index = 0,5,6 fera raté le prédicat sublist/4

    foo(BB, Index, Lines, Names_L, Weights_L, Values_L, AA) 
    :- findall(AA, cleanItemsData(Index, Lines, N, W, Vls, AA), BB).
*/
cleanItemsData(Lines, Index, Clean_line)
    :- nth0(Index, Lines, Line), 
       split_string(Line, " ", " ", Line_L),
       sublist(Str_Nums_Line, 1, 3, Line_L),
       str_l_int_l(Str_Nums_Line, Nums_Line),
       nth0(0, Line_L, Item_Letter),
       append([Item_Letter], Nums_Line, Clean_line).

solveKnapsack(Filename, Value, L_items_list, Lines, L_len, Cleaned_Lines) 
    :- file_lines(Filename, Lines), 
       cleanKnapsackData(Lines, L_len, Names_L, Weights_L, Values_L, Capacity, Cleaned_Lines),
       putArr(Index, Index2, Cleaned_Lines, Value),
       lol(I, Value, 2, 3, 2, L_items_list).

putArr(Index, Index2, Cleaned_Lines, L) 
    :- findall(NL,(nth0(Index,Cleaned_Lines,List),nth0(Index2,List,NL)),L).

lol(I, L, S, D, M, RES) :- findall(E, (nth0(I, L, E), I mod D =:= M, I>=S), RES).

/*
    str_l_int_l/2 converti un liste de strings 
    en un liste de ints ou inversement
*/
str_l_int_l([], []).
str_l_int_l([H|T], [CH|R]) :- atom_number(H, CH), str_l_int_l(T, R).

/* https://stackoverflow.com/questions/16427076/prolog-create-sublist-given-two-indices */
sublist([], 0, 0, _).
sublist(S, M, N, [_A|B]):- M>0, M<N, sublist(S, M-1, N-1, B).
sublist(S, M, N, [A|B]):- 0 is M, M<N, N2 is N-1, S = [A|D], sublist(D, 0, N2, B).

/*
    file_lines/2 et stream_lines/2 proviennent de cette source :
    https://www.swi-prolog.org/pldoc/doc_for?object=open/3
    (Voir sous la section "Read all lines to a list")

    Ces derniers sont chargés de lire un fichier donné
    et de mettre les informations qui y figurent 
    dans une liste.
*/
file_lines(File, Lines) :- setup_call_cleanup(open(File, read, In),
                           stream_lines(In, Lines),
                           close(In)).
stream_lines(In, Lines) :- read_string(In, _, Str),
                           split_string(Str, "\n", "", Lines).