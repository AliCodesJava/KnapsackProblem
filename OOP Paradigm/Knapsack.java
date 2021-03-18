import java.util.ArrayList;

public class Knapsack{
    private int maxWeightCapacity;
    private int currentWeight;
    private int currentValue;
    private ArrayList<Item> content;

    // on peut ajouter plus de constructeurs selon les besoins du problème

    public Knapsack(int maxWeightCapacity, int numOfProblemItems){
        // précondition maxWeightCapacity > 0
        this.maxWeightCapacity = maxWeightCapacity;
        /*
            le numOfProblemItems est juste pour définir la capacité initiale
            de content et ne pas gaspiller de la mémoire car on sait que 
            content n'aura jamais plus de n items
        */
        content = new ArrayList<Item>(numOfProblemItems);
    }

    public int getCurrentWeight(){ return currentWeight; }
    public int getCurrentValue(){ return currentValue; }
    public int getMaxWeightCapacity(){ return maxWeightCapacity; }

    /*
        dans les méthodes d'ajout et de remove dans le sac
        on a pas de préconditions car le sac ici est utilisé
        seulement spécifiquement dans le KnapsackProblem
        j'ai donc fait un choix de design qui est de : 
        simplifié cette classe et de la designer pour ce
        problème spécifiquement
    */
    public void addToSack(Item newItem){
        content.add(newItem);

        currentWeight += newItem.getWeight();
        currentValue += newItem.getValue();
    }
    public void removeFromSack(Item item){
        content.remove(item); 

        currentWeight -= item.getWeight();
        currentValue -= item.getValue();
    }

    // retourne une array des valeurs du sac
    public Item[] values(){
        Object[] contentArray = content.toArray();

        Item[] result = new Item[content.size()];
        for(int i = 0; i<result.length; i++){
            result[i] = (Item)contentArray[i];
        }
        return result;
    }
}