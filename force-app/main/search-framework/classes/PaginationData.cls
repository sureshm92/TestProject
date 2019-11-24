/**
 * Created by Leonid Bartenev
 */

public without sharing class PaginationData {
    
    @AuraEnabled public Integer allRecordsCount;
    @AuraEnabled public Integer pagesCount;
    @AuraEnabled public Integer pageRecordsCount;
    @AuraEnabled public Integer currentPage;
    @AuraEnabled public Integer offset;
    @AuraEnabled public Integer endOffset;
    @AuraEnabled public Integer currentPageCount;
    @AuraEnabled public List<LabelValueItem> pages;
    @AuraEnabled public List<LabelValueItem> recordCountVariants;

    public PaginationData(){
        currentPage = 1;
        pageRecordsCount = 10;
        recordCountVariants =new List<LabelValueItem>{
                new LabelValueItem('5', '5'),
                new LabelValueItem('10', '10'),
                new LabelValueItem('25', '25'),
                new LabelValueItem('50', '50')
        };
    }

    public void setRecordsCount(Integer recordsCount){
        allRecordsCount = recordsCount;
        reCalc();
    }

    public void reCalc(){
        System.debug('PAGE DATA:' + JSON.serialize(this));
        Decimal allRecDecimal = allRecordsCount;
        Decimal pageRacordsCountDecimal = pageRecordsCount;
        Decimal allPagesDecimal = allRecDecimal / pageRacordsCountDecimal;
        allPagesDecimal = allPagesDecimal.round(System.RoundingMode.UP);
        pagesCount = allPagesDecimal.intValue();
        if(currentPage > pagesCount) currentPage = 1;
        offset = (currentPage - 1) * pageRecordsCount;
        endOffset = offset + pageRecordsCount;
        if(endOffset > allRecordsCount) endOffset = allRecordsCount;
        currentPageCount = endOffset - offset;
        System.debug('PAGE DATA:' + JSON.serialize(this));
    }
    
}