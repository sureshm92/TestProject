/**
 * Created by Kryvolap on 02.09.2019.
 */

public without sharing class PIStudiesFilter implements SearchFilter {
    public static final String STORE_ID_PI_LIST_STUDY_FILTER = 'PIListOfStudiesFilter_';

    public FilterData filterData;
    public SortData sortData;

    public PIStudiesFilter() {
        filterData = getFilterData();
        sortData = new SortData();
    }

    public PIStudiesFilter(FilterData filterData, SortData sortData) {
        this.filterData = new FilterData(
            filterData.trialId,
            filterData.piId,
            filterData.statusFilter,
            filterData.searchText
        );
        this.sortData = sortData;
    }

    private static final List<String> PI_STUDY_COMMON_FIELDS = new List<String>{
        'Id',
        'Name',
        'Study_Sponsor__c',
        'CommunityTemplate__c',
        'Detailed_Description__c',
        'Override_Recruitment_Status__c',
        'Terms_And_Conditions_ID__c',
        'Link_to_Medical_Record_Review__c',
        'Link_to_Pre_screening__c',
        'Share_URL__c',
        'Study_Title__c',
        'Study_Code_Name__c',
        'Official_Title__c',
        'Sponsor_Pays_for_Referral_Activity__c',
        'Override_Inclusion_Criteria__c',
        'Override_Description__c',
        'Brief_Summary__c',
        'Therapeutic_Area__r.Name',
        'NCT_Number__c'
    };

    private static final List<String> PI_STUDY_SITES_COMMON_FIELDS = new List<String>{
        'Id',
        'Name',
        'Site__c',
        'Override_PI_Referral_Status__c',
        'Is_Virtual_Study_Site__c',
        'Study_Site_Type__c',
        'Study_Site_Phone__c',
        'Study_Site_Email__c',
        'Suppress_Participant_Emails__c',
        'Account_Was_Changed__c',
        'Site__r.Name',
        'Site__r.BillingAddress',
        'Site__r.BillingCountry',
        'Site__r.BillingCountryCode',
        'Site__r.BillingState',
        'Site__r.BillingStateCode',
        'Site__r.BillingPostalCode',
        'Site__r.BillingCity',
        'Site__r.BillingStreet',
        'Site__r.BillingLatitude',
        'Site__r.BillingLongitude',
        'Site__r.BillingGeocodeAccuracy',
        'Site__r.Driving_Directions__c',
        'Site__r.Parking_Instructions__c',
        'Site__r.ParentId',
        'Clinical_Trial_Profile__c',
        'Clinical_Trial_Profile__r.Suppress_Participant_Emails__c',
        'Clinical_Trial_Profile__r.Id',
        'Clinical_Trial_Profile__r.Study_Title__c',
        'Clinical_Trial_Profile__r.Protocol_ID__c',
        'Clinical_Trial_Profile__r.Study_Code_Name__c',
        'Clinical_Trial_Profile__r.Official_Title__c',
        'Clinical_Trial_Profile__r.Study_Sponsor__c',
        'Clinical_Trial_Profile__r.CommunityTemplate__c',
        'Clinical_Trial_Profile__r.Override_Recruitment_Status__c',
        'Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c',
        'Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c',
        'Clinical_Trial_Profile__r.Link_to_Pre_screening__c',
        'Clinical_Trial_Profile__r.Orientation_Required__c',
        'Clinical_Trial_Profile__r.Include_in_patient_trial_search__c',
        'Clinical_Trial_Profile__r.Patient_Portal_Enabled__c',
        'Principal_Investigator__r.Name',
        'Principal_Investigator__r.FirstName',
        'Principal_Investigator__r.LastName',
        'Principal_Investigator__r.Suffix',
        'Principal_Investigator__r.Title',
        'Principal_Investigator__r.MailingStreet',
        'Principal_Investigator__r.MailingCity',
        'Principal_Investigator__r.MailingState',
        'Principal_Investigator__r.MailingPostalCode',
        'Principal_Investigator__r.MailingAddress',
        'Principal_Investigator__r.Phone',
        'Principal_Investigator__r.Email',
        'Principal_Investigator__r.Salutation',
        'Principal_Investigator__r.Account.BillingStreet',
        'Principal_Investigator__r.Account.BillingCity',
        'Principal_Investigator__r.Account.BillingState',
        'Principal_Investigator__r.Account.BillingStateCode',
        'Principal_Investigator__r.Account.BillingPostalCode',
        'Principal_Investigator__r.Account.BillingCountry',
        'Principal_Investigator__r.Account.BillingCountryCode',
        'Principal_Investigator__r.Account.BillingLatitude',
        'Principal_Investigator__r.Account.BillingLongitude',
        'Principal_Investigator__r.Account.BillingGeocodeAccuracy',
        'Principal_Investigator__r.Account.BillingAddress',
        'Site_Staff__r.Site_Contact__c'
    };

    private static List<String> STUDY_SEARCH_FIELDS = new List<String>{ 'Study_Code_Name__c' };

    public String getQueryType() {
        return SearchService.QUERY_TYPE_SOQL;
    }

    public List<String> getFields() {
        List<String> fields = new List<String>();
        fields.addAll(PI_STUDY_COMMON_FIELDS);
        String studySitesQuery =
            '( SELECT ' +
            String.join(PI_STUDY_SITES_COMMON_FIELDS, ', ') +
            ' FROM Study_Site_Profiles__r WHERE ';
        if (
            filterData.piId != null &&
            filterData.piId != '' &&
            filterData.piId == CommunityService.getUserContact().Id
        ) {
            studySitesQuery +=
                ' (' +
                DatabaseService.fieldEqual('Principal_Investigator__c', filterData.piId) +
                ' )';
        } else if (filterData.piId != null && filterData.piId != '') {
            studySitesQuery +=
                ' (' +
                DatabaseService.fieldEqual('Principal_Investigator__c', filterData.piId) +
                '   AND  ' +
                DatabaseService.fieldInValues('Id', DelegateService.getDelegatedStudySiteIds()) +
                ' )';
        } else {
            studySitesQuery +=
                ' (' +
                DatabaseService.fieldEqual(
                    'Principal_Investigator__c',
                    CommunityService.getUserContact().Id
                ) +
                '   OR  ' +
                DatabaseService.fieldInValues('Id', DelegateService.getDelegatedStudySiteIds()) +
                ' )';
        }
        studySitesQuery += ' AND Override_PI_Referral_Status__c !=null)';
        fields.add(studySitesQuery);
        return fields;
    }

    public String getFilterString() {
        String filterString = DatabaseService.fieldEqual(
            'Override_Recruitment_Status__c',
            filterData.statusFilter
        );
        if (
            filterData.piId != null &&
            filterData.piId != '' &&
            filterData.piId == CommunityService.getUserContact().Id
        ) {
            filterString +=
                ' AND ( Id IN (SELECT Clinical_Trial_Profile__c FROM Study_Site__c WHERE ' +
                DatabaseService.fieldEqual('Principal_Investigator__c', filterData.piId) +
                ' ) )';
        } else if (filterData.piId != null && filterData.piId != '') {
            filterString +=
                ' AND ( Id IN (SELECT Clinical_Trial_Profile__c FROM Study_Site__c WHERE (' +
                DatabaseService.fieldEqual('Principal_Investigator__c', filterData.piId) +
                '   AND  ' +
                DatabaseService.fieldInValues('Id', DelegateService.getDelegatedStudySiteIds()) +
                ' ) ) )';
        } else {
            filterString +=
                ' AND ( Id IN (SELECT Clinical_Trial_Profile__c FROM Study_Site__c WHERE (' +
                DatabaseService.fieldEqual(
                    'Principal_Investigator__c',
                    CommunityService.getUserContact().Id
                ) +
                '   OR  ' +
                DatabaseService.fieldInValues('Id', DelegateService.getDelegatedStudySiteIds()) +
                ' ) ) )';
        }
        if (filterData.trialId != null && filterData.trialId != '') {
            filterString += ' AND ' + DatabaseService.fieldEqual('Id', filterData.trialId);
        }
        CommunityTemplate currentCommunityTemplate = UserContext.getCurrentCommunityTemplate();
        System.debug('CURRENT TEMPLATE: ' + JSON.serializePretty(currentCommunityTemplate));
        if (currentCommunityTemplate.templateName == CommunityTemplateService.TEMPLATE_JANSSEN) {
            //if current is Janssen then add only Janssen
            filterString +=
                ' AND ' +
                DatabaseService.fieldEqual(
                    'CommunityTemplate__c',
                    CommunityTemplateService.TEMPLATE_JANSSEN
                );
        } else {
            //if current not Jenssen then add only not Janssen
            filterString +=
                ' AND ' +
                DatabaseService.fieldNotEqual(
                    'CommunityTemplate__c',
                    CommunityTemplateService.TEMPLATE_JANSSEN
                );
        }

        if (filterData.searchText != '') {
            filterString +=
                ' AND ' + DatabaseService.searchFields(STUDY_SEARCH_FIELDS, filterData.searchText);
        }

        return filterString;
    }

    public String getOrderBy() {
        return sortData.sortType;
    }

    public SObjectType getSObjectType() {
        return Clinical_Trial_Profile__c.getSObjectType();
    }

    public static List<LabelValueItem> getInitStatusOptions() {
        List<LabelValueItem> studyStatusOptions = new List<LabelValueItem>();
        for (
            Schema.PicklistEntry ple : Clinical_Trial_Profile__c.Override_Recruitment_Status__c.getDescribe()
                .getPicklistValues()
        ) {
            studyStatusOptions.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        return studyStatusOptions;
    }

    public class FilterData {
        public String searchText = '';
        public String statusFilter = 'Actively Enrolling';
        public String trialId;
        public String piId;
        public String searchTextPlaceholder;
        public List<LabelValueItem> statusOptions = new List<LabelValueItem>();
        public List<LabelValueItem> PIPickList;
        public List<LabelValueItem> studyPickList;

        public FilterData() {
            this('', '', 'Actively Enrolling', '');
        }

        public FilterData(String trialId, String piId, String statusFilter, String searchText) {
            this.trialId = trialId;
            this.piId = piId;
            this.statusFilter = statusFilter;
            this.searchText = searchText;
            updateFilterData();
        }

        public void updateFilterData() {
            searchTextPlaceholder = Label.PG_MS_L_Search_for_Study_PI;
            statusOptions = getInitStatusOptions();
            PIPickList = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MS_L_All_Investigators, null)
            };
            studyPickList = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRRL_L_All_studies, null)
            };
            Set<Id> studyIds = new Set<Id>();
            Set<Id> piIds = new Set<Id>();
            Set<Id> piHavingPartIds = new Set<Id>();
            List<Study_Site__c> studySites = filterStudySitesByCurrentCommunity(
                StudySiteService.getStudySitesForPI()
            );
            for (Study_Site__c site : studySites) {
                piHavingPartIds.add(site.Principal_Investigator__c);
            }
            Map<Id, Participant__c> piPartDetails = StudyListViewController.getPIParticipantDetails(
                piHavingPartIds
            );
            for (Study_Site__c site : studySites) {
                if (!piIds.contains(site.Principal_Investigator__c)) {
                    if (site.Principal_Investigator__c == CommunityService.getUserContact().Id) {
                        PIPickList.add(
                            new LabelValueItem(Label.PG_MS_L_Self, site.Principal_Investigator__c)
                        );
                    } else {
                        PIPickList.add(
                            new LabelValueItem(
                                piPartDetails.containsKey(site.Principal_Investigator__c)
                                    ? piPartDetails.get(site.Principal_Investigator__c).Full_Name__c
                                    : site.Principal_Investigator__r.Full_Name__c,
                                site.Principal_Investigator__c
                            )
                        );
                    }

                    piIds.add(site.Principal_Investigator__c);
                }
                if (piId != null && piId != '') {
                    if (
                        site.Principal_Investigator__c == piId &&
                        !studyIds.contains(site.Clinical_Trial_Profile__c)
                    ) {
                        studyPickList.add(
                            new LabelValueItem(
                                site.Clinical_Trial_Profile__r.Study_Code_Name__c,
                                site.Clinical_Trial_Profile__c
                            )
                        );
                        studyIds.add(site.Clinical_Trial_Profile__c);
                    }
                } else if (!studyIds.contains(site.Clinical_Trial_Profile__c)) {
                    studyPickList.add(
                        new LabelValueItem(
                            site.Clinical_Trial_Profile__r.Study_Code_Name__c,
                            site.Clinical_Trial_Profile__c
                        )
                    );
                    studyIds.add(site.Clinical_Trial_Profile__c);
                }
            }
        }

        public void save() {
            searchTextPlaceholder = null;
            statusOptions = null;
            PIPickList = null;
            studyPickList = null;
            SettingStoreService.save(getFilterDataId(), this, FilterData.class);
        }
    }

    public static FilterData getFilterData() {
        FilterData fd = (PIStudiesFilter.FilterData) SettingStoreService.get(getFilterDataId());
        if (fd == null) {
            fd = new FilterData();
        } else {
            fd.updateFilterData();
        }
        return fd;
    }

    private static String getFilterDataId() {
        String idPostfix = '_Default';
        if (UserContext.getCurrentCommunityName() == CommunityService.JANSSEN_NETWORK_NAME)
            idPostfix = '_' + UserContext.getCurrentCommunityName();
        return STORE_ID_PI_LIST_STUDY_FILTER + idPostfix;
    }

    public class SortData {
        public String sortType;
        public List<LabelValueItem> sortVariants;
        public SortData() {
            sortVariants = new List<LabelValueItem>{
                new LabelValueItem(Label.PG_MRZ_L_Last_Added, 'CreatedDate DESC'),
                new LabelValueItem(Label.PG_MRZ_L_Last_Modified, 'LastModifiedDate DESC'),
                new LabelValueItem(Label.PG_MRZ_L_Alphabetical_A_Z, 'Study_Code_Name__c ASC'),
                new LabelValueItem(Label.PG_MRZ_L_Alphabetical_Z_A, 'Study_Code_Name__c DESC')
            };
            sortType = 'CreatedDate DESC';
        }
    }

    private static List<Study_Site__c> filterStudySitesByCurrentCommunity(
        List<Study_Site__c> inputList
    ) {
        List<Study_Site__c> outList = new List<Study_Site__c>();
        CommunityTemplate currentCommunityTemplate = UserContext.getCurrentCommunityTemplate();
        for (Study_Site__c ss : inputList) {
            if (
                currentCommunityTemplate.templateName == CommunityTemplateService.TEMPLATE_JANSSEN
            ) {
                //if current is Janssen then add only Janssen
                if (
                    ss.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                    CommunityTemplateService.TEMPLATE_JANSSEN
                )
                    outList.add(ss);
            } else {
                //if current not Jenssen then add only not Janssen
                if (
                    ss.Clinical_Trial_Profile__r.CommunityTemplate__c !=
                    CommunityTemplateService.TEMPLATE_JANSSEN
                )
                    outList.add(ss);
            }
        }
        return outList;
    }
}
