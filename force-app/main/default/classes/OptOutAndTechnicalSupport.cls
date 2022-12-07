global without sharing class OptOutAndTechnicalSupport {
    public static final String DEFAULT_LANGUAGE = 'en_us';
    public static final String CASE_TYPE_Priority = 'Privacy';
    public static final String CASE_TYPE_TECHSUPPORT = 'Technical Support';
    public static final String TECH_SUPPORT_QUEUE_NAME = 'Tech_Support_Case_Queue';
    public static final String CASE_ORIGIN_OPT_OUT = 'Opt Out';

    public static List<InitDataWrapper> getOptoutAndTechnicalSupportData(String strlanguage) {
        List<InitDataWrapper> wrapperList = new List<InitDataWrapper>();
        String communityName = UserContext.getCurrentCommunityName();
        Map<Id, Opt_Out_and_Technical_Support_Category__mdt> categoryMap ;
        if(communityName == 'IQVIA Patient Portal'){
            categoryMap = new Map<Id, Opt_Out_and_Technical_Support_Category__mdt>(
                [
                    SELECT Id, developerName, Title__c, Community_Name__c, Display_Order__c
                    FROM Opt_Out_and_Technical_Support_Category__mdt where Community_Name__c = 'IQVIA Patient Portal' ORDER BY Display_Order__c ASC
                ]
            );
        }
       else{
            categoryMap = new Map<Id, Opt_Out_and_Technical_Support_Category__mdt>(
                [
                    SELECT Id, developerName, Title__c, Community_Name__c, Display_Order__c
                    FROM Opt_Out_and_Technical_Support_Category__mdt where Community_Name__c != 'IQVIA Patient Portal' ORDER BY Display_Order__c ASC
                ]
            );
       }
        
        List<Opt_Out_And_Tech_Support_Subcategory__mdt> subCategoryList = [
            SELECT
                Id,
                developerName,
                Title__c,
                Display_Order__c,
                Opt_Out_and_Technical_Support_Category__c,
                Opt_Out_and_Tech_Support_UI_Category__c,
                Opt_Out_and_Technical_Support_Category__r.Title__c
            FROM Opt_Out_And_Tech_Support_Subcategory__mdt
            WHERE Opt_Out_and_Tech_Support_UI_Category__c IN :categoryMap.keyset()
            ORDER BY Display_Order__c ASC
        ];
        Map<Id, List<Opt_Out_And_Tech_Support_Subcategory__mdt>> categorySubcategoryMap = new Map<Id, List<Opt_Out_And_Tech_Support_Subcategory__mdt>>();

        for (Opt_Out_And_Tech_Support_Subcategory__mdt objSubCategory : subCategoryList) {
            if (
                categorySubcategoryMap.containsKey(
                    objSubCategory.Opt_Out_and_Tech_Support_UI_Category__c
                )
            ) {
                categorySubcategoryMap.get(objSubCategory.Opt_Out_and_Tech_Support_UI_Category__c)
                    .add(objSubCategory);
            } else {
                categorySubcategoryMap.put(
                    objSubCategory.Opt_Out_and_Tech_Support_UI_Category__c,
                    new List<Opt_Out_And_Tech_Support_Subcategory__mdt>{ objSubCategory }
                );
            }
        }
        for (Opt_Out_and_Technical_Support_Category__mdt objCategory : categoryMap.values()) {
            String translatedUICategoryValue = TranslateHelper.getLabelValue(
                objCategory.Title__c,
                strLanguage
            );
            String strOriginalUICategory = TranslateHelper.getLabelValue(
                objCategory.Title__c,
                DEFAULT_LANGUAGE
            );
            List<LabelValueItem> labelValueItemList = new List<LabelValueItem>();
            for (
                Opt_Out_And_Tech_Support_Subcategory__mdt objSubCategory : categorySubcategoryMap.get(
                    objCategory.Id
                )
            ) {
                String translatedSubCategoryValue = TranslateHelper.getLabelValue(
                    objSubCategory.Title__c,
                    strLanguage
                );
                String originalSubCategoryValue = TranslateHelper.getLabelValue(
                    objSubCategory.Title__c,
                    DEFAULT_LANGUAGE
                );
                String strActualCategoryValue = TranslateHelper.getLabelValue(
                    objSubCategory.Opt_Out_and_Technical_Support_Category__r.Title__c,
                    DEFAULT_LANGUAGE
                );
                LabelValueItem objLabelValueItem = new LabelValueItem(
                    translatedSubCategoryValue,
                    originalSubCategoryValue +
                    '-' +
                    strActualCategoryValue
                );
                labelValueItemList.add(objLabelValueItem);
            }
            wrapperList.add(
                new InitDataWrapper(
                    translatedUICategoryValue,
                    labelValueItemList,
                    strOriginalUICategory
                )
            );
        }

        return wrapperList;
    }
    public static void createSupportCases(
        List<String> optOutValueList,
        List<String> techSupportValueList,
        String strContactId
    ) {
        List<Case> caseList = new List<Case>();
        String strOptOutValue = '';
        String strTechSupportValue = '';
        String strOptOutCategory = Label.Opt_Out;
        String strTechSupportCategory = Label.Technical_Support;

        if (!String.isBlank(strContactId)) {
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :strContactId LIMIT 1];
            List<Group> groupList = [
                SELECT Id, Name
                FROM Group
                WHERE developerName = :TECH_SUPPORT_QUEUE_NAME
                LIMIT 1
            ];
            if (!conList.isEmpty() && !groupList.isEmpty()) {
                for (String strOptOut : optOutValueList) {
                    if (String.isBlank(strOptOutValue)) {
                        strOptOutValue = strOptOut.substringBefore('-');
                    } else {
                        strOptOutValue = strOptOutValue + ',' + strOptOut.substringBefore('-');
                    }
                }
                for (String strTechSupport : techSupportValueList) {
                    if (
                        !String.isBlank(strTechSupport.substringAfter('-')) &&
                        strTechSupport.substringAfter('-').equalsIgnoreCase(strTechSupportCategory)
                    ) {
                        if (String.isBlank(strTechSupportValue)) {
                            strTechSupportValue = strTechSupport.substringBefore('-');
                        } else {
                            strTechSupportValue =
                                strTechSupportValue +
                                ',' +
                                strTechSupport.substringBefore('-');
                        }
                    } else {
                        if (String.isBlank(strOptOutValue)) {
                            strOptOutValue = strTechSupport.substringBefore('-');
                        } else {
                            strOptOutValue =
                                strOptOutValue +
                                ',' +
                                strTechSupport.substringBefore('-');
                        }
                    }
                }
                if (!String.isBlank(strOptOutValue)) {
                    Case objOptOutCase = new Case(
                        subject = CASE_TYPE_Priority,
                        ContactId = conList[0].Id,
                        Description = strOptOutValue,
                        ownerId = groupList[0].Id,
                        Type = CASE_TYPE_Priority,
                        Origin = CASE_ORIGIN_OPT_OUT
                    );
                    caseList.add(objOptOutCase);
                }
                if (!String.isBlank(strTechSupportValue)) {
                    Case objTechSupportCase = new Case(
                        subject = CASE_TYPE_TECHSUPPORT,
                        ContactId = conList[0].Id,
                        Description = strTechSupportValue,
                        ownerId = groupList[0].Id,
                        Type = CASE_TYPE_TECHSUPPORT,
                        Origin = CASE_ORIGIN_OPT_OUT
                    );
                    caseList.add(objTechSupportCase);
                }
                insert caseList;
            }
        }
    }
    public class InitDataWrapper {
        @AuraEnabled
        public String strTranslatedCategoryValue;
        @AuraEnabled
        public List<LabelValueItem> labelValueItemList;
        @Auraenabled
        public String strCategoryValue;

        public InitDataWrapper(
            String strTranslatedCategoryValue,
            List<LabelValueItem> labelValueItemList,
            String strCategoryValue
        ) {
            this.strTranslatedCategoryValue = strTranslatedCategoryValue;
            this.labelValueItemList = labelValueItemList;
            this.strCategoryValue = strCategoryValue;
        }
    }
}
