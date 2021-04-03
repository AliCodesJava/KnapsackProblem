package main

import(
	"fmt"
	"time"
	"runtime"
	"strconv"
	"strings"
	"bufio"
	"os"
	"sync"
)

/* 
	A brute force recursive implementation of 0-1 Knapsack problem 
	modified from: https://www.geeksforgeeks.org/0-1-knapsack-problem-dp-10 

	IMPORTANT : I transformed this implementation into a 
	brute force recursive **concurrent** solution.
*/

func main(){
	// NOTE : J'ai beaucoup consulté la documentation Go officielle

	fmt.Println("Number of cores: ", runtime.NumCPU())

	W, weights, values, nameOfItems := Init()
	/*
		numOfMaxRoutines gère le nombre de goroutines autorisés
		si la variable est 8 (par exemple), alors j'aurais
		2^8 goroutines possibles au maximum car a chaque fois
		que une exécution de Knapsack termine dans la clause 'else if'
		il y a des chances j'ai crée deux goroutines.

		Je crée deux goroutines car je a un arbre binaire, une goroutine pour
		la gauche et une autre pour la droite.

		Je décrémente cette valeur a chaque fois j'appele
		Knapsack() d'elle-même pour éviter de manquer de mémoire sur
		des goroutines et ralentir le programme.

		Avec mon processeur (AMD Ryzen 5), la valeur
		optimale s'avère être entre 7-9 pour obtenir
		des temps d'exécutions pour un gros fichier comme 
		Knapsack_2.txt entre 400-500ms contrairement 
		a plusieurs secondes sans concurrences.
	*/
	numOfMaxRoutines := 7
	start := time.Now()
	result := KnapSack(W, weights, values, nameOfItems, numOfMaxRoutines)
	fmt.Println("Meilleure valeur :", result)
	end := time.Now()
    fmt.Printf("Total runtime : %s\n", end.Sub(start))

	SaveSolution(values, nameOfItems, result)
}

func Init() (int, []int, []int, []string) {
	var err error

	/*
		ici le paramètre de Open() est le nom du fichier 
		passé depuis la ligne de commande
	*/
	file, err := os.Open(os.Args[1:][0])
	if err != nil{ panic(err) }

	scanner := bufio.NewScanner(file)
	scanner.Scan() // lis le prochain token
	
	/*
		Atoi() convertis de string a int
		
		TrimSpace() retourne une slice de la string 
		donnée sans les espaces aux alentours

		Text() retourne une string du token actuel du scanner
	*/
	lenOfArrays, err := strconv.Atoi(strings.TrimSpace(scanner.Text()))
	if err != nil{ panic(err) }

	fmt.Println(lenOfArrays)

	/*
		création des slices nécéssaires
		et mise de l'information ligne par 
		ligne dans les slices
	*/
	nameOfItems := make([]string, lenOfArrays)
	weights := make([]int, lenOfArrays)
	values := make([]int, lenOfArrays)
	for i := lenOfArrays - 1; i >= 0; i--{
		scanner.Scan()

		/*
			strings.Fields() prend dans un tableau
			l'info séparé par l'espaces blancs
		*/
		line := strings.Fields(scanner.Text())

		nameOfItems[lenOfArrays - 1 - i] = line[0]
		values[lenOfArrays - 1 - i], err = strconv.Atoi(strings.TrimSpace(line[1]))
		if err != nil{ panic(err) }
		weights[lenOfArrays - 1 - i], err = strconv.Atoi(strings.TrimSpace(line[2]))
		if err != nil{ panic(err) }
	}

	var W int
	scanner.Scan()
	W, err = strconv.Atoi(strings.TrimSpace(scanner.Text()))
	if err != nil{ panic(err) }

	fmt.Println(nameOfItems)
	fmt.Println(weights)
	fmt.Println(values)
	fmt.Println(W)

	return W, weights, values, nameOfItems
}

func Max(x, y int) int{
    if x < y{
        return y
    }
    return x
}

// Returns the maximum value that 
// can be put in a knapsack of capacity W 
func KnapSack(W int, wt []int, val []int, nameOfItems []string, numOfMaxRoutines int) int {
	// Base Case 
	if (len(wt) == 0 || W == 0){
		return 0
	}
	last := len(wt) - 1

	// If weight of the nth item is more 
	// than Knapsack capacity W, then 
	// this item cannot be included 
	// in the optimal solution 
	if wt[last] > W {
		return KnapSack(W, wt[:last], val[:last], nameOfItems, 0)
	// Return the maximum of two cases: 
	// (1) nth item included 
	// (2) item not included 
	}else if numOfMaxRoutines > 0{
		var firstValue, secondValue int
		var callWaitGroup sync.WaitGroup

		/*
			je sépare les calculs a faire ici 
			en deux goroutines pour gagner du temps

			je syncronise avec un WaitGroup par call Knapsack()
			pour pas que les goroutines se syncronise suivant les autres
			calls
		*/
		callWaitGroup.Add(2)
		go func(){
			defer callWaitGroup.Done()
			firstValue = val[last] + KnapSack(W - wt[last], wt[:last], val[:last], 
									 nameOfItems, numOfMaxRoutines - 1)
		}()
		go func(){
			defer callWaitGroup.Done()
			secondValue = KnapSack(W, wt[:last], val[:last], nameOfItems, numOfMaxRoutines - 1)
		}()
		callWaitGroup.Wait()

		return Max(firstValue, secondValue)
	}else{
		return Max(val[last] + KnapSack(W - wt[last], wt[:last], val[:last], nameOfItems, numOfMaxRoutines - 1), 
				   KnapSack(W, wt[:last], val[:last], nameOfItems, numOfMaxRoutines - 1))
	}
} 

func SaveSolution(values []int, nameOfItems []string, result int){
	inputFileName := os.Args[1:][0] // nom du fichier (sans l'extension)

	resultsFile, err := os.Create(inputFileName[0:len(inputFileName) - 4] + ".sol")
	if err != nil{ panic(err) }

	resultsFile.WriteString(strconv.Itoa(result))
	// écriture des lettres valides sur le fichier
	for i := 0; i<len(values); i++{
		for j := 0; j<len(values); j++{
			if values[i] + values[j] == result{
				resultsFile.WriteString("\n" + nameOfItems[i] + " " + nameOfItems[j])
				return
			}
		}
	}
}