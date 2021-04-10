knapsack(Capacity, L_items_weight, L_items_value, Value, L_items_list).

cap(_, _, _, S, []) :- S>7, !.
cap(L, W, V, 0, [0|RR]) :- cap(L, W, V, 1, RR).
cap(L, W, V, S, [0|RR]) :- S<W, SS is S+1, cap(L,W,V,SS,RR).
cap(L, W, V, S, [VV|RR]) :- S>=W, SR is S-W, nth0(SR, L, E), VV is E+V, SS is S+1, cap(L, W, V, SS,RR).


c(L, _, _, CC, []) :- length(L, LEN), CC>=LEN, !.
c(L, W, V, CC, [NV|R]) :- W>CC, nth0(CC, L, NV), write(NV),
                          NCC is CC + 1, c(L, W, V, NCC, R).

c(L, W, V, CC, [NV|R]) :-  nth0(CC, L, AV), 
                           AI is CC - W,
                           nth0(AI, L, OAV),
                           SECOND is V + OAV,
                           my_max(AV, SECOND, NV), write(NV),
                           NCC is CC + 1, c(L, W, V, NCC, R).

makeKTable(_, WI, _, L_items_value, L_items_weight, NR, []) 
    :- length(L_items_value, LEN), .

makeKTable(AL, WI, VI, L_items_value, L_items_weight, T)
    :- 
       nth0(WI, L_items_weight, W),
       nth0(VI, L_items_value, V),
       cap(AL, W, V, 0, R), 
       NWI is WI + 1, NVI is VI + 1,
       makeKTable(R, NWI, VWI, L_items_value, L_items_weight, T).

kTable(SL, WI, VI, L_items_value, L_items_weight, ROWS) 
    :- W is nth0(WI, L_items_weight, W), 
       V is nth0(VI, L_items_value, V), 
       setof(ROW, c(L, W, V, 0, ROW), ROWS).

/* FUNCTIONAL SOMEWHAT

c(_, _, _, CC, []) :- CC>7, !.
c(L, W, V, CC, [NV|R]) :- W>CC, nth0(CC, L, NV), write(NV),
                          NCC is CC + 1, c(L, W, V, NCC, R).

c(L, W, V, CC, [NV|R]) :-  nth0(CC, L, AV), 
                           AI is CC - W,
                           nth0(AI, L, OAV),
                           SECOND is V + OAV,
                           my_max(AV, SECOND, NV), write(NV),
                           NCC is CC + 1, c(L, W, V, NCC, R).
*/


/* V + nth0(CC - W, L, OAV)*/

check(X, 0) :- X<0.
check(X, X) :- X>=0.

/*
max de 2 nombres
*/
my_max(X, Y, Y) :- X<Y, !.
my_max(X, Y, X).

/*
    private void dynamicAlgorithm(){
        for(int item = 1; item<kTable.length; item++){
            for(int weight = 1; weight<kTable[0].length; weight++){
                    si le poids de l'item actuelle est plus grand que
                    le poids max de la colonne actuelle, alors
                    on ne peut pas rajouter en valeur, on conserve
                    donc la valeur de la case dernière
                    sinon, on prend le max entre :
                        - la valeur de la case dernière et
                        - la valeur de l'item actuel + la valeur de l'item 
                          précédent a la position weight - item.weight

                if (problemItems[item - 1].getWeight() > weight){
                    kTable[item][weight] = kTable[item - 1][weight];
                }
                else{
                    kTable[item][weight] = Math.max(kTable[item - 1][weight], 
                                           problemItems[item - 1].getValue() 
                                           + kTable[item - 1][weight - problemItems[item - 1].getWeight()]);

                                            MAX(VALUE ABOVE, )
                }
            }
            c([AV|L], W, V, CC, [NV|R])

            if:
                nth0(CC, L, AV)
            else:
                Max(nth0(CC, L, AV), V + nth0(CC - W, L, OAV))
        }

            on commence avec la valeur tout en bas a droite (valeur optimale <=> item numéro n)
            puis en cherchant item par item du dernier jusqu'a au premier, 
            on trouve nos items pris en soustrayant de value, la valeur de chaque item sélectionné 
            au fur et a mesure tout en vérifiant si la valeur restante vient de la ligne d'en haut ou non 
            ce qui veut dire que l'on prend pas l'item actuel

        int value = kTable[kTable.length-1][kTable[0].length-1];
        for(int row = kTable.length-1; row>0; row--){
                on utilise la méthode helper searchRowForValue(row, value) afin de voir
                si une valeur vient de la ligne au dessus d'elle ou non
            if(!searchRowForValue(row - 1, value) && value > 0){
                value -= problemItems[row - 1].getValue();

                knapsack.addToSack(problemItems[row - 1]);
            }
        }
    }
*/



/*
    Le prédicat suivant provient de la source suivante :
    https://stackoverflow.com/questions/4380624/how-compute-index-of-element-in-a-list

    Il fourni l'index d'un élément donnée dans une liste donnée.
*/
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index) :- indexOf(Tail, Element, Index1),
                                    !, Index is Index1 + 1.

/* make list of length N filled with X 
https://stackoverflow.com/questions/16431465/prolog-fill-list-with-n-elements
*/
fill([], _, 0).
fill([X|Xs], X, N) :- succ(N0, N), fill(Xs, X, N0).

/* sumup/3 inspiré du cours du 30 mars du professeur */
sumup([], [], []).
sumup([X1|L1], [X2|L2], [X3|L3]) :- X3 is X1 + X2, sumup(L1, L2, L3).

cleanKnapsackData(Lines, L_len, Names_L, Values_L, Weights_L, Capacity, Cleaned_Lines) 
    :- nth0(0, Lines, StrLen), normalize_space(atom(NormStrLen), StrLen), 
       atom_number(NormStrLen, L_len),
       findall(Clean_line, cleanItemsData(Lines, Index, Clean_line), Cleaned_Lines),
       nth0(5, Lines, StrCapacity), normalize_space(atom(NormStrCapacity), StrCapacity),
       atom_number(StrCapacity, Capacity).
/*
    Pour le knapsack_1.txt
    Dans le nth0/3 ici, Index prendra les valeurs 1,2,3,4
    car Line pour Index = 0,5,6 fera raté le prédicat sublist/4
*/
cleanItemsData(Lines, Index, Clean_line)
    :- nth0(Index, Lines, Line), 
       split_string(Line, " ", " ", Line_L),
       sublist(Str_Nums_Line, 1, 3, Line_L),
       str_l_int_l(Str_Nums_Line, Nums_Line),
       nth0(0, Line_L, Item_Letter),
       append([Item_Letter], Nums_Line, Clean_line).

readKnapsackFile(Filename) 
    :- file_lines(Filename, Lines), 
    cleanKnapsackData(Lines, L_len, Names_L, Weights_L, Values_L, Capacity, Cleaned_Lines),
    findall(NL,(nth0(Index,Cleaned_Lines,List),nth0(Index2,List,NL)),L),
    extract_l_from_l(I, L, 0, 3, 0, Names_L), 
    extract_l_from_l(I, L, 1, 3, 1, Weights_L), 
    extract_l_from_l(I, L, 2, 3, 2, Values_L),
    write(L_len),
    write(Names_L),
    write(Weights_L),
    write(Values_L),
    write(Capacity).

extract_l_from_l(I, L, S, D, M, RES) :- findall(E, (nth0(I, L, E), I mod D =:= M, I>=S), RES).

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