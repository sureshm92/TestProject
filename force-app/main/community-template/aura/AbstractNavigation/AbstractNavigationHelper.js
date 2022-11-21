/**
 * Created by Leonid Bartenev
 */
({
    initItemsMap: function (component, event) {
        //define navigation items:
        this.allPagesMap = {
            '': {
                page: '',
                label: $A.get('$Label.c.Navigation_My_Studies'),
                icon: 'clinical-trial'
            },

            'my-patients': {
                page: 'my-patients',
                label: $A.get('$Label.c.Navigation_My_Patients'),
                icon: 'referred-patient'
            },

            dashboard: {
                page: 'dashboard',
                label: $A.get('$Label.c.Navigation_Dashboard'),
                icon: 'dashboard'
            },
            'resources-pi': {
                page: 'resources-pi',
                label: $A.get('$Label.c.Navigation_Resources'),
                icon: 'resources'
            },

            // 'medical-record-review-log': {
            //     page: 'medical-record-review-log',
            //     label: $A.get('$Label.c.Navigation_Medical_Record_Review_Log'),
            //     icon: 'chart-review-sent'
            // },

            // 'my-study-sites': {
            //     page: 'my-study-sites',
            //     label: $A.get('$Label.c.Navigation_My_Study_Sites'),
            //     icon: 'referred-clinic'
            // },

            reports: {
                page: 'reports',
                label: $A.get('$Label.c.Navigation_Reports'),
                icon: 'reports'
            },

            'sites-search': {
                page: 'sites-search',
                label: $A.get('$Label.c.Search_For_Sites'),
                icon: 'reports'
            },
            'medical-record-review': {
                page: 'sites-search',
                label: $A.get('$Label.c.Medical_Record_Review'),
                icon: 'reports'
            },

            help: {
                page: 'help',
                label: $A.get('$Label.c.Navigation_Help'),
                icon: 'help'
            },

            'my-referrals': {
                page: 'my-referrals',
                label: $A.get('$Label.c.Navigation_My_Referrals'),
                icon: 'referrals'
            },

            'my-referring-clinics': {
                page: 'my-referring-clinics',
                label: $A.get('$Label.c.Navigation_My_Referring_Clinics'),
                icon: 'referred-clinic'
            },

            referring: {
                page: 'referring',
                label: $A.get('$Label.c.Referring')
            },

            'study-workspace': {
                page: 'study-workspace',
                label: $A.get('$Label.c.PG_SW_Title')
            },

            'referral-profile': {
                page: 'referral-profile',
                label: $A.get('$Label.c.PG_RP_L_Referral_Profile')
            },

            'patient-profile': {
                page: 'patient-profile',
                label: $A.get('$Label.c.PG_PP_L_Patient_Profile')
            },

            settings: {
                page: 'settings',
                label: $A.get('$Label.c.Navigation_Settings')
            },

            'participant-home': {
                page: '',
                label: $A.get('$Label.c.Navigation_Home'),
                icon: 'icon-home-brand-new'
            },

            'my-study': {
                page: 'study-workspace',
                label: $A.get('$Label.c.Navigation_My_Study'),
                icon: 'about-the-study'
            },

            resources: {
                page: 'study-workspace',
                label: $A.get('$Label.c.Navigation_Resources'),
                icon: 'resources'
            },

            'past-studies': {
                page: 'past-studies',
                label: $A.get('$Label.c.Navigation_Past_Studies'),
                icon: 'plan-check-in-square'
            },

            messages: {
                page: 'messages',
                label: $A.get('$Label.c.Navigation_Messages'),
                icon: 'icon-envelope'
            },

            'e-diaries': {
                page: 'e-diaries',
                label: $A.get('$Label.c.Navigation_eDiary'),
                icon: 'icon-e-diaries'
            },

            'trial-match': {
                page: 'trial-match',
                label: $A.get('$Label.c.Trial_Match'),
                icon: 'trial-match-mob'
            },

            'site-list': {
                page: '',
                label: $A.get('$Label.c.CC_HomePageLabel'),
                icon: 'siteListbuilding'
            }
        };

        //init items for every type
        let participantTabs = [];
        if (communityService.getCurrentCommunityTemplateName() == 'PatientPortal') {
            let homepage = this.allPagesMap[''];
            homepage.label =  $A.get('$Label.c.Navigation_Home');
        }
        participantTabs.push(this.allPagesMap['participant-home']);
        if (communityService.getCurrentCommunityMode().currentPE) {
            if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                participantTabs.push(this.allPagesMap['my-study']);
            }
        } else {
            if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                participantTabs.push(this.allPagesMap['resources']);
            }
        }
        if (communityService.getCurrentCommunityMode().hasPastStudies) {
            if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                participantTabs.push(this.allPagesMap['past-studies']);
            }
        }
        //set eDiary tab visibility for Participants.
        if (communityService.getEDiaryVisible()) {
            if (communityService.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                    participantTabs.push(this.allPagesMap['e-diaries']);
                }
            }
        }
        if (communityService.getMessagesVisible()) {
            if (communityService.getCurrentCommunityTemplateName() != 'PatientPortal') {
                participantTabs.push(this.allPagesMap['messages']);
            }
        }
        if (communityService.getTrialMatchVisible()) {
            //PEH-2288: Check from the currentCommunityMode
            if (communityService.getCurrentCommunityMode().participantState === 'PARTICIPANT') {
                participantTabs.push(this.allPagesMap['trial-match']);
            }
        }

        participantTabs.push(this.allPagesMap['help']);

        if (component.get('v.hasMessage')) {
            this.itemsMap = {
                Participant: participantTabs,

                PI: [
                    this.allPagesMap[''],
                    this.allPagesMap['dashboard'],
                    this.allPagesMap['my-referrals'],
                    this.allPagesMap['resources-pi'],
                    //this.allPagesMap['my-referring-clinics'],
                    //this.allPagesMap['reports'],
                    this.allPagesMap['messages']
                    // this.allPagesMap['help'] //Comment as we are using help text from CustomThemeLayout Component as per REF-1343 for PI and Referral Provider
                ],

                HCP: [
                    this.allPagesMap[''],
                    this.allPagesMap['my-patients'],
                    // this.allPagesMap['medical-record-review-log'],
                    // this.allPagesMap['my-study-sites'],
                    this.allPagesMap['reports'],
                    this.allPagesMap['resources-pi']
                    // this.allPagesMap['help'] //Comment as we are using help text from CustomThemeLayout Component as per REF-1343 for PI and Referral Provider
                ],

                CC: [this.allPagesMap['site-list']]
            };
        } else {
            this.itemsMap = {
                Participant: participantTabs,

                PI: [
                    this.allPagesMap[''],
                    this.allPagesMap['dashboard'],
                    this.allPagesMap['my-referrals'],
                    this.allPagesMap['resources-pi']
                    //this.allPagesMap['my-referring-clinics'],
                    //this.allPagesMap['reports'],
                    //this.allPagesMap['messages']
                    // this.allPagesMap['help'] //Comment as we are using help text from CustomThemeLayout Component as per REF-1343 for PI and Referral Provider
                ],

                HCP: [
                    this.allPagesMap[''],
                    this.allPagesMap['my-patients'],
                    // this.allPagesMap['medical-record-review-log'],
                    // this.allPagesMap['my-study-sites'],
                    this.allPagesMap['reports'],
                    this.allPagesMap['resources-pi']
                    // this.allPagesMap['help'] //Comment as we are using help text from CustomThemeLayout Component as per REF-1343 for PI and Referral Provider
                ],

                CC: [this.allPagesMap['site-list']]
            };
        }
    },

    updateDocumentTitle: function (component, pageName) {
        if (!this.itemsMap) this.initItemsMap();
        let page = this.allPagesMap[pageName];
        if (page) document.title = page.label;
        //for CC mode
        if (communityService.getCurrentCommunityMode().userMode === 'CC' && page.page == '')
            document.title = $A.get('$Label.c.CC_HomePageLabel');
    },

    updateCurrentPage: function (component) {
        try {
            let helper = this;
            let menuItems = component.get('v.menuItems');
            let currentPageName = communityService.getPageName();
            helper.updateDocumentTitle(component, currentPageName);
            //document.title = $A.get('$Label.c.RH_Window_Title');
            component.set('v.currentPage', currentPageName);
        } catch (e) {
            console.error(e);
        }
    }
});
