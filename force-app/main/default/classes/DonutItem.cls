/**
 * Created by Leonid Bartenev
 */

public class DonutItem {
    
    public enum Type {SUCCSESS, DECLINED, PENDING, ON_HOLD}
    public static Map<Type, String> COLOR_MAP = new Map<DonutItem.Type, String>{
            DonutItem.Type.SUCCSESS => '#00C221',
            DonutItem.Type.ON_HOLD => '#FF9300',
            DonutItem.Type.DECLINED => '#E20000',
            DonutItem.Type.PENDING => '#297DFD'
    };
    
    public String segment;
    public Integer value;
    public String color;
    
    public DonutItem(String segment, Integer value, DonutItem.Type donutItemType){
        this.segment = segment;
        this.value = value;
        this.color = COLOR_MAP.get(donutItemType);
    }
}