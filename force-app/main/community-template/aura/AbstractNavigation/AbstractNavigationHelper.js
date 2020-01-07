/**
 * Created by Leonid Bartenev
 */
({

    initItemsMap: function () {
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

            'dashboard': {
                page: 'dashboard',
                label: $A.get('$Label.c.Navigation_Dashboard'),
                icon: 'dashboard'
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

            'reports': {
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

            'help': {
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
            
            'referring': {
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

            'settings': {
                page: 'settings',
                label: $A.get('$Label.c.Navigation_Settings')
            },

            'participant-home':{
                page: '',
                label: $A.get('$Label.c.Navigation_Home'),
                icon: 'icon-home-brand-new'
            },

            'my-study':{
                page: 'study-workspace',
                label: $A.get('$Label.c.Navigation_My_Study'),
                icon: 'about-the-study'
            },

            'resources':{
                page: 'study-workspace?tab=tab-resources',
                label: $A.get('$Label.c.Navigation_Resources')
            },

            'past-studies':{
                page: 'past-studies',
                label: $A.get('$Label.c.Navigation_Past_Studies')
            },

            'messages': {
                page: 'messages',
                label: $A.get('$Label.c.Navigation_Messages'),
                icon: 'icon-envelope'
            }
        };

        //init items for every type
        var participantTabs = [];
        participantTabs.push(this.allPagesMap['participant-home']);
        if(communityService.getParticipantState() !== 'ALUMNI') {
            participantTabs.push(this.allPagesMap['my-study']);
        }else{
            participantTabs.push(this.allPagesMap['resources']);
        }
        if(communityService.isShowPastStudies()) participantTabs.push(this.allPagesMap['past-studies']);
        participantTabs.push(this.allPagesMap['messages']);
        participantTabs.push(this.allPagesMap['help']);

        this.itemsMap = {

            Participant: participantTabs,

            PI: [
                this.allPagesMap[''],
                this.allPagesMap['dashboard'],
                this.allPagesMap['my-referrals'],
                //this.allPagesMap['my-referring-clinics'],
                this.allPagesMap['reports'],
                this.allPagesMap['messages'],
                this.allPagesMap['help']
            ],

            HCP: [
                this.allPagesMap[''],
                this.allPagesMap['my-patients'],
                // this.allPagesMap['medical-record-review-log'],
                // this.allPagesMap['my-study-sites'],
                this.allPagesMap['reports'],
                this.allPagesMap['help']
            ]
        }
    },

    updateDocumentTitle: function (component, pageName) {
        if(!this.itemsMap) this.initItemsMap();
        var page = this.allPagesMap[pageName];
        if(page) document.title = page.label;
    }

})