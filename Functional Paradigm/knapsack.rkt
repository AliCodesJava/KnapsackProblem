; Ali ABDEDDAIM
; 300113418

#lang scheme

; Ma fonction knapsack est inspirée de la fonction récursive donnée pour le livrable Go
; elle-même inspirée de la SOURCE suivante : https://www.geeksforgeeks.org/0-1-knapsack-problem-dp-10
(define (knapsack W wt val)
    (cond ((or (= (length wt) 0) (= W 0)) 0)
        ((let ([last (- (length wt) 1)])
            (if (> (list-ref wt last) W)
                (knapsack W (drop-right wt 1) (drop-right val 1))
                (max (+ (list-ref val last) (knapsack (- W (list-ref wt last)) (drop-right wt 1) (drop-right val 1)))
                     (knapsack W (drop-right wt 1) (drop-right val 1)))
            )
        ))
    )
)

; solveKnapsack LIS le fichier au nom de filename, prends les données
; comme voulu pour les paramètres a l'appel de la fonction knapsack 
; pour résoudre le problème. Finalement, elle écrit le résultat sur un fichier
(define (solveKnapsack filename)
   (let* ([L (file->list filename)] ; lecture du fichier d'entrée
          [len (* (car L) 3)]
          [itemsInfo (slice L 2 len)])
     
        ; préparation des données et résolution du problème
        (let* ([val (extractOddOrEven (filter number? itemsInfo) 0 #t)]
               [wt (extractOddOrEven (filter number? itemsInfo) 0 #f)]
               [capacity (last-element L)]
               [resValue (knapsack capacity wt val)]
               [headOfFile (car (regexp-split "\\." filename))]
               [solFilename (string-append headOfFile ".sol")])

            ; écriture de la solution
            (writeToFile solFilename (number->string resValue))
        )
   )
)

; Crée un fichier et écris dedans
; SOURCE : https://web.mit.edu/scheme_v9.2/doc/mit-scheme-ref/File-Ports.html
(define (writeToFile solFilename str)
  (call-with-output-file solFilename
    (lambda (output-port)
      (display str output-port)
    )
   )
)

; Donne le dernière élément d'un liste (utilise pour extraire la capacité de notre sac)
; SOURCE : https://stackoverflow.com/questions/13175152/scheme-getting-last-element-in-list/51202247
(define (last-element l)
  (cond ((null? (cdr l)) (car l))
        (else (last-element (cdr l)))
  )
)

; J'utilise cette fonction pour extraire les éléments 
; aux indices pairs ou impairs d'une liste.
; Utile pour facilement extraire les listes de weights 
; et values de la liste prises du fichier d'entrée
(define (extractOddOrEven L i even)
    (if (null? L)
        '()
        (if (equal? even #t)
            (cons (car L) (extractOddOrEven (cddr L) -1 #t))
            (if (not (= (modulo i 2) 0))
                (cons (car L) (extractOddOrEven (cdr L) (+ i 1) #f))
                (extractOddOrEven (cdr L) (+ i 1) #f)
            )
        )
    )
)

; On peut prendre une partie d'un tableau
; SOURCE de slice & get-n-items : 
; https://stackoverflow.com/questions/108169/how-do-i-take-a-slice-of-a-list-a-sublist-in-scheme
(define slice
    (lambda (lst start count)
        (if (> start 1)
            (slice (cdr lst) (- start 1) count)
            (get-n-items lst count)
        )
    )
)
; get-n-items est utilisé dans slice
; get-n-items prends les n premiers éléments d'une liste donnée
(define get-n-items
    (lambda (lst num)
        (if (> num 0)
            (cons (car lst) (get-n-items (cdr lst) (- num 1)))
            '()
        )
    )
)