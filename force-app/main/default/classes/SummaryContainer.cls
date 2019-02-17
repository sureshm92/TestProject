/**
 * Created by D.Yasinskyi on 23.04.2018
 */
public without sharing class SummaryContainer {

    public String label;
    public String value;
    public String labelMaxWidth;
    public List<LabelValueItem> items;

    public SummaryContainer(String label, String value){
        this.label = label;
        this.value = value;
        this.items = new List<LabelValueItem>();
    }
}