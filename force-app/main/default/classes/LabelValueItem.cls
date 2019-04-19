/**
 * Created by Leonid Bartenev
 */

public without sharing class LabelValueItem {
    @AuraEnabled public String label;
    @AuraEnabled public String value;

    public LabelValueItem(String label, String value){
        this.label = label;
        this.value = value;
    } 
}