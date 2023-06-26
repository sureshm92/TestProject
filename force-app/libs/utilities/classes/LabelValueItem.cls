/**
 * Created by Leonid Bartenev
 */

public without sharing class LabelValueItem implements Comparable {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;

    public LabelValueItem(String label, String value) {
        this.label = label;
        this.value = value;
    }
     public Integer compareTo(Object item){
        LabelValueItem labelValuePair =(LabelValueItem)item;
        return label.compareTo(labelValuePair.label);
    }
}
