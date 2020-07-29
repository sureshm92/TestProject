global without sharing class OptOutAndTechnicalSupport{

    public static final String DEFAULT_LANGUAGE='en_us';
    public static final String CASE_TYPE_Priority='Privacy';
    public static final String CASE_TYPE_TECHSUPPORT='Technical Support';
    public static final String TECH_SUPPORT_QUEUE_NAME='Tech_Support_Case_Queue';
    
     public static List<InitDataWrapper> getOptoutAndTechnicalSupportData(String strlanguage){
    
        List<InitDataWrapper> wrapperList=new List<InitDataWrapper>();
        Map<Id,Opt_Out_and_Technical_Support_Category__mdt> categoryMap=new Map<Id,Opt_Out_and_Technical_Support_Category__mdt>([SELECT Id,developerName,Title__c,Display_Order__c  FROM Opt_Out_and_Technical_Support_Category__mdt  Order BY Display_Order__c ASC]);
        List<Opt_Out_And_Tech_Support_Subcategory__mdt> subCategoryList=[SELECT Id,developerName,Title__c,Display_Order__c,Opt_Out_and_Technical_Support_Category__c   FROM Opt_Out_And_Tech_Support_Subcategory__mdt WHERE Opt_Out_and_Technical_Support_Category__c in:categoryMap.keyset() ORDER BY Display_Order__c ASC];
        Map<Id,List<Opt_Out_And_Tech_Support_Subcategory__mdt>> categorySubcategoryMap=new Map<Id,List<Opt_Out_And_Tech_Support_Subcategory__mdt>>();
        
        for(Opt_Out_And_Tech_Support_Subcategory__mdt objSubCategory:subCategoryList){
            if(categorySubcategoryMap.containsKey(objSubCategory.Opt_Out_and_Technical_Support_Category__c)){
                categorySubcategoryMap.get(objSubCategory.Opt_Out_and_Technical_Support_Category__c).add(objSubCategory);
            }
            else{
                categorySubcategoryMap.put(objSubCategory.Opt_Out_and_Technical_Support_Category__c,new List<Opt_Out_And_Tech_Support_Subcategory__mdt>{objSubCategory});
            }
        }
        
        
        for(Opt_Out_and_Technical_Support_Category__mdt objCategory:categoryMap.values()){
            String translatedCategoryValue=TranslateHelper.getLabelValue(objCategory.Title__c,strLanguage);
            String strOriginalCategory=TranslateHelper.getLabelValue(objCategory.Title__c,DEFAULT_LANGUAGE);
            List<LabelValueItem> labelValueItemList=new List<LabelValueItem>();
            for(Opt_Out_And_Tech_Support_Subcategory__mdt objSubCategory:categorySubcategoryMap.get(objCategory.Id)){
                String translatedSubCategoryValue=TranslateHelper.getLabelValue(objSubCategory.Title__c,strLanguage);
                String originalSubCategoryValue=TranslateHelper.getLabelValue(objSubCategory.Title__c,DEFAULT_LANGUAGE);
                LabelValueItem objLabelValueItem=new LabelValueItem(translatedSubCategoryValue,originalSubCategoryValue);
                labelValueItemList.add(objLabelValueItem);
            }
            wrapperList.add(new InitDataWrapper(translatedCategoryValue,labelValueItemList,strOriginalCategory));
        }
        
        return wrapperList;
    
    }
    public static void createSupportCases(String strOptOutValue,String strTechSupportValue,String strContactId){
        List<Case> caseList=new List<Case>();
        if(!String.isBlank(strContactId)){
                List<Contact> conList=[SELECT Id,Name FROM Contact WHERE Id=:strContactId  LIMIT 1];
                List<Group> groupList=[SELECT Id,Name FROM Group WHERE developerName=:TECH_SUPPORT_QUEUE_NAME LIMIT 1];
                if(!conList.isEmpty() && !groupList.isEmpty()){
                    if(!String.isBlank(strOptOutValue)){
                        Case objOptOutCase=new Case(subject=CASE_TYPE_Priority,ContactId=conList[0].Id,Description=strOptOutValue,ownerId=groupList[0].Id,Type=CASE_TYPE_Priority);
                        caseList.add(objOptOutCase);
                    }
                    if(!String.isBlank(strTechSupportValue)){
                        Case objTechSupportCase=new Case(subject=CASE_TYPE_TECHSUPPORT,ContactId=conList[0].Id,Description=strTechSupportValue,ownerId=groupList[0].Id,Type=CASE_TYPE_TECHSUPPORT);
                        caseList.add(objTechSupportCase);
                    }
                    insert caseList;
                }
        }
        
    }
    public class InitDataWrapper{
        @AuraEnabled
        public String strTranslatedCategoryValue;
        @AuraEnabled
        public List<LabelValueItem> labelValueItemList;
        @Auraenabled 
        public String strCategoryValue;
        
        public InitDataWrapper(String strTranslatedCategoryValue,List<LabelValueItem> labelValueItemList,String strCategoryValue){
            this.strTranslatedCategoryValue=strTranslatedCategoryValue;
            this.labelValueItemList=labelValueItemList;
            this.strCategoryValue=strCategoryValue;
            
        }
    }
}