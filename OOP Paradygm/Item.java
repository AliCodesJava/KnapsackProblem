public class Item{
    private char itemId;
    private int value;
    private int weight;

    public Item(char itemId, int value, int weight){
        this.itemId = itemId;
        this.value = value;
        this.weight = weight;
    }

    public char getId(){ return itemId; }

    public int getWeight(){ return weight; }
    public int getValue(){ return value; }

    @Override
    public String toString(){
        return "(" + itemId + "," + value + "," + weight + ")";
    }
}   