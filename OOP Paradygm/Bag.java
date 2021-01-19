import java.util.ArrayList;

public class Bag{
    private int maxWeightCapacity;
    private int currentWeight;
    private int currentValue;
    private ArrayList<Item> content;

    public Bag(int maxWeightCapacity, int numOfProblemItems){
        this.maxWeightCapacity = maxWeightCapacity;
        content = new ArrayList<Item>(numOfProblemItems);
    }

    public int getCurrentWeight(){ return currentWeight; }
    public int getCurrentValue(){ return currentValue; }

    public int getMaxWeightCapacity(){ return maxWeightCapacity; }


    public void addToBag(Item newItem){
        // no condition ? no nothing ?

        content.add(newItem);

        currentWeight += newItem.getWeight();
        currentValue += newItem.getValue();
    }
    public void removeFromBag(Item item){
        // no condition ? no nothing ?        

        content.remove(item); 

        currentWeight -= item.getWeight();
        currentValue -= item.getValue();
    }

    public Item[] values(){
        Object[] contentArray = content.toArray();

        Item[] result = new Item[content.size()];
        for(int i = 0; i<result.length; i++){
            result[i] = (Item)contentArray[i];
        }
        return result;
    }

    @Override
    public String toString(){
        return "(" + 
                maxWeightCapacity + "," + 
                currentValue + "," + 
                currentWeight + "," + 
                content.toString() + 
               ")";
    }
}