/**
 * Created by Igor Malyuta on 24.11.2019.
 */

public without sharing class ValueStateItem implements Comparable {
    @AuraEnabled public String value;
    @AuraEnabled public Boolean state;
    @AuraEnabled public Boolean initialState;
    @AuraEnabled public Id sourceId;

    public ValueStateItem(String value, Boolean state) {
        this.value = value;
        this.state = state;
        this.initialState = state;
    }

    public ValueStateItem(String value, Id sourceId) {
        this.value = value;
        this.state = sourceId != null;
        this.sourceId = sourceId;
    }

    public Integer compareTo(Object compareTo) {
        String compareValue = ((ValueStateItem) compareTo).value;
        if (this.value > compareValue) return 1;
        if (this.value < compareValue) return -1;

        return 0;
    }
}