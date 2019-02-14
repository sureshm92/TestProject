/**
 * Created by Leonid Bartenev
 */

public without sharing class ParticipantEnrollmentService {

    // Medical Record Review statuses
    public static final String MRR_STATUS_PASS = 'Pass';
    public static final String MRR_STATUS_FAIL = 'Fail';
    public static final String MRR_STATUS_PENDING = 'Pending';
    public static final String MRR_STATUS_NOT_REQUIRED = 'Not Required';
    public static final List<String> MRR_COMPLETION_STATUSES = new List<String>{MRR_STATUS_FAIL, MRR_STATUS_PASS};
    // Pre Eligibility Screening statuses
    public static final String PES_STATUS_PASS = 'Pass';
    public static final String PES_STATUS_FAIL = 'Fail';
    public static final String PES_STATUS_PENDING = 'Pending';
    public static final String PES_STATUS_NOT_REQUIRED = 'Not Required';
    public static final List<String> PES_COMPLETION_STATUSES = new List<String>{PES_STATUS_FAIL, PES_STATUS_PASS};
    // Participant statuses
    public static final String PART_STATUS_PENDING_REFERRAL = 'Pending Referral';
    public static final String PART_STATUS_FAILED_REVIEW = 'Failed Review';
    public static final String PART_STATUS_FAILED_REFERRAL = 'Failed Referral';
    public static final String PART_STATUS_REFERRAL_SENT_TO_PI = 'Referral Sent to PI';
    public static final String PART_STATUS_EXCLUDED_FROM_REFERRING = 'Excluded from Referring';
    // Non referral reason
    public static final String NON_REF_REASON_STATUS_NOT_INTERESTED = 'No Longer Interested';
    public static final String NON_REF_REASON_STATUS_FAILED_PE_SCREENING = 'Failed Pre-Eligibility Screening';
    public static final String NON_REF_REASON_STATUS_HAD_DISC_NOT_INTERESTED = 'Had Discussion, Not Interested';


    public static Participant_Enrollment__c findParticipantEnrollment(HCP_Enrollment__c hcpEnrollment, String participantId){
        //find all participant enrollments for this patientId, clinic and trial
        List<Participant_Enrollment__c> participantEnrollments = [
                SELECT Id, HCP__c, Name,
                        Patient_ID__c,
                        Medical_Record_Review_Status__c,
                        Pre_screening_Status__c,
                        Participant_Status__c,
                        Participant_Name__c,
                        Participant_Surname__c,
                        Referral_Source__c,
                        Screening_ID__c
                FROM Participant_Enrollment__c
                WHERE Study_Site__c != NULL AND  HCP__r.HCP_Contact__r.AccountId =: hcpEnrollment.HCP_Contact__r.AccountId
                AND HCP__r.Study_Site__r.Clinical_Trial_Profile__c =: hcpEnrollment.Study_Site__r.Clinical_Trial_Profile__c
                AND Patient_ID__c =: participantId
        ];
        if(participantEnrollments.size() > 0) return participantEnrollments[0];
        return null;
    }
    
    public static List<Participant_Enrollment__c> getParticipantEnrollmentsForParticipant(){
        return getPEnrolmentsCommon(CommunityService.USER_MODE_PARTICIPANT, null);
    }
    
    public static Participant_Enrollment__c getParticipantEnrollment(Id peId, String userMode){
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommon(userMode, ' AND Id=\'' + peId + '\'');
        if(peList.size() > 0) return peList[0];
        return null;
    }
    
    public static List<Participant_Enrollment__c> getPendingParticipantEnrollments(Id hcpEnrollmentId){
        return getPEnrolmentsCommon(
                CommunityService.USER_MODE_HCP,
                ' AND HCP__c =\'' + hcpEnrollmentId + '\' AND Participant_Status__c = \'' + PART_STATUS_PENDING_REFERRAL + '\''
        );
    }

    public static Map<Id, Integer> getPreScreeningsAllByTrial(Id clinicId){
        return getPECountMapByTrialsForPI(
                'AND Pre_screening_Status__c IN (\'' + String.join(PES_COMPLETION_STATUSES, '\', \'') + '\')' +
                        ' AND HCP__r.HCP_Contact__r.AccountId = \'' + clinicId + '\' '
        );
    }
    
    public static Map<Id, Integer> getPreScreeningsPassedByTrial(Id clinicId){
        return getPECountMapByTrialsForPI(
                'AND Pre_screening_Status__c = \'' + PES_STATUS_PASS + '\' ' +
                        ' AND HCP__r.HCP_Contact__r.AccountId = \'' + clinicId + '\' '
        );
    }
    
    public static Map<Id, Integer> getMRRAllByTrial(Id clinicId){
        return getPECountMapByTrialsForPI(
                'AND Medical_Record_Review_Status__c IN (\'' + String.join(MRR_COMPLETION_STATUSES, '\', \'') + '\')' +
                        ' AND HCP__r.HCP_Contact__r.AccountId = \'' + clinicId + '\' '
        );
    }
    
    public static Map<Id, Integer> getMRRPassedByTrial(Id clinicId){
        return getPECountMapByTrialsForPI(
                'AND Medical_Record_Review_Status__c = \'' + MRR_STATUS_PASS + '\'' +
                        ' AND HCP__r.HCP_Contact__r.AccountId = \'' + clinicId + '\' '
        );
    }
    
    public static Map<Id, Integer> getPreScreeningsAllByTrial(){
        return getPECountMapByTrialsForPI('AND Pre_screening_Status__c != \'' + PES_STATUS_NOT_REQUIRED + '\'' );
    }
    
    public static Map<Id, Integer> getPreScreeningsPassedByTrial(){
        return getPECountMapByTrialsForPI('AND Pre_screening_Status__c = \'' + PES_STATUS_PASS + '\'');
    }
    
    public static Map<Id, Integer> getMRRAllByTrial(){
        return getPECountMapByTrialsForPI('AND Medical_Record_Review_Status__c != \'' + MRR_STATUS_NOT_REQUIRED + '\'');
    }
    
    public static Map<Id, Integer> getMRRPassedByTrial(){
        return getPECountMapByTrialsForPI('AND Medical_Record_Review_Status__c = \'' + MRR_STATUS_PASS + '\'');
    }
    
    public static Map<Id, Integer> getReferredByTrial(){
        return getPECountMapByTrialsForPI('AND Participant_Status__c IN  (\'' + String.join(new List<String>(PEStatusState.ALL_USED_STATUSES),'\',\'') + '\')');
    }
    
    public static Map<Id, Integer> getPECountMapByTrialsForPI(String filter){
        String query = 'SELECT Study_Site__r.Clinical_Trial_Profile__c trialId, count(Name) amount ' +
                ' FROM Participant_Enrollment__c ' +
                ' WHERE Study_Site__c != NULL AND ' + getUserModeFilter(CommunityService.USER_MODE_PI);
        if(filter != null){
            query += filter;
        }
        query += ' GROUP BY Study_Site__r.Clinical_Trial_Profile__c';
        Map<Id, Integer> resMap = new Map<Id, Integer>();
        for(AggregateResult ar : Database.query(query)){
            resMap.put((Id)ar.get('trialId'), (Integer)ar.get('amount'));
        }
        return resMap;
    }
    
    public static Integer getPEnrolmentsCount(List<Id> trialIds, String userMode, List<String> statuses){
        return getPEnrolmentsCount(trialIds, userMode, statuses, null);
    }
    
    public static Integer getPEnrolmentsCount(String userMode, String status){
        return getPEnrolmentsCount(null, userMode, new List<String>{status}, null);
    }
    
    public static Integer getPEnrolmentsCount(String userMode, List<String> statuses){
        return getPEnrolmentsCount(null, userMode, statuses, null);
    }
    
    public static Integer getPEnrolmentsCount(List<Id> trialIds, String userMode, String status, String reason){
        return getPEnrolmentsCount(trialIds, userMode, new List<String>{status}, new List<String>{reason});
    }
    
    public static Integer getPEnrolmentsCount(List<Id> trialIds, String userMode, List<String> statuses, List<String> reasons){
        String filter = ' AND Participant_Status__c IN (\'' + String.join(statuses, '\',\'') + '\')';
        if(trialIds != null) filter += ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(trialIds, '\',\'') + '\') ';
        if(reasons != null) filter += ' AND Non_Referral_Reason__c IN (\'' + String.join(reasons, '\',\'')  + '\')';
        return getPEnrolmentsCountCommon(userMode, filter);
    }
    
    public static Integer getPEnrolmentsCountCommon(String userMode, String filter) {
        String query = ' SELECT count() ' +
                ' FROM Participant_Enrollment__c ' +
                ' WHERE Study_Site__c != NULL AND ' + getUserModeFilter(userMode);
        query += filter;
        System.debug('PE QUERY: ' + query);
        return Database.countQuery(query);
    }
    
    public static List<Participant_Enrollment__c> getPEnrolmentsByStatus(String userMode, List<String> statuses, Integer recordsLimit){
        String filter = ' AND Participant_Status__c IN (\'' + String.join(statuses, '\',\'') + '\') ';
        if(recordsLimit != null) filter += ' LIMIT ' + recordsLimit;
        return getPEnrolmentsCommon(userMode, filter);
    }
    
    public static List<Participant_Enrollment__c> getReferredPEList(String userMode, String filter){
        if(filter == null) filter = '';
        filter += ' AND Participant_Status__c IN (\'' + String.join(new List<String>(PEStatusState.ALL_USED_STATUSES), '\',\'') + '\') ';
        return getPEnrolmentsCommon(userMode, filter);
    }
    
    private static final List<String> PE_COMMON_FIELDS = new List<String>{
            'Id',
            'HCP__c',
            'Name',
            'Patient_ID__c',
            'PI_Contact__r.Name',
            'PI_Contact__r.Phone',
            'Medical_Record_Review_Status__c',
            'Pre_screening_Status__c',
            'Participant_Status__c',
            'Participant_Name__c',
            'Participant_Surname__c',
            'Non_Referral_Reason__c',
            'Participant__c',
            'Participant__r.First_Name__c',
            'Participant__r.Last_Name__c',
            'Participant__r.Email__c',
            'Participant__r.Phone__c',
            'Participant__r.Mailing_State__c',
            'Participant__r.Mailing_State_Code__c',
            'Participant__r.Mailing_Country__c',
            'Participant__r.Mailing_Country_Code__c',
            'Participant__r.Mailing_Zip_Postal_Code__c',
            'Study_Name__c',
            'Study_Site__c',
            'Study_Site__r.Name',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Orientation_Required__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Study_Site__r.Site__r.Name',
            'Study_Site__r.Site__r.BillingStreet',
            'Is_Virtual_Study_Site__c',
            'HCP__r.Status__c',
            'HCP__r.HCP_Contact__c',
            'HCP__r.HCP_Contact__r.Name',
            'HCP__r.HCP_Contact__r.AccountId',
            'HCP__r.HCP_Contact__r.Account.Name',
            'HCP__r.HCP_Contact__r.Account.BillingCountryCode',
            'HCP__r.HCP_Contact__r.Account.BillingStateCode',
            'HCP__r.Orientation_Date__c',
            'Referred_Date__c',
            'Referral_ID__c',
            'Referral_Source__c',
            'Participant_Status_Last_Changed_Date__c',
            'Medical_Record_Review_Completedby_Name__c',
            'Pre_Eligibility_Date__c',
            'Screening_ID__c',
            'Referral_Completedby_Name__c',
            'CreatedDate'
    };
    
    public static List<Participant_Enrollment__c> getPEnrolmentsCommonCustomFields(String userMode, List<String> customFields, String filter){
        String query = 'SELECT ' + String.join(customFields, ',') +
                ' FROM Participant_Enrollment__c ' +
                ' WHERE Study_Site__c != NULL AND ' + getUserModeFilter(userMode);
        if(filter != null) query += ' ' + filter;
        System.debug('EXECUTE QUERY: ' + query);
        List<Participant_Enrollment__c> peList = Database.query(query);
        TranslateHelper.translate(peList);
        return peList;
    }
    
    public static List<Participant_Enrollment__c> getPEnrolmentsCommon(String userMode, String filter){
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommonCustomFields(userMode, PE_COMMON_FIELDS, filter);
        for(Participant_Enrollment__c pe : peList){
            if(pe.getSObject('Participant__r') != null){
                //translate country:
                String countryCode = (String)pe.getSObject('Participant__r').get('Mailing_Country_Code__c');
                String country = CountryStateUtil.getCountryName(countryCode);
                pe.getSObject('Participant__r').put('Mailing_Country__c', country);
            
                //translate state
                String stateCode = (String)pe.getSObject('Participant__r').get('Mailing_State_Code__c');
                String state = CountryStateUtil.getStateName(countryCode, stateCode);
                pe.getSObject('Participant__r').put('Mailing_State__c', state);
            }
        }
        return peList;
    }

    private static String getUserModeFilter(String userMode){
        String delegatesFilter = '';
        if (userMode == CommunityService.USER_MODE_PI) {
            List<Id> delegatedSSIds = DelegateService.getDelegatedStudySiteIds();
            if(delegatedSSIds.size() > 0) delegatesFilter = ' OR Study_Site__c IN (\'' + String.join(delegatedSSIds, '\',\'') + '\')' ;
            return '( ' +
                    '   Study_Site__r.Principal_Investigator__c = \'' + CommunityService.getUserContact().Id + '\' ' +
                        delegatesFilter +
                    ') ';
        } else if(userMode == CommunityService.USER_MODE_HCP) {
            List<Id> delegatedHCPEIds = DelegateService.getDelegatedHCPEnrollmentIds();
            if(delegatedHCPEIds.size() > 0) delegatesFilter = '   OR HCP__c IN (\'' + String.join(delegatedHCPEIds, '\',\'') + '\')';
            return '(' +
                    '   HCP__r.HCP_Contact__c = \'' + CommunityService.getUserContact().Id + '\'' +
                        delegatesFilter +
                    ') ';
        } else{
            return 'Participant__r.Contact__c = \'' + CommunityService.getUserContact().Id + '\' ';
        }
    }
    
    public static Participant_Enrollment__c createParticipantEnrollment(Clinical_Trial_Profile__c trial, HCP_Enrollment__c hcpEnrollment, String participantId){
        String mrrStatus = MRR_STATUS_NOT_REQUIRED;
        if(trial.Link_to_Medical_Record_Review__c != null) mrrStatus = MRR_STATUS_PENDING;

        String pesStatus = PES_STATUS_NOT_REQUIRED;
        if(trial.Link_to_Pre_screening__c != null) pesStatus = PES_STATUS_PENDING;


        Participant_Enrollment__c participantEnrollment = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                HCP__r = hcpEnrollment,
                Pre_screening_Status__c = pesStatus,
                Medical_Record_Review_Status__c = mrrStatus,
                PI_Contact__c = hcpEnrollment.Study_Site__r.Principal_Investigator__c,
                Study_Site__c = hcpEnrollment.Study_Site__c,
                Patient_ID__c = participantId,
                Referral_Source__c = 'HCP'
        );
        //insert participantEnrollment;
        return participantEnrollment;
    }

    //contains selected filter values
    public class PEFilter{
        public String mode;
        public List<Id> trialIds;
        public Id study;
        public Id studySite;
        public String referringStatus;
        public String enrollmentStatus;
        public String reviewResult;
        public String referredType;
        public String dateRange;
        public Date startDate;
        public Date endDate;
        public String searchText;
        public List<String> searchFields;
        public String sortType = SortOrder.SORT_TYPES[0].value;
        public String additionalFilter;
        public String acceptenceStatus;
        public String referringClinic;

        public PEFilter(PEFilterData filterData){
            mode = filterData.mode;
            trialIds = filterData.trialIds;
        }
    }

    //contains pick list values for PEFilter
    public class PEFilterData{
        public String mode;
        public List<Id> trialIds;
        public List<LabelValueItem> studies;
        public List<LabelValueItem> studySites;
        public List<LabelValueItem> referringStatuses = PEStatusState.getReferringStatusesLVList();
        public List<LabelValueItem> reviewResults;
        public List<LabelValueItem> referredTypes;
        public List<LabelValueItem> referringClinics;
        public List<LabelValueItem> dateRanges = DateRangeFilterData.getRanges();
        public List<LabelValueItem> sortVariants = SortOrder.SORT_TYPES;
        public List<LabelValueItem> acceptenceStatuses = PEStatusState.getAcceptenceStatusesLVList();
        public List<LabelValueItem> enrollmentStatuses = PEStatusState.getEnrollmentStatusesLVList();
    }

    public static PEFilterData getPEFilterData(Id trialId, String mode){
        Id userContactId = CommunityService.getUserContact().Id;
        Clinical_Trial_Profile__c trial;
        PEFilterData peFilterData = new PEFilterData();
        peFilterData.mode = mode;
        Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>(TrialService.getAvailableTrials(mode));
        //init trials
        peFilterData.studies = new List<LabelValueItem>();
        peFilterData.studies.add(new LabelValueItem(Label.PG_MRRL_L_All_studies, null));
        peFilterData.trialIds = new List<Id>();
        if(trialId != null){
            peFilterData.trialIds.add(trialId);
            trial = trialsMap.get(trialId);
            if(trial != null){
                peFilterData.studies.add(new LabelValueItem(trial.Study_Code_Name__c, trial.Id));
            }
        }else{
            for(String id : trialsMap.keySet()){
                peFilterData.trialIds.add(id);
                trial = trialsMap.get(id);
                peFilterData.studies.add(new LabelValueItem(trial.Study_Code_Name__c, trial.Id));
            }
        }
        //init study sites:
        peFilterData.studySites = new List<LabelValueItem>();
        peFilterData.studySites.add(new LabelValueItem(Label.PG_Report_L_All_study_sites, null));
        if(mode == CommunityService.USER_MODE_HCP){
            List<Study_Site__c> studySites = StudySiteService.getStudySitesForHCP(peFilterData.trialIds);
            for(Study_Site__c ss : studySites) peFilterData.studySites.add(new LabelValueItem(ss.Name, ss.Id));
        }

        peFilterData.referringClinics = new List<LabelValueItem>();
        peFilterData.referringClinics.add(new LabelValueItem(Label.PG_Report_L_All_referring_clinics, null));
        for(Account clinic : HCPEnrollmentService.getReferringClinics(peFilterData.trialIds)){
            peFilterData.referringClinics.add(new LabelValueItem(clinic.Name, clinic.Id));
        }
        return peFilterData;
    }

    public static List<Participant_Enrollment__c> getParticipantEnrollments(PEFilter filter, PaginationData paginationData){
        //prepare filter string:
        String filterStr = ' AND Study_Site__r.Clinical_Trial_Profile__c IN (\'' + String.join(filter.trialIds, '\',\'') + '\') ';
        if(!String.isEmpty(filter.additionalFilter)) filterStr += ' AND ' + filter.additionalFilter + ' ';
        if(filter.searchText != null) filter.searchText = filter.searchText.trim();
        if(String.isEmpty(filter.searchText)){
            if(!String.isEmpty(filter.study)) filterStr += ' AND Study_Site__r.Clinical_Trial_Profile__c = \'' + filter.study + '\' ';
            if(!String.isEmpty(filter.studySite)) filterStr += ' AND Study_Site__c = \'' + filter.studySite + '\' ';
            if(!String.isEmpty(filter.referringStatus)) filterStr += filter.referringStatus;
            if(!String.isEmpty(filter.enrollmentStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.enrollmentStatus + ' ';
            if(!String.isEmpty(filter.acceptenceStatus)) filterStr += ' AND Participant_Status__c IN ' + filter.acceptenceStatus + ' ';
            if(!String.isEmpty(filter.referringClinic)) filterStr += ' AND HCP__r.HCP_Contact__r.AccountId = \'' + filter.referringClinic + '\' ';
            if(filter.startDate != null && filter.endDate != null && filter.startDate < filter.endDate){
                //TODO
            }
        }
        if(!String.isEmpty(filter.dateRange)){
            filterStr += ' AND CreatedDate ' + filter.dateRange + ' ';
        }
        if(!filter.sortType.contains('Alphabetical')) filterStr += ' ORDER BY ' + filter.sortType;
        System.debug('FILTER STRING: ' + filterStr);

        //get PE List:
        List<Participant_Enrollment__c> peList = getPEnrolmentsCommon(filter.mode, filterStr);
        List<Participant_Enrollment__c> filteredPEList = new List<Participant_Enrollment__c>();
        //Filter by search string:
        if(filter != null && !String.isEmpty(filter.searchText) ){
            for(Participant_Enrollment__c pe : peList){
                Boolean isFound = false;
                for(String searchField : filter.searchFields){
                    String searchFieldValue = getSObjectFieldValue(pe, searchField) + '';
                    if(searchFieldValue.containsIgnoreCase(filter.searchText)){
                        isFound = true;
                        break;
                    }
                }
                if(isFound) filteredPEList.add(pe);
            }
            peList = filteredPEList;
        }
    
        //sort
        if(filter != null && filter.sortType.contains('Alphabetical')){
            List<String> fields = filter.sortType.split(',');
            String type = fields[0];
            List<String> orderList = new List<String>();
            Map<String, Participant_Enrollment__c> peMap = new Map<String, Participant_Enrollment__c>();
            for(Participant_Enrollment__c pe : peList){
                String key = '';
                for(String field : fields){
                    if(!field.contains('Alphabetical')) key += ' ' + getSObjectFieldValue(pe, field.trim());
                }
                key += pe.Id;
                orderList.add(key);
                peMap.put(key, pe);
            }
            orderList.sort();
            
            if( type.equalsIgnoreCase('Alphabetical_DESC')){
                List<String> reversed = new List<String>();
                for(Integer i = orderList.size() - 1; i >= 0; i--){
                    reversed.add(orderList[i]);
                }
                orderList = reversed;
            }
            List<Participant_Enrollment__c> sortedList = new List<Participant_Enrollment__c>();
            for(String key : orderList) sortedList.add(peMap.get(key));
            peList = sortedList;
        }
        
        //Pagination:
        if(paginationData != null){
            paginationData.setRecordsCount(peList.size());
            List<Participant_Enrollment__c> pageList = new List<Participant_Enrollment__c>();
            for(Integer i = paginationData.offset; i < paginationData.endOffset; i++){
                pageList.add(peList[i]);
            }
            return pageList;
        }
        return peList;
    }
    
    private static Object getSObjectFieldValue(SObject sObj, String fieldPath){
        List<String> pathItems = fieldPath.split('\\.');
        SObject currentSObject = sObj;
        for(Integer i = 0; i < pathItems.size() - 1; i++) {
            currentSObject = currentSObject.getSObject(pathItems[i]);
            if(currentSObject == null) return null;
        }
        return currentSObject.get(pathItems[pathItems.size() - 1]);
    }

}