public class Item{
    private String itemId;
    private int value;
    private int weight;

    public Item(String itemId, int value, int weight){
        this.itemId = itemId;
        this.value = value;
        this.weight = weight;
    }

    public String getId(){ return itemId; }
    public int getWeight(){ return weight; }
    public int getValue(){ return value; }
}