import java.util.Scanner;
import java.util.Arrays;
import java.util.HashSet;

import java.io.File;
import java.io.FileWriter;
import java.io.FileNotFoundException;
import java.io.IOException;

import java.lang.Math;

public class KnapsackProblem{
    private Scanner scanner;

    private Item[] problemItems;
    private Bag bag;

    public static void main(String[] args) throws FileNotFoundException, IOException{
        KnapsackProblem ksp = new KnapsackProblem();

        ksp.init(args[0]);
        ksp.chooseSolvingMethod(args[1]);
        ksp.saveSolution(args[0].split("\\.")[0]);
    }

    public void init(String fileName) throws FileNotFoundException{
        scanner = new Scanner(new File(fileName));

        problemItems = new Item[Integer.parseInt(scanner.next())];
        for(int i = 0; i<problemItems.length; i++){
            scanner.nextLine();

            problemItems[i] = new Item(scanner.next().charAt(0),
                                       Integer.parseInt(scanner.next()),
                                       Integer.parseInt(scanner.next()));
        }
        //System.out.println("Problem Items : " + Arrays.toString(problemItems));
        scanner.nextLine();

        bag = new Bag(Integer.parseInt(scanner.next()), 
                      problemItems.length);
    }

    private void chooseSolvingMethod(String choice){
        if(choice.equals("F")) bruteForce();
        else if(choice.equals("D")) dynamicAlgorithm();
        else{
            System.out.println("Choix invalide ! Choisissez F ou D.");
        }
    }

    public void bruteForce(){
        HashSet<Item> bestSolution = new HashSet<Item>(problemItems.length);

        int bestValue = 0;
        HashSet<HashSet<Item>> powerSet = generatePowerSet();
        for(HashSet subset : powerSet){
            //System.out.println("current set : " + subset.toString());

            int[] valueWeightSums = valueWeightSumsOfSet(subset);
            //System.out.println(valueWeightSums[0] + " " + valueWeightSums[1]);
            //System.out.println((valueWeightSums[0] > bestValue) + " " 
            //                    + (valueWeightSums[1] < bag.getMaxWeightCapacity()));
            if(valueWeightSums[0] > bestValue &&
               valueWeightSums[1] <= bag.getMaxWeightCapacity()){
                //System.out.println("override");

                bestValue = valueWeightSums[0];
                
                bestSolution = (HashSet<Item>)subset.clone();
            }
        }

        for(Item item : bestSolution){ bag.addToBag(item); }
        //System.out.println(bestSolution.toString());
        //System.out.println(bag.toString());
    }
    private HashSet<HashSet<Item>> generatePowerSet(){
        HashSet<HashSet<Item>> powerSet = new HashSet<HashSet<Item>>
                                          ((int)Math.pow(2, problemItems.length));

        for(int ctr = 0; ctr<Math.pow(2, problemItems.length); ctr++){
            String[] binaryNum = convertDecimalToBinary(ctr);

            HashSet<Item> subset = new HashSet<Item>(problemItems.length);
            for(int j = 0; j<binaryNum.length; j++){
                if(binaryNum[j].equals("1")){
                    subset.add(problemItems[j]);
                }
            }
            powerSet.add(subset);
        }

        return powerSet;
    }
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
    private int[] valueWeightSumsOfSet(HashSet set){
        int[] sums = new int[]{0, 0};
        for(Object o : set){
            Item item = (Item)o;

            sums[0] += item.getValue();
            sums[1] += item.getWeight();
        }
        return sums;
    }

    public void dynamicAlgorithm(){
        System.out.println("dynamic programming method");
    }

    public void saveSolution(String inputFilename) throws IOException{
        File resultsFile = new File(inputFilename + ".sol");

        if(resultsFile.createNewFile()){
            FileWriter fileWriter = new FileWriter(resultsFile.getName());

            String resultInfo = "";
            for(Item item : bag.values()){
                resultInfo += (" " + item.getId());
            }

            fileWriter.write(bag.getCurrentValue() + "\n");
            fileWriter.write(resultInfo.trim());

            fileWriter.close();
        }
    }
}