/**
 * Created by Igor Malyuta on 24.11.2019.
 */

public without sharing class ValueStateItem implements Comparable {
    @AuraEnabled public String value;
    @AuraEnabled public Boolean state;

    public ValueStateItem(String value, Boolean state) {
        this.value = value;
        this.state = state;
    }

    public Integer compareTo(Object compareTo) {
        String compareValue = ((ValueStateItem) compareTo).value;
        if (this.value > compareValue) return 1;
        if (this.value < compareValue) return -1;

        return 0;
    }
}