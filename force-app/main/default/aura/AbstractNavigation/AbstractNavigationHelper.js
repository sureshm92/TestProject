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

            'medical-record-review-log': {
                page: 'medical-record-review-log',
                label: $A.get('$Label.c.Navigation_Medical_Record_Review_Log'),
                icon: 'chart-review-sent'
            },

            'my-study-sites': {
                page: 'my-study-sites',
                label: $A.get('$Label.c.Navigation_My_Study_Sites'),
                icon: 'referred-clinic'
            },

            'reports': {
                page: 'reports',
                label: $A.get('$Label.c.Navigation_Reports'),
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
            }



        };

        //init items for every type
        this.itemsMap = {

            Participant: [
                this.allPagesMap[''],
                this.allPagesMap['help']
            ],

            PI: [
                this.allPagesMap[''],
                this.allPagesMap['dashboard'],
                this.allPagesMap['my-referrals'],
                this.allPagesMap['my-referring-clinics'],
                this.allPagesMap['reports'],
                this.allPagesMap['help']
            ],

            HCP: [
                this.allPagesMap[''],
                this.allPagesMap['dashboard'],
                this.allPagesMap['my-patients'],
                this.allPagesMap['medical-record-review-log'],
                this.allPagesMap['my-study-sites'],
                this.allPagesMap['reports'],
                this.allPagesMap['help']
            ]
        }
    },

    updateDocumentTitle: function (component, pageName) {
        var page = this.allPagesMap[pageName];
        if(page) document.title = page.label;
    }

})