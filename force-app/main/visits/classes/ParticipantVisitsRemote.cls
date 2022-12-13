/**
 * Created by Igor Malyuta on 11.04.2019.
 */

public without sharing class ParticipantVisitsRemote {
    @AuraEnabled
    public static Boolean isStudySiteHasVisits() {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                    .getVisitWrappers(PatientVisitService.VISIT_MODE_ALL, null)
                    .size() > 0
                ? true
                : false;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<PatientVisitService.VisitWrapper> getVisitsPreview() {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getVisitWrappers(PatientVisitService.VISIT_MODE_CURRENT, 5);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static VisitAndCountWrapper getVisitsPreviewAndCount() {
        try {
            ParticipantService.ParticipantState pState = ((ParticipantService) ClassFactory.newInstance(
                ParticipantService.class
            ))
            .getState();
            VisitAndCountWrapper visitAndCount = new VisitAndCountWrapper();
            visitAndCount.showVisits = pState.showVisits;
            List<String> additionalFields = new List<String>();
            additionalFields.add('Participant_Enrollment__r.Study_Site__r.Site__r.BillingAddress');
            additionalFields.add('Participant_Enrollment__r.Study_Site__r.Site__r.Name');
            additionalFields.add('Participant_Enrollment__r.Study_Site__r.Site__r.Phone');
            visitAndCount.visitPreviewList = ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getVisitWrappers(PatientVisitService.VISIT_MODE_CURRENT, 5, additionalFields);
            return visitAndCount;

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    public class VisitAndCountWrapper {
        @AuraEnabled
        public List<PatientVisitService.VisitWrapper>  visitPreviewList;
        @AuraEnabled
        public Boolean showVisits;
    }

    @AuraEnabled
    public static String getSiteAddress() {
        String accountData;
        try {
            Id userId = UserInfo.getUserId();
            Id contactId = [SELECT Id, Contact.Id FROM User WHERE Id = :userId].Contact.Id;
            List<Contact> siteData = [
                SELECT
                    Id,
                    Account.Name,
                    Account.Phone,
                    Account.BillingStreet,
                    Account.BillingCity,
                    Account.Billingstate,
                    Account.BillingCountry,
                    Account.BillingPostalCode
                FROM Contact
                WHERE Id = :contactId
            ];
            String[] addr = new List<String>{
                siteData[0].Account.BillingStreet,
                siteData[0].Account.BillingCity,
                siteData[0].Account.Billingstate,
                siteData[0].Account.BillingCountry,
                siteData[0].Account.BillingPostalCode
            };
            for (Integer i = 4; i >= 0; i--) {
                if (addr[i] == null) {
                    addr.remove(i);
                }
            }
            AccountData acc = new AccountData();
            acc.accountName = siteData[0].Account.Name;
            acc.accountPhone = siteData[0].Account.Phone;
            acc.accountAddress = String.join(addr, ',');
            accountData = JSON.serializePretty(acc);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return accountData;
    }

    public class AccountData {
        String accountName;
        String accountAddress;
        String accountPhone;
    }

    @AuraEnabled
    public static List<PatientVisitService.VisitWrapper> getParticipantVisits(String visitMode) {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getVisitWrappers(visitMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static PatientVisitService.PatientVisitsAndEvent getParticipantVisitsAndStudyType(String visitMode) {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getVisitWrappersAndStudyType(visitMode);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<PatientVisitService.VisitWrapper> getParticipantVisitsDetails(Id visitId) {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getVisitDetails(visitId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<Patient_Visit__c> getPatientVisitsDetails(Id visitId) {
        try {
            return ((PatientVisitService) ClassFactory.newInstance(PatientVisitService.class))
                .getPatientVisitDetails(visitId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static Boolean getIsRTL() {
        try {
            return (System.Label.RTL_Languages).contains(UserInfo.getLanguage());
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static Boolean getIsVisitPathEnabled() {
        ParticipantService.ParticipantState state = ParticipantService.getInstance().getState();
        return state.isVisitPathEnabled;
    }

    @AuraEnabled
    public static List<Patient_Visit__c> getCardPatientVisits() {
        try {
            return PatientVisitService.getPatientCardVisits(
                ParticipantService.getParticipantState().pe.Id
            );
        } catch (Exception e) {
            return (List<Patient_Visit__c>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void updatePatientVisit(String visit) {
        try {
            Patient_Visit__c patientVisit = (Patient_Visit__c) JSON.deserialize(
                visit,
                Patient_Visit__c.class
            );
            update patientVisit;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<Icon_Details__c> getVisitIconsbyName(Id visitId) {
        
        Id visitPlanId;
        List<Icon_Details__c> iconDetails = new List<Icon_Details__c>();
        List<Patient_Visit__c> visits = [
            SELECT Id, Visit__c, Visit__r.Visit_Plan__c, Completed_Date__c, Visit__r.Icons__c
            FROM Patient_Visit__c
            WHERE Id = :visitId
        ];
        for (Patient_Visit__c visit : visits) {
            if (visit.Visit__c != null && visit.Visit__r.Visit_Plan__c != null) {
                visitPlanId = visit.Visit__r.Visit_Plan__c;
                break;
            }
        }
        String icons;
        List<String> iconNames = new List<String>();
        if (visits[0].Visit__c != null) {
            icons = visits[0].Visit__r.Icons__c;
            if (visits[0].Visit__r != null && visits[0].Visit__r.Icons__c != null)
                iconNames = visits[0].Visit__r.Icons__c.split(';');
        }
        iconDetails = [
            SELECT Id, Name, Label__c, Description__c
            FROM Icon_Details__c
            WHERE Name IN :iconNames AND Visit_Plan__c = :visitPlanId
        ];
        TranslateHelper.translate(iconDetails);
        return iconDetails;
    }

    @AuraEnabled
    public static String getVisitsLegend(String iconNames) {
        try {
            List<Legend> legends = new List<Legend>();
            ParticipantService.ParticipantState state = ((ParticipantService) ClassFactory.newInstance(
                    ParticipantService.class
                ))
                .getState();
            if (
                String.isNotBlank(iconNames) &&
                state.pe != null &&
                state.pe.Visit_Plan__c != null
            ) {
                String query =
                    'SELECT Id, ' +
                    'Name, ' +
                    'Label__c, ' +
                    'Description__c ' +
                    'FROM Icon_Details__c ' +
                    'WHERE Name IN (' +
                    CollectionUtil.joinByComa(
                        CollectionUtil.wrapInApostrophes(iconNames.split(';'))
                    ) +
                    ') ' +
                    'AND Visit_Plan__c = \'' +
                    state.pe.Visit_Plan__c +
                    '\'';
                List<Icon_Details__c> iconsDetails = ((DatabaseProxy) ClassFactory.newInstance(
                        DatabaseProxy.class
                    ))
                    .query(query, true);
                TranslateHelper.translate(
                    iconsDetails,
                    IRBParticipantService.getSuitableLanguageForIRBTranslation(state.pe.Id)
                );

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
