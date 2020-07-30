/**
 * Created by Kryvolap on 26.08.2019.
 */

public without sharing class ReferringClinicsFilter implements SearchFilter{

    public FilterData filterData;
    public FilterValues filterValues;
    public SortData sortData;

    public ReferringClinicsFilter(String trialId, String ssId) {
        filterValues = new FilterValues(trialId, ssId, '');
        filterData = new FilterData(filterValues);
        sortData = new SortData();
    }

    public ReferringClinicsFilter(FilterValues filterValues, SortData sortData) {
        this.filterValues = filterValues;
        this.filterData = new FilterData(filterValues);
        this.sortData = sortData;
    }


    private static final List<String> REFERRING_CLINICS_COMMON_FIELDS = new List<String>{
            'Id',
            'Name',
            'Status__c',
            'Trial_Requires_Orientation__c',
            'CreatedDate',
            'LastModifiedDate',
            'HCP_Contact__c',
            'HCP_Contact__r.FirstName',
            'HCP_Contact__r.LastName',
            'HCP_Contact__r.Name',
            'HCP_Contact__r.AccountId',
            'HCP_Contact__r.Account.Name',
            'HCP_Contact__r.Account.BillingStreet',
            'HCP_Contact__r.Account.BillingState',
            'HCP_Contact__r.Account.BillingPostalCode',
            'HCP_Contact__r.Account.BillingCity',
            'HCP_Contact__r.Account.Phone',
            'HCP_Contact__r.Salutation',
            'HCP_Contact__r.Is_First_logon__c',
            'HCP_Name__c',
            'Study_Site__r.Id',
            'Study_Site__r.Name',
            'Study_Site__r.Site__c',
            'Study_Name__c',
            'Study_Site__r.Principal_Investigator__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Id',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Official_Title__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Study_Sponsor__c',
            'Study_Site__r.Clinical_Trial_Profile__c',
            'Study_Site__r.Override_PI_Referral_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Override_Status_Updated_By__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
            'Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c',
            'Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
            'Study_Site__r.Site__r.Name',
            'Study_Site__r.Principal_Investigator__r.Name',
            'Study_Site__r.Principal_Investigator__r.Title',
            'Study_Site__r.Principal_Investigator__r.Email',
            'Study_Site__r.Principal_Investigator__r.Phone',
            'Study_Site__r.Principal_Investigator__r.MailingAddress',
            'Study_Site__r.Is_Virtual_Study_Site__c',
            'Study_Site__r.Study_Site_Type__c',
            'Override_PI_Status__c',
            'Orientation_Date__c',
            'HCP_Full_Name__c'
    };

    private static List<String> REFERRING_CLINICS_SEARCH_FIELDS = new List<String>{
            'HCP_Contact__r.Full_Name__c'
            //'Study_Site__r.Name',
            //'Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c'
    };

    public String getQueryType(){
        return SearchService.QUERY_TYPE_SOQL;
    }

    public List<String> getFields(){
        return REFERRING_CLINICS_COMMON_FIELDS;
    }

    public String getFilterString (){
        String filterString = '(' + DatabaseService.fieldEqual('Study_Site__r.Principal_Investigator__c',CommunityService.getUserContact().Id) +
                (!DelegateService.getDelegatedStudySiteIds().isEmpty()?'   OR  ' + DatabaseService.fieldInValues('Study_Site__c', DelegateService.getDelegatedStudySiteIds()): '')+
                ') ';
        if(filterValues.ssId != null && filterValues.ssId != ''){
            filterString += ' AND ' + DatabaseService.fieldEqual( 'Study_Site__c', filterValues.ssId);
        }
        else if (filterValues.trialId != null && filterValues.trialId != '')  {
            filterString += ' AND ' + DatabaseService.fieldEqual('Study_Site__r.Clinical_Trial_Profile__c', filterValues.trialId);
        }
        else {
            List<Id> trialIds = new List<Id>();
            for (LabelValueItem trialOptions : filterData.studyPickList) {
                if (trialOptions.value != '') {
                    trialIds.add(trialOptions.value);
                }
            }
            filterString += ' AND ' + DatabaseService.fieldInValues('Study_Site__r.Clinical_Trial_Profile__c',  trialIds);
        }

        if(filterValues.statusFilter == ''){
            filterString += ' AND ' + DatabaseService.fieldNotInValues('Status__c',new List<String>{
                    HCPEnrollmentService.HCP_S_INVITATION_SENT
            });
        }
        else{
            filterString += ' AND ' + DatabaseService.fieldInValues('Status__c',new List<String>{
                    filterValues.statusFilter
            });
        }
        if(filterValues.searchText != '' && filterValues.searchText.trim().length()>1){
            String searchString = 'FIND \'*' + filterValues.searchText +'*\' IN NAME FIELDS RETURNING Contact(Id, Name)';
            List<List<sObject>> searchList = search.query(searchString);
            List<Contact>searchHCPContacts = (List<Contact>)searchList[0];
            List<Id> contactIds = new List<Id>();
            for(Contact contact : searchHCPContacts){
                contactIds.add(contact.Id);
            }
            filterString += ' AND ' + DatabaseService.fieldInValues('HCP_Contact__c', contactIds);
            //filterString += ' AND ' + DatabaseService.searchFields(REFERRING_CLINICS_SEARCH_FIELDS, filterValues.searchText);
        }

        return filterString;
    }

    public String getOrderBy(){
        return sortData.sortType;
    }

    public SObjectType getSObjectType(){
        return HCP_Enrollment__c.getSObjectType();
    }

    public static List<LabelValueItem> getInitStatusOptions() {
        List<LabelValueItem> enrollmentStatusOptions = new List<LabelValueItem>();
        for (Schema.PicklistEntry ple : HCP_Enrollment__c.Status__c.getDescribe().getPicklistValues()) {
            if (HCPEnrollmentService.HCP_E_S_INVISIBLE_ON_STUDY_SITE_P.contains(ple.getValue())) continue;
            enrollmentStatusOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        return enrollmentStatusOptions;
    }



    public class FilterValues {
        public String searchText = '';
        public String statusFilter = '';
        public String statusFilterPlaceholder = Label.PG_MRZ_L_Provider_Status;
        public String trialId;
        public String ssId;
        public FilterValues(String trialId, String ssId, String statusFilter) {
            this.trialId = trialId;
            this.ssId = ssId;
            this.statusFilter = statusFilter;
        }

    }

    public class FilterData {
        public String searchTextPlaceholder = Label.PG_MRZ_L_Search_for_a_referring_clinic;
        public List<LabelValueItem> statusOptions = new List<LabelValueItem>();
        public List<LabelValueItem> studyPickList;
        public List<LabelValueItem> studySitePickList;
        public FilterData(FilterValues filterValues) {
            statusOptions = getInitStatusOptions();
            studyPickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRRL_L_All_studies, null)
            };
            studySitePickList = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_Report_L_All_study_sites, null)
            };
            List<Study_Site__c> studySites = StudySiteService.getStudySitesForPI();
            Set<Id> studyIds = new Set<Id>();
            for (Study_Site__c site : studySites) {
                if (!studyIds.contains(site.Clinical_Trial_Profile__c)) {
                    studyPickList.add(new LabelValueItem(site.Clinical_Trial_Profile__r.Study_Code_Name__c, site.Clinical_Trial_Profile__c));
                    studyIds.add(site.Clinical_Trial_Profile__c);
                }
                if (filterValues.trialId == null || filterValues.trialId == '' || site.Clinical_Trial_Profile__c == filterValues.trialId) {
                    studySitePickList.add(new LabelValueItem(site.Name, site.Id));
                }
            }
        }

    }

    public class SortData {
        public String sortType;
        public List<LabelValueItem> sortVariants;
        public SortData() {
            sortVariants = new List<LabelValueItem>{
                    new LabelValueItem(Label.PG_MRZ_L_Last_Added, 'CreatedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Last_Modified, 'LastModifiedDate DESC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_A_Z, 'Study_Site__r.Name ASC'),
                    new LabelValueItem(Label.PG_MRZ_L_Alphabetical_Z_A, 'Study_Site__r.Name DESC')
            };
            sortType = 'CreatedDate DESC';
        }
    }
}