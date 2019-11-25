/**
 * Created by Igor Malyuta on 24.11.2019.
 */

public without sharing class StudySitePageWrapper {

    @AuraEnabled public List<StudySiteItem> studySiteItems;
    @AuraEnabled public Boolean haveEmptyAssigment;
    @AuraEnabled public PaginationData pagination;
    @AuraEnabled public List<LabelValueItem> pageColumnItems;

    public StudySitePageWrapper(){}

    public StudySitePageWrapper(PaginationData pagination, List<LabelValueItem> pageColumnItems) {
        this.pagination = pagination;
        this.pageColumnItems = pageColumnItems;
    }
}