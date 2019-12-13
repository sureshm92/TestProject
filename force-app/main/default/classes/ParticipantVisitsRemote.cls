/**
 * Created by Igor Malyuta on 11.04.2019.
 */

public without sharing class ParticipantVisitsRemote {

    @AuraEnabled
    public static Boolean isStudySiteHasVisits(){
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                    .getVisitWrappers(PatientVisitService.VISIT_MODE_ALL, null).size() > 0 ? true : false;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

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

    @AuraEnabled(Cacheable = true)
    public static List<Patient_Visit__c> getCardPatientVisits() {
        try {
            return PatientVisitService.getPatientCardVisits(ParticipantService.getParticipantState().pe.Id);
        } catch (Exception e) {
            return (List<Patient_Visit__c>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePatientVisit(String visit) {
        try {
            Patient_Visit__c patientVisit = (Patient_Visit__c) JSON.deserialize(visit, Patient_Visit__c.class);
            update patientVisit;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getVisitsLegend(String iconNames) {
        try {
            List<Legend> legends = new List<Legend>();
            ParticipantService.ParticipantState state =
                    ((ParticipantService) ClassFactory.newInstance(ParticipantService.class)).getState();
            if(String.isNotBlank(iconNames) && state.pe != null && state.pe.Visit_Plan__c != null) {
                String query = 'SELECT Id, ' +
                        'Name, ' +
                        'Label__c, ' +
                        'Description__c ' +
                        'FROM Icon_Details__c ' +
                        'WHERE Name IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(iconNames.split(';'))) + ') ' +
                            'AND Visit_Plan__c = \'' + state.pe.Visit_Plan__c + '\'';
                List<Icon_Details__c> iconsDetails =
                        ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class)).query(query, true);
                TranslateHelper.translate(iconsDetails, IRBParticipantService.getSuitableLanguageForIRBTranslation(state.pe.Id));

                for (Icon_Details__c iconDetails : iconsDetails) {
                    Legend leg = new Legend();
                    leg.iconId = iconDetails.Name;
                    leg.iconLabel = iconDetails.Label__c;
                    leg.iconLegend = iconDetails.Description__c;
                    legends.add(leg);
                }
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