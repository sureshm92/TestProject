({
    doInit: function (component, event, helper) {

        var teamMember = {};
        teamMember.name = '';
        teamMember.nameErrorMessage = '';
        teamMember.lastName = '';
        teamMember.lastNameErrorMessage = '';
        teamMember.email = '';
        teamMember.emailErrorMessage = '';
        teamMember.access = '';
        teamMember.accessErrorMessage = '';

        component.set("v.teamMember", teamMember);

        var userMode = component.get("v.userMode");
        var accessOptions = component.get("v.options");

        if(!userMode || !accessOptions){
            console.log("incorrect data");
            console.log("userMode= " + userMode);
            console.log("accessOptions= " + accessOptions);
            return;
        }

        var delegateDetailList = [];

        for(var j = 0; j < accessOptions.length; j++){

            var newDelegateDetail = {};
            newDelegateDetail.name = "Delegate Level " + (j + 1) + ": ";
            newDelegateDetail.description = accessOptions[j].label + ".";
            delegateDetailList.push(newDelegateDetail);
        }

        if(userMode === "PI"){
            delegateDetailList[2].additionalDescription = {};
            delegateDetailList[2].additionalDescription.can ="change status of Contact Attempts and Initial Visit and Screening. Can run reports. Can enter patient details. Call for help.";
            delegateDetailList[2].additionalDescription.canNot = "change status of other steps of patient intake. Can't indicate Open to Receiving Referrals. Can't manage HCP. Can't accept HCP. Can't accept or decline referrals, delegate to others.";
        } else if(userMode === "HCP") {
            delegateDetailList[2].additionalDescription = {};
            delegateDetailList[2].additionalDescription.can = "run reports, send attachments to PI. Can enter patient details. Access library. Call for help. Can do chart review.";
            delegateDetailList[2].additionalDescription.canNot = "do pre-eligibility screening. Can't refer a patient. Can't exclude from referring. Can't delegate to others.";
        } else {
            console.log("ERROR: incorrect UserMode= " + userMode);
            return;
        }

        component.set("v.delegateDetailList", delegateDetailList);
    },
    inviteMembers: function (component, event, helper) {

        var buttonId = event.currentTarget.id;
        if(buttonId === "0") {
            component.set('v.show', false);
            return;
        }

        var spinner = component.find('footerSpinner');
        spinner.show();

        var emailRegEx = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var teamMember = component.get("v.teamMember");
        var hasErrors = false;
        var validRecord = false;

        teamMember.nameErrorMessage = "";
        teamMember.lastNameErrorMessage = "";
        teamMember.emailErrorMessage = "";
        teamMember.accessErrorMessage = "";

        if(!teamMember.name) {
            teamMember.nameErrorMessage = "Complete this field.";
            hasErrors = true;
        }

        if(!teamMember.lastName) {
            teamMember.lastNameErrorMessage = "Complete this field.";
            hasErrors = true;
        }

        if(!teamMember.access) {
            teamMember.accessErrorMessage = "Select access rights!";
            hasErrors = true;
        }

        if(teamMember.email) {

            if(emailRegEx.test(String(teamMember.email).toLowerCase())){
                validRecord = true;
            } else {
                teamMember.emailErrorMessage = "Wrong email format!";
                hasErrors = true;
            }

        } else {
            teamMember.emailErrorMessage = "Complete this field.";
            hasErrors = true;
        }

        if(hasErrors || !validRecord){
            component.set("v.teamMember", teamMember);
            spinner.hide();
        } else {

            var userMode = component.get('v.userMode');
            var newContact = {};

            newContact.FirstName = teamMember.name;
            newContact.LastName = teamMember.lastName;
            newContact.Email = teamMember.email;

            if(userMode === "HCP"){
                newContact.HCP_DelegateAccessLevel__c = teamMember.access;
            } else if(userMode === "PI"){
                newContact.PI_DelegateAccessLevel__c = teamMember.access;
            }

            var action = component.get('c.addDelegateContact');
            action.setParams({
                contact: JSON.stringify(newContact),
                userMode: userMode
            });
            action.setCallback(this, function (response) {

                if (response.getState() === "SUCCESS") {

                    var isSuccess = response.getReturnValue();

                    if(isSuccess) {
                        communityService.showToast("success", "success", "Delegates was successfully created!");
                        spinner.hide();
                        var parent = component.get('v.parentComponent');
                        if(parent) parent.refresh();
                    } else {
                        teamMember.emailErrorMessage = "Duplicate email!";
                        component.set("v.teamMember", teamMember);
                        spinner.hide();
                    }
                } else {
                    communityService.showToast("error", "error", "Something went wrong!");
                    communityService.logErrorFromResponse(response);
                }
            });
            $A.enqueueAction(action);
        }
    }
})