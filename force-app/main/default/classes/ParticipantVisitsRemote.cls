/**
 * Created by Igor Malyuta on 11.04.2019.
 */

public with sharing class ParticipantVisitsRemote {

    public static final Map<String, String> LABELS_MAP = new Map<String, String> {
            'Questions about your health and medications' => Label.StudyVisit_Legend_Questions,
            'Brief physical examination' => Label.StudyVisit_Legend_Brief_Physical_Examination,
            'Receive study medication' => Label.StudyVisit_Legend_Receive_Medication,
            'Electrocardiogram (ECG)' => Label.StudyVisit_Legend_ECG,
            'Vital signs, weight and height' => Label.StudyVisit_Legend_Vital_Signs,
            'Blood and urine tests' => Label.StudyVisit_Legend_Blood,
            'Pregnancy test' => Label.StudyVisit_Legend_Pregnancy_Test,
            'Return study medication' => Label.StudyVisit_Legend_Return_Medication,
            'No food or drink except water for 10 hours prior to visit' => Label.StudyVisit_Legend_No_Food_Or_Drink,
            'Follow Up Period' => Label.StudyVisit_Legend_Follow_Up_Period,
            'Joint Assessment' => Label.StudyVisit_Legend_Joint_Assessment,
            'Lung function test' => Label.StudyVisit_Legend_Lung_Function_Test,
            'Lung health check' => Label.StudyVisit_Legend_Lung_Health_Check,
            'Treatment Period' => Label.StudyVisit_Legend_Treatment_Period,
            'X Rays' => Label.StudyVisit_Legend_X_Rays,
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
            List<Visit__c> visits = VisitService.getInstance().getAllVisits();

            PaginationData paginationData = new PaginationData();
            paginationData.pageRecordsCount = 4;
            paginationData.setRecordsCount(visits.size());

            InitData initData = new InitData();
            initData.visits = visits;
            initData.paginationData = paginationData;

            return JSON.serialize(initData);
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

    class InitData {
        public List<Visit__c> visits;
        public PaginationData paginationData;
    }

    class Legend {
        public String iconId;
        public String iconLabel;
        public String iconLegend;
    }
}