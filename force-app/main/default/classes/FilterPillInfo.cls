/**
 * Created by D.Yasinskyi on 24.04.2018
 */
public without sharing class FilterPillInfo {

    public Integer value;
    public String label;
    Boolean isActive;

    public FilterPillInfo(Integer value, String label) {
        this(value, label, false);
    }
    public FilterPillInfo(Integer value, String label, Boolean isActive) {
        this.value = value;
        this.label = label;
        this.isActive = isActive;
    }
}