/**
 * Created by Andrii Kryvolap
 */
({

    initButtonsMap: function () {
        this.allButtonsMap = {
            'account-settings': {
                page: 'account-settings',
                label: $A.get('$Label.c.Profile_Menu_Account_Settings'),
                icon: 'cog'
            },
            'my-team': {
                page: 'my-team',
                label: $A.get('$Label.c.PG_PST_L_My_Team'),
                icon: 'delegate'
            },
            'delegates': {
                page: 'my-team',
                label: $A.get('$Label.c.PG_PST_L_Delegates'),
                icon: 'delegate'
            }

        };

        this.buttonsMap = {
            'RH_Only': [
                this.allButtonsMap['account-settings'],
                this.allButtonsMap['my-team'],
            ],
            'RH_Single_View': [
                this.allButtonsMap['account-settings'],
                this.allButtonsMap['my-team'],
            ]
        };
    },
})