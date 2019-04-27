/**
 * Created by Igor Malyuta on 11.04.2019.
 */

public with sharing class ParticipantVisitsRemote {

    public static final Map<String, String> LABELS_MAP = new Map<String, String> {
            'Questionnaires' => Label.StudyVisit_Legend_Questions,
            'Brief physical examination' => Label.StudyVisit_Legend_Brief_Physical_Examination,
            'Electrocardiogram (ECG)' => Label.StudyVisit_Legend_ECG,
            'Vital signs' => Label.StudyVisit_Legend_Vital_Signs,
            'Blood and urine tests' => Label.StudyVisit_Legend_Blood,
            'Pregnancy test' => Label.StudyVisit_Legend_Pregnancy_Test,
            'Joint assessment' => Label.StudyVisit_Legend_Joint_Assessment,
            'Lung function test' => Label.StudyVisit_Legend_Lung_Function_Test,
            'Lung health check' => Label.StudyVisit_Legend_Lung_Health_Check,
            'Chest, hand, and feet X-rays' => Label.StudyVisit_Legend_X_Rays,
            'Questions' => Label.StudyVisit_Legend_Questions2
    };

    @AuraEnabled
    public static String getVisitsPreview() {
        try{
            return JSON.serialize(VisitService.getInstance().getPreviewVisits());
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getParticipantVisits() {
        try{
            return JSON.serialize(VisitService.getInstance().getVisits(null));
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getVisitsLegend() {
        try{
            List<PicklistEntry> picklistEntries = Visit__c.Icons__c.getDescribe().picklistValues;
            List<Legend> legends = new List<ParticipantVisitsRemote.Legend>();
            for(PicklistEntry entry : picklistEntries) {
                Legend leg = new Legend();
                leg.iconId = entry.value;
                leg.iconLabel = entry.label;
                leg.iconLegend = LABELS_MAP.get(entry.label);
                legends.add(leg);
            }

            return JSON.serialize(legends);
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public class Legend {
        public String iconId;
        public String iconLabel;
        public String iconLegend;
    }
}