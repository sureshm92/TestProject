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
    public static List<PatientVisitService.VisitWrapper> getVisitsPreview() {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class)).getVisitWrappers(PatientVisitService.VISIT_MODE_CURRENT, 3);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<PatientVisitService.VisitWrapper> getParticipantVisits(String visitMode) {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class)).getVisitWrappers(visitMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static String getVisitsLegend(String iconNames) {
        try {
            String query = 'SELECT Id, ' +
                    'Name, ' +
                    'Label__c, ' +
                    'Description__c ' +
                    'FROM Icon_Details__c ' +
                    'WHERE Name IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(iconNames.split(';'))) + ')';
            List<Icon_Details__c> iconsDetails = ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(query, true);
            List<Legend> legends = new List<Legend>();
            for (Icon_Details__c iconDetails : iconsDetails) {
                Legend leg = new Legend();
                leg.iconId = iconDetails.Name;
                leg.iconLabel = iconDetails.Label__c;
                leg.iconLegend = iconDetails.Description__c;
                legends.add(leg);
            }
            return JSON.serialize(legends);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public class Legend {
        public String iconId;
        public String iconLabel;
        public String iconLegend;
    }
}