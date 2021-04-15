/*
    Ali ABDEDDAIM
    300113418
*/

/* NOTES IMPORTANTES :
    1.  Mon programme retourne les bonnes lettres et la bonne valeur mais knapsack_2.txt est beaucoup trop grand 
        et la récursivité en Prolog a du mal à s'en charger. Aussi, 
        la récursivité est trop chargé pour knapsack_2.txt seulement si on cherche aussi les items (lettres).
        Si on enlève cette partie du problème. V=716 sera produit. Ceci peut se faire tester en
        enlever les deux dernières lignes de knapsack

    2.  J’ai beaucoup utilisé cette documentation 
        (SWI-Prolog - https://www.swi-prolog.org/pldoc/doc_for?object=root).
*/

/*
    Résoud le problème de la même manière que celle faite en Programmation dynamique
    en Java mais avec le paradigm et la pensée de programmation logique
*/
knapsack(Capacity, L_items_weight, L_items_value, Value, L_items_list, FULLKTABLE, CleanLetters)
    :- LEN_Y_KTABLE is Capacity + 1, fill(L, 0, LEN_Y_KTABLE), 
       getVWL(_,_,L_items_value,L_items_weight, VWPairs), makeKTable(L, 0, VWPairs, KTABLE),
       append([L],KTABLE,FULLKTABLE), length(FULLKTABLE, LENTABLE), 
       LastRowIndex is LENTABLE - 1, nth0(LastRowIndex, FULLKTABLE, LastRow),
       nth0(Capacity, LastRow, Value),
       getLetters(FULLKTABLE, Capacity, Value, LastRowIndex, L_items_list, L_items_weight, L_items_value, Letters),
       convert_ASCIIDEC_string(Letters, CleanLetters).

/* 
    fais lecture, résolution et écriture
*/
solveKnapsack(Filename, Value, L_items_list)
    :-  readKnapsackFile(Filename, _, Names_L, Weights_L, Values_L, Capacity),
        knapsack(Capacity, Weights_L, Values_L, Value, Names_L, _, L_items_list),
        writeToFile(Filename, Value, L_items_list).

/*
    Trouve les lettres des items pris comme on doit 
    faire dans la solution dynamique.
*/
getLetters(_, 0, 0, _, _, _, _, []) :- !.
getLetters(KTable, C, V, CRI, L_items_list, L_items_value, L_items_weight, [CI|RI])
    :-  NCRI is CRI - 1,
        getLastTwoRows(KTable, CRI, UpperRow, _), 
        checkElements(V, UpperRow, C, B), B =:= "f", 
        nth0(NCRI, L_items_list, LI), CI is LI, 
        nth0(NCRI, L_items_value, CIV), NV is V - CIV,
        nth0(NCRI, L_items_weight, CC), NC is C - CC, 
        getLetters(KTable, NC, NV, NCRI, L_items_list, L_items_value, L_items_weight, RI), !.
getLetters(KTable, C, V, CRI, L_items_list, L_items_value, L_items_weight, RI)
    :-  NCRI is CRI - 1,
        getLetters(KTable, C, V, NCRI, L_items_list, L_items_value, L_items_weight, RI), !.


/* ***LECTURE & ÉCRITURE FICHIER*** */
/*
    readKnapsackFile/7 lis le fichier d'entrée, prépare les infos avec cleanKnapsackData/7
    puis extract_l_from_l/6.

    Ici, extract_list_from_list est utilisé pour extraire les noms, valeurs, weights d'items,
    ce qui est nécéssaire pour procéder a la résolution du problème.
 */
readKnapsackFile(Filename, L_len, Names_L, Weights_L, Values_L, Capacity) 
    :- file_lines(Filename, Lines), 
    cleanKnapsackData(Lines, L_len, Names_L, Weights_L, Values_L, Capacity, Cleaned_Lines),
    /*
        Ce findall met toutes les informations des items dans une liste 1D
        Par example, [A, 1, 1, B, ...]
    */
    findall(NL,(nth0(_,Cleaned_Lines,List),nth0(_,List,NL)),L),
    extract_l_from_l(I, L, 0, 3, 0, Names_L), 
    extract_l_from_l(I, L, 1, 3, 1, Weights_L), 
    extract_l_from_l(I, L, 2, 3, 2, Values_L).
/*
    cleanKnapsackData/7 prend la capacité et length des arrays
    et se sert de cleanItemsData/3 pour traiter les lignes avec les informations
    sur les items.
*/
cleanKnapsackData(Lines, L_len, _, _, _, Capacity, Cleaned_Lines) 
    :- nth0(0, Lines, StrLen), normalize_space(atom(NormStrLen), StrLen), 
       atom_number(NormStrLen, L_len),
       findall(Clean_line, cleanItemsData(Lines, _, Clean_line), Cleaned_Lines),
       CapacityIndex is L_len + 1,
       nth0(CapacityIndex , Lines, StrCapacity), normalize_space(atom(_), StrCapacity),
       atom_number(StrCapacity, Capacity).
/*
    cleanItemsData/3 "néttoie" les informations sur les items tel que
    (par exemple) "A 1 1" devienne ["A", 1, 1].

    Ensuite, ce sera facile d'utiliser extract sur la liste (par exemple)
    [["A", 1, 1], ["B", 6, 2], ["C", 10, 3], ["D", 15, 5]]
    pour extraire les letters, valeurs, poids et les mettre dans leurs
    listes respectives.

    Petite précision en plus : pour le knapsack_1.txt,
    dans le nth0/3 ici, Index prendra les valeurs 1,2,3,4
    car Line pour Index = 0,5,6 fera raté le prédicat sublist/4.
    C'est le concepte d'unification en oeuvre.
*/
cleanItemsData(Lines, Index, Clean_line)
    :- nth0(Index, Lines, Line), 
       split_string(Line, " ", " ", Line_L),
       sublist(Str_Nums_Line, 1, 3, Line_L),
       str_l_int_l(Str_Nums_Line, Nums_Line),
       nth0(0, Line_L, Item_Letter),
       append([Item_Letter], Nums_Line, Clean_line).

/*
    file_lines/2 et stream_lines/2 proviennent de cette source :
    https://www.swi-prolog.org/pldoc/doc_for?object=open/3
    (Voir sous la section "Read all lines to a list")

    file_lines/2 lis un fichier donné et de met
    les informations qui y figurent dans une liste 
    ligne par ligne dans l'ordre. 
    Il se sert de stream_lines/2 pour faire ainsi.

    stream_lines/2 sépare les lignes du fichier ligne par ligne
    et les met dans Lines.
*/
file_lines(File, Lines) :- setup_call_cleanup(open(File, read, In),
                           stream_lines(In, Lines),
                           close(In)).
stream_lines(In, Lines) :- read_string(In, _, Str),
                           split_string(Str, "\n", "", Lines).

/* 
    Écris la solution valeur,lettres sur un fichier .sol du même nom 
*/
writeToFile(Filename,Value,L_items_list)
    :-  split_string(Filename,".","",L), nth0(0, L,HeadOfFilename),
        atom_concat(HeadOfFilename, '.sol', SolutionFileName),
        open(SolutionFileName,write,Out),
        write(Out,Value),
        write(Out,"\n"),
        write(Out,L_items_list),
        close(Out).

/* CONSTRUCTION DE LA KTABLE POUR LA SOLUTION DYNAMIQUE */
/*
    Constitue la table en s'aidant de makeNextRow/5.

    Le premier row est la rangée de 0 de longueur capacité
    étant la première valeur du paramètre AboveRow.
*/
makeKTable(_, I, L, []) :- length(L, LEN), I>=LEN.
makeKTable(AR, I, L, [R|RR])
    :-  nth0(I, L, [V|W]),
        makeNextRow(AR, W, V, 0, R),
        I2 is I + 1, makeKTable(R, I2, L, RR).
/*
    makeNextRow/5 constitue le prochain row de la KTable 
    pour la solution dynamique a partir du dernier row fourni en paramètre.

    SOURCE : Inspiré d'un cours sur Zoom du professeur
*/
makeNextRow(L, _, _, CC, []) :- length(L, LEN), CC>=LEN, !.
makeNextRow(L, W, V, CC, [NV|R]) 
    :-  W>CC, nth0(CC, L, NV),
        NCC is CC + 1, makeNextRow(L, W, V, NCC, R).
makeNextRow(L, W, V, CC, [NV|R]) 
    :-  nth0(CC, L, AV), 
        AI is CC - W,
        nth0(AI, L, OAV),
        SECOND is V + OAV,
        max(AV, SECOND, NV),
        NCC is CC + 1, makeNextRow(L, W, V, NCC, R).

/* PRÉDICATS INTERMÉDIARE */
/*
    getWWL/5 constitue la liste des possibilités de pairs [VALUE|WEIGHT].

    getVW/6 prend les éléments tel que ValueIndex (VI) et WeightIndex (WI) sont égaux
    dans les listes qui contiennent ces informations.
*/
getVW(VI, WI, L_items_weight, L_items_value, V, W) 
    :- nth0(VI, L_items_value, V),
       nth0(WI, L_items_weight, W),
       VI =:= WI.
getVWL(VI, WI, L_items_weight, L_items_value, L)
    :- findall([V|W], getVW(VI, WI, L_items_weight, L_items_value, V, W), L).

/*
    convert_ASCIIDEC_string/2 converti une liste de codes ASCII DECIMAUX en liste de string (ou inversement) 
    char_code/2 (built-in) converti un atome en code ASCII (ou inversement)
*/
convert_ASCIIDEC_string([], []).
convert_ASCIIDEC_string([X|Y], [H|T])
    :-  char_code(H, X), convert_ASCIIDEC_string(Y, T).
/* 
    Compare CurrentValue a la valeur juste au dessus dans la KTable 
    BoolResult = true si elles sont les mêmes.

    Ce prédicat est utile pour trouver les letters dans getLetters/7
    comme on doit le faire dans la solution dynamique.
*/
checkElements(CurrentValue, AboveRow, Capacity, B)
    :- nth0(Capacity, AboveRow, AboveValue), equals(AboveValue, CurrentValue, B).

/* 
    Donne les deux derniers rows a partir de l'index du dernier voulu dans KTable
*/
getLastTwoRows(KTable, BottomIndex, UpperRow, BottomRow)
    :-  BottomIndex>=1, nth0(BottomIndex, KTable, BottomRow), 
        UPI is BottomIndex - 1, nth0(UPI, KTable, UpperRow).

/*
    equals/3 unifie le 3ème param. a "t" si les deux premiers sont égaux, "f" sinon  
*/
equals(X, X, "t") :- !.
equals(_, _, "f").

/*
    Unifie le 3eme paramètre avec la plus grande valeur des 2 premiers paramètres.
*/
max(X, Y, Y) :- X<Y, !.
max(X, _, X).

/*
    Donne une liste de longueur N, remplie de l'élément X
    SOURCE : https://stackoverflow.com/questions/16431465/prolog-fill-list-with-n-elements
*/
fill([], _, 0).
fill([X|Xs], X, N) :- succ(N0, N), fill(Xs, X, N0).

/* 
    Extrait de la liste L, chaque élément indexé par I tel que
    I mod D = R.
    
    R étant le reste de la division de I par D et D étant le diviseur 
    I>=S car S détermine le début (start) de l'extraction

    C'est-a-dire que ce prédicat extrait chaque élément donc l'index est un multiple de D
    dans une liste L.
*/
extract_l_from_l(I, L, S, D, M, RES) :- findall(E, (nth0(I, L, E), I mod D =:= M, I>=S), RES).

/*
    str_l_int_l/2 converti une liste de strings en une liste de ints (ou inversement)
*/
str_l_int_l([], []).
str_l_int_l([H|T], [CH|R]) :- atom_number(H, CH), str_l_int_l(T, R).

/*
    Donne une sous liste d'une liste donnée
    SOURCE : https://stackoverflow.com/questions/16427076/prolog-create-sublist-given-two-indices
*/
sublist([], 0, 0, _).
sublist(S, M, N, [_A|B]):- M>0, M<N, sublist(S, M-1, N-1, B).
sublist(S, M, N, [A|B]):- 0 is M, M<N, N2 is N-1, S = [A|D], sublist(D, 0, N2, B).