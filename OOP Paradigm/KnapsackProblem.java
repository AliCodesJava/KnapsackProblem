import java.util.Scanner;
import java.util.HashSet;

import java.io.File;
import java.io.FileWriter;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.lang.Math;

/*
    Choix de design :
        Mettre toutes les méthodes en privée dans cette classe
        car dans ce cas, on n'utilise pas les méthodes depuis l'extérieur
        de la classe sauf pour la méthode main() qui reste publique

        cette classe gère tout, elle doit avoir l'acces aux autres classes
        mais pas inversement
*/
public class KnapsackProblem{
    private Scanner scanner;

    private Item[] problemItems;
    private Knapsack knapsack;

    // pour la solution dynamique iterative
    private int[][] kTable;

    public static void main(String[] args) throws FileNotFoundException, IOException{
        KnapsackProblem ksp = new KnapsackProblem();

        ksp.init(args[0]);
        ksp.chooseSolvingMethod(args[1]);
        ksp.saveSolution(args[0].split("\\.")[0]); // parameter : name of the input file
    }
    private void chooseSolvingMethod(String choice){
        if(choice.equals("F")) bruteForce();
        else if(choice.equals("D")) dynamicAlgorithm();
        else System.out.println("Choix invalide ! Choisissez F ou D.");
    }

    // initialisation des variables nécéssaires a partir du fichier d'input
    private void init(String filename) throws FileNotFoundException{
        scanner = new Scanner(new File(filename));

        problemItems = new Item[Integer.parseInt(scanner.next())];
        for(int i = 0; i<problemItems.length; i++){
            scanner.nextLine();

            problemItems[i] = new Item(scanner.next(),
                                       Integer.parseInt(scanner.next()),
                                       Integer.parseInt(scanner.next()));
            // Note : scanner.next() trouve et retourne le prochain token
            // donc ça saute les espaces blancs
        }
        // passe a la prochaine ligne car scanner.next() reste sur la même ligne
        scanner.nextLine();

        /*
            création du sac avec comme paramètres sa capacité (poids max)
            du sac et le nombre d'Items MAX (donc le nombre d'Items)
            qu'on peut mettre dans l'ArrayList (donc dans le sac)
        */
        knapsack = new Knapsack(Integer.parseInt(scanner.next()), 
                      problemItems.length);

        kTable = new int[problemItems.length + 1][knapsack.getMaxWeightCapacity() + 1];
    }

    /* 
        NOTE IMPORTANTE :
        
        Mon PC était trop lent pour tester le 2ème test (knapsack2.txt) avec n = 27 éléments
        car la compléxite de l'algorithme bruteForce() est énorme (O(2^n)) pour ma méthode
        brute force seulement. Faute de mémoire et de puissance.

        Cependant, j'ai testé plusieurs autres tests (comme celui de l'exemple du PDF)
        et mon code pour les deux méthodes s'avère être juste.
    */
    private void bruteForce(){
        HashSet<Item> optimalSolution = new HashSet<Item>(problemItems.length);

        int bestValue = 0;
        // notez que l'ensemble puissance est l'ensemble 
        // de toutes les sous-ensembles possibles d''un ensemble
        HashSet<HashSet<Item>> powerSet = generatePowerSet();
        for(HashSet subset : powerSet){
            // pour chaque sous-ensemble de l'ensemble puissance de notre ensemble d'items 
            // du problème : valueWeightSums[0] = valeur totale du sous-ensemble actuel, 
            // valueWeightSums[1] = poids totale du sous-ensemble actuel
            int[] valueWeightSums = valueWeightSumsOfSet(subset);

            // en utilisant ces valeurs, on peut donc trouvé 
            // si un sous-ensemble est meilleur que le dernier meilleur
            // obtenu ou non, on répète jusqu'a obtenir la solution optimale
            if(valueWeightSums[0] > bestValue 
               &&valueWeightSums[1] <= knapsack.getMaxWeightCapacity()){
                bestValue = valueWeightSums[0];
                
                optimalSolution = (HashSet<Item>)subset.clone();
            }
        }

        // on met les items de la solution optimal dans le sac
        for(Item item : optimalSolution) knapsack.addToSack(item);
    }
    /* 
        generatePowerSet() est une méthode helper pour bruteForce() 
        qui génère l'ensemble contenant tous les sous-ensembles possible 
        (donc toutes les solutions) pour notre tableau d'Items (ensemble d'Items)

        La génération se fait de manière itérative et binaire. C'est-a-dire qu'on
        va a travers les 2^n possibilités ou on décide ou non de prendre un item
        donc 0000 <=> {}, 0001 <=> {D}, etc
    */
    private HashSet<HashSet<Item>> generatePowerSet(){
        HashSet<HashSet<Item>> powerSet = new HashSet<HashSet<Item>>
                                          ((int)Math.pow(2, problemItems.length));

        // on génère les 2^n-1 possibilités
        for(int ctr = 0; ctr<Math.pow(2, problemItems.length); ctr++){
            // convertDecimalToBinary(ctr) de ctr = 0 jusqu'a ctr = 2^n-1
            // pour obtenir progréssivement les 2^n solutions possibles
            String[] binaryNum = convertDecimalToBinary(ctr);

            HashSet<Item> subset = new HashSet<Item>(problemItems.length);
            for(int j = 0; j<binaryNum.length; j++){
                // on prend l'item si et seulement si on a un "1"
                if(binaryNum[j].equals("1")){
                    subset.add(problemItems[j]);
                }
            }
            powerSet.add(subset);
        }

        return powerSet;
    }
    /*
        méthode helper (pour generatePowerSet()) qui prend un nombre décimal
        et le converti en binaire
    */
    private String[] convertDecimalToBinary(int decimal){
        String[] result = new String[problemItems.length];

        int bitPower = result.length - 1;
        for(int i = 0; i<result.length; i++){
            if(decimal >= Math.pow(2, bitPower)){
                result[i] = "1";

                decimal -= Math.pow(2, bitPower);
            }else{ result[i] = "0"; }

            bitPower--;
        }

        return result;
    }
    // méthode helper pour bruteForce, voir bruteForce()
    // pour voir ce que cette méthode fait en détails
    private int[] valueWeightSumsOfSet(HashSet set){
        int[] sums = new int[]{0, 0};
        for(Object o : set){
            Item item = (Item)o;

            sums[0] += item.getValue();
            sums[1] += item.getWeight();
        }
        return sums;
    }

    private void dynamicAlgorithm(){
        // on rempli la kTable
        for(int item = 1; item<kTable.length; item++){
            for(int weight = 1; weight<kTable[0].length; weight++){
                // SOURCE: Le if else suivant a été fait a partir du pseudo-code
                // dans le document PDF fourni (instructions générales)

                /*
                    si le poids de l'item actuelle est plus grand que
                    le poids max de la colonne actuelle, alors
                    on ne peut pas rajouter en valeur, on conserve
                    donc la valeur de la case dernière
                    sinon, on prend le max entre :
                        - la valeur de la case dernière et
                        - la valeur de l'item actuel + la valeur de l'item 
                          précédent a la position weight - item.weight
                */
                if (problemItems[item - 1].getWeight() > weight){
                    kTable[item][weight] = kTable[item - 1][weight];
                }
                else{
                    kTable[item][weight] = Math.max(kTable[item - 1][weight], 
                                           problemItems[item - 1].getValue() 
                                           + kTable[item - 1][weight - problemItems[item - 1].getWeight()]);
                }
            }
        }

        /*
            on commence avec la valeur tout en bas a droite (valeur optimale <=> item numéro n)
            puis en cherchant item par item du dernier jusqu'a au premier, 
            on trouve nos items pris en soustrayant de value, la valeur de chaque item sélectionné 
            au fur et a mesure tout en vérifiant si la valeur restante vient de la ligne d'en haut ou non 
            ce qui veut dire que l'on prend pas l'item actuel
        */
        int value = kTable[kTable.length-1][kTable[0].length-1];
        for(int row = kTable.length-1; row>0; row--){
            // on utilise la méthode helper searchRowForValue(row, value) afin de voir
            // si une valeur vient de la ligne au dessus d'elle ou non
            if(!searchRowForValue(row - 1, value) && value > 0){
                value -= problemItems[row - 1].getValue();

                knapsack.addToSack(problemItems[row - 1]);
            }
        }
    }
    // helper method pour la solution dynamique
    private boolean searchRowForValue(int row, int value){
        for(int weight = 1; weight<kTable[row].length; weight++){
            if(kTable[row][weight] == value) return true;
        }
        return false;
    }

    // sauvegarde la solution dans un fichier .sol dans le format spécifié
    private void saveSolution(String inputFilename) throws IOException{
        File resultsFile = new File(inputFilename + ".sol");

        if(resultsFile.createNewFile()){
            FileWriter fileWriter = new FileWriter(resultsFile.getName());

            String resultInfo = "";
            for(Item item : knapsack.values()){
                resultInfo += (" " + item.getId());
            }

            fileWriter.write(knapsack.getCurrentValue() + "\n");
            fileWriter.write(resultInfo.trim());

            fileWriter.close();
        }
    }
}