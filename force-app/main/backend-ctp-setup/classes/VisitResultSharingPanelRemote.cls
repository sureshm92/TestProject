/**
 * Created by Leonid Bartenev
 * Edited by Igor Malyuta
 */

public without sharing class VisitResultSharingPanelRemote {
    public static final String FEATURE_VISIT_RESULT_SHARING = 'Visits_Results_Sharing';

    private static final String TYPE_DISABLED = 'Disabled';
    private static String TYPE_ALL = 'All';

    private static final String TYPE_STUDY_SITES = 'Study Sites';
    private static final String TYPE_STUDY_SITES_DISABLED = 'Study Sites_Disabled';

    private static final String TYPE_COUNTRIES = 'Countries';
    private static final String TYPE_COUNTRIES_DISABLED = 'Countries_Disabled';

    private static final List<String> GROUPS_ORDER = new List<String>{
        'Vitals',
        'MetabolicPanel',
        'Hematology',
        'FastingLipidProfile',
        'Biomarkers'
    };

    public class VisitResultGroupWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<VisitResultWrapper> visitResults;
        @AuraEnabled
        public Boolean show = false;
        @AuraEnabled
        public Boolean displayOnMyResultCard = false;

        public VisitResultGroupWrapper() {
        }

        public VisitResultGroupWrapper(String label, List<VisitResultWrapper> visitResults) {
            this.label = label;
            this.visitResults = visitResults;
        }
    }

    public class VisitResultWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String countryCodes;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String desLabel;
        @AuraEnabled
        public String customTooltip;
        @AuraEnabled
        public boolean isCustomToolTipEnabled;
        public VisitResultWrapper(
            String label,
            String value,
            String type,
            String countryCodes,
            String description,
            String desLabel,
            String customTooltip,
            Boolean isCustomToolTipEnabled
        ) {
            this.label = label;
            this.value = value;
            this.type = type;
            this.countryCodes = countryCodes;
            this.description = description;
            this.desLabel = desLabel;
            this.customTooltip = customTooltip;
            this.isCustomToolTipEnabled = isCustomToolTipEnabled;
        }
    }

    public class OptionsWrapper {
        @AuraEnabled
        public Boolean globalShareBck;
        @AuraEnabled
        public String participantDefault;
        @AuraEnabled
        public String selectedStatuses;
        @AuraEnabled
        public String selectedSSIds;
        @AuraEnabled
        public String ssSelectionType;
        @AuraEnabled
        public Integer showAfterDays;
        @AuraEnabled
        public String whenToShow;
        @AuraEnabled
        public Boolean inPatientPortal;
        @AuraEnabled
        public String countrySelectionType;
        @AuraEnabled
        public String selectedCountries;
    }

    public class InitData {
        @AuraEnabled
        public String userPermission = TYPE_DISABLED;
        @AuraEnabled
        public List<VisitResultGroupWrapper> groups;
        @AuraEnabled
        public List<LabelValueItem> typeSelectLVList = new List<LabelValueItem>{
            new LabelValueItem('Disabled for all countries', TYPE_DISABLED),
            new LabelValueItem('Enabled for all countries', TYPE_ALL),
            new LabelValueItem('Enabled for selected countries', TYPE_COUNTRIES),
            new LabelValueItem('Disabled for selected countries', TYPE_COUNTRIES_DISABLED)
        };
        @AuraEnabled
        public List<LabelValueItem> typeSelectCountryLevelList = new List<LabelValueItem>{
            new LabelValueItem('Disabled for all countries', TYPE_DISABLED),
            new LabelValueItem('Enabled for all countries', TYPE_ALL),
            new LabelValueItem('Enabled for selected countries', TYPE_COUNTRIES)
        };
        @AuraEnabled
        public List<LabelValueItem> participantDefaultLVList = new List<LabelValueItem>{
            new LabelValueItem('Opt in', 'Opt in'),
            new LabelValueItem('Opt out', 'Opt out')
        };
        @AuraEnabled
        public List<LabelValueItem> ssSelectionTypeLVList = new List<LabelValueItem>{
            new LabelValueItem('Enabled for all study sites', TYPE_ALL),
            new LabelValueItem('Enabled for selected study sites', TYPE_STUDY_SITES),
            new LabelValueItem('Disabled for selected study sites', TYPE_STUDY_SITES_DISABLED),
            new LabelValueItem('Disabled for all study sites', TYPE_DISABLED)
        };
        @AuraEnabled
        public List<LabelValueItem> whenToShowLVList = new List<LabelValueItem>{
            new LabelValueItem('Immediate', 'Immediate'),
            new LabelValueItem('Show after', 'After')
        };

        @AuraEnabled
        public OptionsWrapper options;
        @AuraEnabled
        public String communityTemplate;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        try {
            Clinical_Trial_Profile__c ctp = VisitResultSharingService.getCTP(ctpId);
            Map<String, Visit_Result_Type_Sharing__c> typeVRSharingMap = VisitResultSharingService.getTypeVRSharingMap(
                ctp
            );
            Map<String, List<VisitResultWrapper>> resultGroupToVisitResults = new Map<String, List<VisitResultWrapper>>();

            InitData initData = new InitData();
            initData.communityTemplate = ctp.CommunityTemplate__c;
            initData.groups = new List<VisitResultGroupWrapper>();
            initData.userPermission = GetPermissions.getViewMode(FEATURE_VISIT_RESULT_SHARING);

            List<Visit_Result_GroupM__mdt> resultGroups = [
                SELECT
                    Id,
                    Label,
                    (
                        SELECT
                            Id,
                            DeveloperName,
                            Label,
                            Visit_Result_Code__c,
                            Description_Label_Api_Name__c
                        FROM Visit_Result_Types__r
                    )
                FROM Visit_Result_GroupM__mdt
            ];

            for (Visit_Result_GroupM__mdt resultGroup : resultGroups) {
                List<VisitResultWrapper> visitResults = new List<VisitResultWrapper>();
                for (Visit_Result_TypeM__mdt visitResultType : resultGroup.Visit_Result_Types__r) {
                    String type = TYPE_DISABLED;
                    String countryCodes = '';
                    String customToolTipDes = '';
                    if (typeVRSharingMap.containsKey(visitResultType.DeveloperName)) {
                        Visit_Result_Type_Sharing__c sharing = typeVRSharingMap.get(
                            visitResultType.DeveloperName
                        );
                        customToolTipDes = sharing.Custom_Tooltip__c;
                        if (!String.isEmpty(sharing.Sharing_Countries__c)) {
                            if (sharing.Sharing_Countries__c == TYPE_ALL) {
                                type = TYPE_ALL;
                            } else {
                                countryCodes = sharing.Sharing_Countries__c;
                                if (sharing.Include_Countries__c) {
                                    type = TYPE_COUNTRIES;
                                } else {
                                    type = TYPE_COUNTRIES_DISABLED;
                                }
                            }
                        }
                    }
                    visitResults.add(
                        new VisitResultWrapper(
                            visitResultType.Label,
                            visitResultType.DeveloperName,
                            type,
                            countryCodes,
                            TranslateHelper.getLabelValue(
                                visitResultType.Description_Label_Api_Name__c
                            ),
                            visitResultType.Description_Label_Api_Name__c,
                            customToolTipDes,
                            !String.isBlank(customToolTipDes) ? true : false
                        )
                    );
                }
                resultGroupToVisitResults.put(resultGroup.Label, visitResults);
            }

            for (String groupLabel : GROUPS_ORDER) {
                VisitResultGroupWrapper resultGroupWrapper = new VisitResultGroupWrapper(
                    groupLabel,
                    resultGroupToVisitResults.get(groupLabel)
                );
                if (
                    !String.isBlank(ctp.Participant_Visit_Result_Group__c) &&
                    groupLabel == ctp.Participant_Visit_Result_Group__c
                ) {
                    resultGroupWrapper.displayOnMyResultCard = true;
                }
                initData.groups.add(resultGroupWrapper);
            }

            List<Study_Site__c> studySites = [
                SELECT Visit_Results_Sharing__c
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c = :ctpId
            ];
            Set<Id> selectedSSIds = new Set<Id>();
            for (Study_Site__c ss : studySites) {
                if (
                    ctp.Shareback_Settings_on_StudySites__c && ss.Visit_Results_Sharing__c ||
                    !ctp.Shareback_Settings_on_StudySites__c && !ss.Visit_Results_Sharing__c
                ) {
                    selectedSSIds.add(ss.Id);
                }
            }
            String ssSelectionType;
            if (studySites.size() == selectedSSIds.size()) {
                ssSelectionType = ctp.Shareback_Settings_on_StudySites__c
                    ? TYPE_ALL
                    : TYPE_DISABLED;
            } else if (ctp.Shareback_Settings_on_StudySites__c) {
                ssSelectionType = TYPE_STUDY_SITES;
            } else {
                ssSelectionType = TYPE_STUDY_SITES_DISABLED;
            }

            String selectionCountryType;
            if (ctp.Shareback_Settings_On_Country_Level__c) {
                selectionCountryType = String.isNotBlank(ctp.Shareback_Settings_Countries__c)
                    ? TYPE_COUNTRIES
                    : TYPE_ALL;
            } else {
                selectionCountryType = ctp.Shareback_Settings_Countries__c != null
                    ? TYPE_COUNTRIES_DISABLED
                    : TYPE_DISABLED;
                selectionCountryType = TYPE_DISABLED;
            }

            initData.options = new OptionsWrapper();
            initData.options.globalShareBck = ctp.Visit_Data_Shareback__c;
            initData.options.participantDefault = ctp.Shareback_Settings_On_Participant_Level__c
                ? 'Opt in'
                : 'Opt out';
            initData.options.selectedSSIds = String.join(new List<Id>(selectedSSIds), ';');
            initData.options.selectedStatuses = ctp.Shareback_Availability_Status__c != null
                ? ctp.Shareback_Availability_Status__c
                : '';
            initData.options.ssSelectionType = ssSelectionType;
            initData.options.showAfterDays = (Integer) ctp.Shareback_Availability_Timing__c;
            initData.options.whenToShow = ctp.Shareback_Availability_Timing__c > 0
                ? 'After'
                : 'Immediate';
            initData.options.inPatientPortal = ctp.Patient_Portal_Enabled__c;
            initData.options.countrySelectionType = selectionCountryType;
            initData.options.selectedCountries = ctp.Shareback_Settings_Countries__c == null
                ? ''
                : ctp.Shareback_Settings_Countries__c;

            return initData;
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void saveSharingRules(String options, String groups, String ctpId) {
        try {
            List<VisitResultGroupWrapper> groupsList = (List<VisitResultGroupWrapper>) JSON.deserialize(
                groups,
                List<VisitResultGroupWrapper>.class
            );
            OptionsWrapper optionsWrapper = (OptionsWrapper) JSON.deserialize(
                options,
                OptionsWrapper.class
            );

            Clinical_Trial_Profile__c ctp = VisitResultSharingService.getCTP(ctpId);

            ctp.Visit_Data_Shareback__c = optionsWrapper.globalShareBck;
            List<Id> ssIds;
            if (!ctp.Visit_Data_Shareback__c) {
                VisitResultSharingService.disableShareback(ctp);
                ssIds = new List<Id>();
                optionsWrapper.ssSelectionType = TYPE_DISABLED;
            } else {
                ctp.Shareback_Availability_Timing__c = optionsWrapper.showAfterDays;
                ctp.Shareback_Availability_Status__c = optionsWrapper.selectedStatuses;
                ctp.Shareback_Settings_On_Participant_Level__c = optionsWrapper.participantDefault.equals(
                    'Opt in'
                );
                ctp.Shareback_Settings_on_StudySites__c =
                    optionsWrapper.ssSelectionType.equals(TYPE_ALL) ||
                    optionsWrapper.ssSelectionType.equals(TYPE_STUDY_SITES);
                ctp.Shareback_Settings_On_Country_Level__c =
                    optionsWrapper.countrySelectionType.equals(TYPE_ALL) ||
                    optionsWrapper.countrySelectionType.equals(TYPE_COUNTRIES);
                ctp.Shareback_Settings_Countries__c = optionsWrapper.selectedCountries != null
                    ? optionsWrapper.selectedCountries
                    : '';

                ssIds = optionsWrapper.selectedSSIds.split(';');
                if (ctp.Shareback_Settings_On_Country_Level__c) {
                    for (VisitResultGroupWrapper groupWrapper : groupsList) {
                        if (groupWrapper.displayOnMyResultCard) {
                            ctp.Participant_Visit_Result_Group__c = groupWrapper.label;
                        }
                    }
                } else {
                    ctp.Participant_Visit_Result_Group__c = '';
                }
                updateVRTSharing(
                    groupsList,
                    VisitResultSharingService.getTypeVRSharingMap(ctp),
                    ctpId
                );
            }

            VisitResultSharingService.updateStudySitesSharing(
                ctpId,
                ssIds,
                optionsWrapper.ssSelectionType.equals(TYPE_ALL),
                ctp.Shareback_Settings_on_StudySites__c
            );

            update ctp;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static void updateVRTSharing(
        List<VisitResultGroupWrapper> groups,
        Map<String, Visit_Result_Type_Sharing__c> typeVRSharingMap,
        String ctpId
    ) {
        List<Visit_Result_Type_Sharing__c> forDeletionSharings = new List<Visit_Result_Type_Sharing__c>();
        for (VisitResultGroupWrapper groupWrapper : groups) {
            for (VisitResultWrapper vrWrapper : groupWrapper.visitResults) {
                String countries = '';
                if (vrWrapper.type == TYPE_COUNTRIES || vrWrapper.type == TYPE_COUNTRIES_DISABLED) {
                    countries = vrWrapper.countryCodes;
                } else if (vrWrapper.type == TYPE_ALL) {
                    countries = TYPE_ALL;
                }

                if (!typeVRSharingMap.containsKey(vrWrapper.value)) {
                    if (vrWrapper.type != TYPE_DISABLED) {
                        typeVRSharingMap.put(
                            vrWrapper.value,
                            new Visit_Result_Type_Sharing__c(
                                Clinical_Trial_Profile__c = ctpId,
                                Include_Countries__c = vrWrapper.type == TYPE_COUNTRIES,
                                Type__c = vrWrapper.value,
                                Sharing_Countries__c = countries,
                                Custom_Tooltip__c = vrWrapper.customTooltip
                            )
                        );
                    }
                } else {
                    Visit_Result_Type_Sharing__c sharing = typeVRSharingMap.get(vrWrapper.value);
                    if (vrWrapper.type == TYPE_DISABLED) {
                        forDeletionSharings.add(typeVRSharingMap.remove(vrWrapper.value));
                    } else {
                        sharing.Sharing_Countries__c = countries;
                        sharing.Include_Countries__c = vrWrapper.type == TYPE_COUNTRIES;
                        sharing.Custom_Tooltip__c = vrWrapper.customTooltip;
                        typeVRSharingMap.put(vrWrapper.value, sharing);
                    }
                }
            }
        }
        if (!forDeletionSharings.isEmpty())
            delete forDeletionSharings;
        upsert typeVRSharingMap.values();
    }
}
