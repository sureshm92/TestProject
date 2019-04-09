/**
 * Created by Leonid Bartenev
 */

public without sharing class LanguageSwitcherRemote {
    
    public class InitData{
        String languageKey;
        List<LabelValueItem> languages = new List<LabelValueItem>();
        String localeKey;
        List<LabelValueItem> locales = new List<LabelValueItem>();
    }
    
    @AuraEnabled
    public static String getInitData(){
        try{
            InitData initData = new InitData();
            List<PicklistEntry> listPLE = Translation__c.Language__c.getDescribe().getPicklistValues();
            for(PicklistEntry ple : listPLE){
                initData.languages.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
            listPLE = User.LocaleSidKey.getDescribe().getPicklistValues();
            for(PicklistEntry ple : listPLE){
                initData.locales.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
            }
            initData.languageKey = UserInfo.getLanguage();
            initData.localeKey = UserInfo.getLocale();
            return JSON.serialize(initData);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static void changeLanguage(String languageKey, String localeKey){
        try{
            update new User(
                    Id = UserInfo.getUserId(),
                    LanguageLocaleKey = languageKey,
                    LocaleSidKey = localeKey
            );
            //TODO Move this to another place:
            List<Task> tasks = TaskService.getTasksCommon('Task_Code__c =\'' + TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE +'\' AND ' + TaskService.getOpenTasksFilter());
            if(tasks.size() > 0){
                TaskService.completeTask(tasks[0]);
                update tasks[0];
            }
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

}