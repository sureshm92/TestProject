/**
 * Created by Vicky on 21.05.2019.
 */
({
    clearInviteFields: function (component, event, helper) {
        component.set('v.study', '');
        component.set('v.preferred', '');
        component.set('v.media', '');
        component.set('v.phone', '');
        component.set('v.emailS', '');
        component.set('v.startdt', '');
        component.set('v.enddt', '');
        component.set('v.site', '');
        component.set('v.notes', '');
        component.set('v.endrequestedError', '');
        component.set('v.startrequestedError', '');
        component.set('v.phoneError', '');
        component.set('v.emailError', '');
        component.set('v.studyData', '');
        component.set('v.isDuplicate', false);
    },

    studyContact: function (component, event, helper) {
        communityService.executeAction(component, 'getstudyContact', {}, function (returnValue) {
            console.log('studycontacthelper>>' + JSON.stringify(returnValue));
            component.set('v.studysite', returnValue);
        });
    },
    mediaType: function (component, event, helper) {
        var opts = [];
        //var mediaOutreach = $A.get('$Label.c.Media_Outreach');
        //var mediatType = $A.get('$Label.c.Media_Type');
        var mediaOutreach = 'Media_Outreach__c';
        var mediatType ='Media_Type__c';
        communityService.executeAction(
            component,
            'getPickListValues',
            {
                obj: mediaOutreach,
                str: mediatType
            },
            function (returnValue) {
                var studySite = returnValue;
                for (var key in studySite) {
                    opts.push({ label: key, value: studySite[key] });
                }
                component.set('v.mediaType', opts);
            }
        );
    },

    checkFields: function (component, event, helper) {
        var study = component.get('v.study');
        var site = component.get('v.site');
        var preferred = component.get('v.preferred');
        var media = component.get('v.media');
        var studyEmail = component.get('v.studyEmail');
        var studyPhone = component.get('v.studyPhone');
        var phone = component.get('v.phone');
        var emailS = component.get('v.emailS');
        var inputPattern = new RegExp('[!+@#$%^&*(),.?":{}|<>]', 'g');
        var phonePattern = new RegExp('[!@#$%^&*,.?":{}|<>]', 'g');
        //var isPhoneValid = !phonePattern.test(phone);
        // var isstudyPhoneValid = !phonePattern.test(studyPhone);
        var othermail = $A.get('$Label.c.Other_Email');
        var otherPhone = $A.get('$Label.c.Other_Phone_Number');
        var emailLabel = $A.get('$Label.c.PG_MRC_RF_Email');
        var phoneLabel = $A.get('$Label.c.PG_MRC_RF_Phone');
        var reqFieldsFilled;
        if (study == '' || study == undefined) {
            reqFieldsFilled = true;
        }
        if (site == '' || site == undefined) {
            reqFieldsFilled = true;
        }
        if (media == '' || media == undefined) {
            reqFieldsFilled = true;
        }

        if (preferred == '' || preferred == undefined) {
            reqFieldsFilled = true;
        }
        if (preferred == othermail && (emailS == '' || emailS == undefined)) {
            reqFieldsFilled = true;
        }
        if (preferred == otherPhone && (phone == '' || phone == undefined)) {
            reqFieldsFilled = true;
        }

        var delegatePIs = component.get('v.PIForInvetation');
        if (delegatePIs.length > 0) {
            var chosenPis = component.get('v.checkboxGroupValues');
            if (chosenPis.length < 1) {
                reqFieldsFilled = false;
            }
        }
        component.set('v.reqFieldsFilled', reqFieldsFilled);
    }
});
