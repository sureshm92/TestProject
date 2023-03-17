/**
 * Created by Sandeep on 17.03.2023.
 */

public without sharing class Batch_CreatePlatformResourceNotification extends Batch_ScheduledAbstract {
    public Map<Id, ThereaputicAreaLang> resWithTherapeuticAreasMap = new Map<Id, ThereaputicAreaLang>();
    //  public List<ResourceMap> resourceMap;
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Resource__c,
                    Resource__r.Content_Type__c,
                    Resource__r.Content_Class__c,
                    Therapeutic_Area__c,
                    Resource__r.Languages__c,
                    Resource__r.Language__c
                FROM Therapeutic_Area_Assignment__c
                WHERE
                    Resource__r.Content_Type__c = 'Relevant_Link' //platform link
                    OR Resource__r.Content_Class__c = '3rd Party' // alumni or delegate
                    OR Resource__r.Content_Class__c = 'Platform-TA' // active participant
            ]
        );
    }

    public void execute(
        Database.BatchableContext param1,
        List<Therapeutic_Area_Assignment__c> therapeuticAreaAssignmentsList
    ) {
        List<Id> linkResIds = new List<Id>();
        for (Therapeutic_Area_Assignment__c taObj : therapeuticAreaAssignmentsList) {
            if (taObj.Resource__r.Content_Type__c == 'Relevant_Link') {
                linkResIds.add(taObj.Resource__c); // for later purpose
            }
            if (
                taObj.Resource__r.Content_Class__c == '3rd Party' ||
                taObj.Resource__r.Content_Class__c == 'Platform-TA'
            ) {
                if (
                    resWithTherapeuticAreasMap != null &&
                    resWithTherapeuticAreasMap.containsKey(taObj.Resource__c)
                ) {
                    ThereaputicAreaLang taLangObj = resWithTherapeuticAreasMap.get(
                        taObj.Resource__c
                    );
                    taLangObj.therapeuticAreaIds.add(taObj.Therapeutic_Area__c);
                    if (!taLangObj.langCodeList.contains(taObj.Resource__r.Language__c)) {
                        taLangObj.langCodeList =
                            taLangObj.langCodeList +
                            ';' +
                            taObj.Resource__r.Language__c;
                    }
                } else {
                    ThereaputicAreaLang taLang = new ThereaputicAreaLang();
                    taLang.therapeuticAreaIds = new List<Id>{ taObj.Therapeutic_Area__c };
                    taLang.langCodeList = taObj.Resource__r.Language__c;
                    taLang.contentClass = taObj.Resource__r.Content_Class__c;
                    taLang.resourceType = taObj.Resource__r.Content_Type__c;
                    resWithTherapeuticAreasMap.put(taObj.Resource__c, taLang);
                }
            }
        }

        List<Resource__c> platformLevelResLinks = [
            SELECT Id
            FROM Resource__c
            WHERE
                Content_Type__c = 'Relevant_Link'
                AND Id NOT IN (SELECT Resource__c FROM Res_study__c)
                AND Id = :linkResIds
        ];
        for (Therapeutic_Area_Assignment__c taObj : therapeuticAreaAssignmentsList) {
            for (Resource__c resObj : platformLevelResLinks) {
                if (taObj.Resource__c == resObj.Id) {
                    if (
                        resWithTherapeuticAreasMap != null &&
                        resWithTherapeuticAreasMap.containsKey(taObj.Resource__c)
                    ) {
                        ThereaputicAreaLang taLangObj = resWithTherapeuticAreasMap.get(
                            taObj.Resource__c
                        );
                        taLangObj.therapeuticAreaIds.add(taObj.Therapeutic_Area__c);
                        if (!taLangObj.langCodeList.contains(taObj.Resource__r.Languages__c)) {
                            taLangObj.langCodeList =
                                taLangObj.langCodeList +
                                ';' +
                                taObj.Resource__r.Languages__c;
                        }
                    } else {
                        ThereaputicAreaLang taLang = new ThereaputicAreaLang();
                        taLang.therapeuticAreaIds = new List<Id>{ taObj.Therapeutic_Area__c };
                        taLang.langCodeList = taObj.Resource__r.Languages__c;
                        taLang.resourceType = taObj.Resource__r.Content_Type__c;
                        resWithTherapeuticAreasMap.put(taObj.Resource__c, taLang);
                    }
                }
            }
        }
    }

    public override void finalAction() {
        if (resWithTherapeuticAreasMap != null && !resWithTherapeuticAreasMap.isEmpty()) {
            Batch_InsertPlatformResNotification objBatch = new Batch_InsertPlatformResNotification(
                resWithTherapeuticAreasMap
            );
            Database.executeBatch(objBatch, 200);
        }
    }

    public override Type getType() {
        return Batch_CreatePlatformResourceNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job creates update notification when new platform resource is available';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }

    public class ThereaputicAreaLang {
        public List<Id> therapeuticAreaIds;
        public String langCodeList;
        public String contentClass;
        public String resourceType;
    }
}
