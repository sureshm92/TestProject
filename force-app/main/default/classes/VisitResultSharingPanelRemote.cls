/**
 * Created by Leonid Bartenev
 */

public without sharing class VisitResultSharingPanelRemote {
    
    public class VisitResultGroupWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public List<VisitResultWrapper> visitResults;
    }
    
    public class VisitResultWrapper{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String type;
        @AuraEnabled public String countryCodes;
        
        public VisitResultWrapper(String label, String value, String type, String countryCodes){
            this.label = label;
            this.value = value;
            this.type = type;
            this.countryCodes = countryCodes;
        }
    }
    
    public class OptionsWrapper{
        @AuraEnabled public String ssSelectionType;
        @AuraEnabled public List<LabelValueItem> ssSelectionTypeLVList = new List<LabelValueItem>{
                new LabelValueItem('Enabled for all study sites', 'All'),
                new LabelValueItem('Enabled for selected study sites', 'Study Sites')
        };
        @AuraEnabled public String selectedSSIds;
        @AuraEnabled public String participantDefault = 'Opt in';
        @AuraEnabled public List<LabelValueItem> participantDefaultLVList = new List<LabelValueItem>{
                new LabelValueItem('Opt in', 'Opt in'),
                new LabelValueItem('Opt out', 'Opt out')
        };
        @AuraEnabled public String whenToShow = 'Immediate';
        @AuraEnabled public List<LabelValueItem> whenToShowLVList = new List<LabelValueItem>{
                new LabelValueItem('Immediate', 'Immediate'),
                new LabelValueItem('Show after', 'After')
        };
        @AuraEnabled public Integer showAfterDays;
        @AuraEnabled public String statusBasedType = 'All statuses';
        @AuraEnabled public List<LabelValueItem> statesBasedTypeLVList = new List<LabelValueItem>{
                new LabelValueItem('Enabled for all statuses', 'All statuses'),
                new LabelValueItem('Enabled for selected statuses', 'Selected statuses')
        };
        @AuraEnabled public String selectedStatuses = '';
        @AuraEnabled public Boolean globalShareBck = true;
        
    }
    
    public class InitData{
        @AuraEnabled public List<VisitResultGroupWrapper> groups;
        @AuraEnabled public List<LabelValueItem> typeSelectLVList = new List<LabelValueItem>{
                new LabelValueItem('Disabled for all countries', 'Disabled'),
                new LabelValueItem('Enabled for all countries', 'All'),
                new LabelValueItem('Enabled for selected countries', 'Countries')
        };
        @AuraEnabled public OptionsWrapper options;
    }
    
    @AuraEnabled
    public static InitData getInitData(){
       try{
           InitData initData = new InitData();
           initData.groups = new List<VisitResultGroupWrapper>();
           
           
           List<Visit_Result_GroupM__mdt> resultGroups = [
                   SELECT Id, Label, (SELECT Id, Label, Visit_Result_Code__c FROM Visit_Result_Types__r)
                   FROM Visit_Result_GroupM__mdt
           ];
           
           for(Visit_Result_GroupM__mdt resultGroup : resultGroups){
               VisitResultGroupWrapper resultGroupWrapper = new VisitResultGroupWrapper();
               resultGroupWrapper.label = resultGroup.label;
               resultGroupWrapper.visitResults = new List<VisitResultWrapper>();
               for(Visit_Result_TypeM__mdt visitResultType : resultGroup.Visit_Result_Types__r){
                   resultGroupWrapper.visitResults.add(new VisitResultWrapper(
                           visitResultType.Label,
                           visitResultType.Visit_Result_Code__c,
                           'Disabled',
                           ''
                   ));
               }
               initData.groups.add(resultGroupWrapper);
           }
           
           initData.options = new OptionsWrapper();
           initData.options.ssSelectionType = 'All';
           initData.options.showAfterDays = 1;
           return initData;
       }catch (Exception e){
           return (InitData)AuraHelper.throwException(e);
       }
    }

}