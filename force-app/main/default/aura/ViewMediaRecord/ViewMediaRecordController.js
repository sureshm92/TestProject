({
    doInit: function(component, event, helper) {
        //component.find('modalSpinner').show();
    },
    doExecute: function(component, event, helper) {

        component.find('ShowPoP_Up').show();
        component.find('modalSpinnerpopup').show();
        component.set("v.buttonDisable", false);
        component.set("v.ViewRecordId", component.get("v.ViewRecord")[0]
            .Id);
        component.set("v.AlternatePhone_email", "");
        if (component.get("v.disablefield")) {
            component.set("v.disabled", true);
        }
        communityService.executeAction(component,
            'PreferredContactsandNotes', {
                studysiteId: component.get(
                    "v.ViewRecord[0].Study_Name__c"),
                MediaRecordId: component.get("v.ViewRecordId")
            },
            function(returnValue) {
                var resultData = JSON.parse(returnValue);
                component.set("v.lstNotes", resultData.lstnotes);
                component.set("v.MOEmail", resultData.MOEmail);
                component.set("v.MOPhone", resultData.MOPhone);
                component.set("v.Other", resultData.Other);
                component.set("v.MO_Phonenumber", resultData.MO_Phonenumber);
                component.set("v.MO_Email", resultData.MO_Email);
                component.set("v.MO_Value", resultData.MO_Value);
                var Picklist_option = [];

                if (component.get("v.MOEmail") == false &&
                    component.get("v.MOPhone") == true &&
                    component.get("v.Other") == false) {
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ':' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ':' + component.get(
                                "v.MO_Email")
                        });
                    }
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Phone_Number"
                        )
                    });
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Email")
                    });
                    component.set("v.PC_Value", Picklist_option);
                }
                if (component.get("v.MOEmail") == false &&
                    component.get("v.MOPhone") == true &&
                    component.get("v.Other") == true) {
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Phone_Number"
                        )
                    });
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Email")
                    });
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ':' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ':' + component.get(
                                "v.MO_Email")
                        });
                    }
                    component.set("v.PC_Value", Picklist_option);
                }
                if (component.get("v.MOEmail") == true && component
                    .get("v.MOPhone") == false &&
                    component.get("v.Other") == false) {

                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ':' + component.get(
                                "v.MO_Email")
                        });
                    }
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ':' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Email")
                    });
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Phone_Number"
                        )
                    });
                    component.set("v.PC_Value", Picklist_option);
                }
                if (component.get("v.MOEmail") == true && component
                    .get("v.MOPhone") == false &&
                    component.get("v.Other") == true) {
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Email")
                    });
                    Picklist_option.push({
                        value: $A.get(
                            "$Label.c.Other_Phone_Number"
                        )
                    });
                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ':' + component.get(
                                "v.MO_Email")
                        });
                    }
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ':' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    component.set("v.PC_Value", Picklist_option);
                }
                var otheremail = $A.get("$Label.c.Other_Email");
                var otherpone = $A.get(
                    "$Label.c.Other_Phone_Number");
                if (Picklist_option[0].value == otheremail) {
                    if (component.get("v.ActiveReqRecord")) {
                        component.set("v.disabled", false);
                    } else {
                        component.set("v.disabled", true);
                    }
                    component.set("v.AlternatePhone_email",
                        component.get("v.MO_Value")
                    );
                } else if (Picklist_option[0].value == otherpone) {
                    if (component.get("v.ActiveReqRecord")) {
                        component.set("v.disabled", false);

                    } else {
                        component.set("v.disabled", true);
                    }
                    component.set("v.AlternatePhone_email",
                        component.get("v.MO_Value"));
                } else {
                    component.set("v.disabled", true);
                }
                component.set("v.preferred", Picklist_option[0].value);
                component.set("v.Picklistdefaultvalue",
                    Picklist_option[0].value);
            });
        component.find('modalSpinnerpopup').hide();
    },
    preferredType: function(component, event, helper) {
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var picklistval = component.find('preferredId').get('v.value');
        if (picklistval == othermail) {
            component.set("v.disabled", false);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                component.set("v.AlternatePhone_email", component.get(
                    "V.MO_Value"));

            } else {
                component.set("v.AlternatePhone_email", "");
            }
        } else if (picklistval == otherPhone) {
            component.set("v.disabled", false);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                component.set("v.AlternatePhone_email", component.get(
                    "V.MO_Value"));

            } else {
                component.set("v.AlternatePhone_email", "");
            }
        } else {
            component.set("v.disabled", true);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                component.set("v.AlternatePhone_email", component.get(
                    "V.MO_Value"));

            } else {
                component.set("v.AlternatePhone_email", "");
            }
        }

    },
    CancelPoPUp: function(component, event, helper) {
        component.find('ShowPoP_Up').hide();
    },
    save: function(component, event, helper) {
        component.find('modalSpinner').show();
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var picklistval = component.find('preferredId').get('v.value');
        var PC_oldvalue = component.get("V.MO_Value");
        var PC_Newvalue = "";
        var update = true;
        var existingvalue_phone = $A.get("$Label.c.PG_MRC_RF_Phone") +
            ':' + component.get("v.MO_Phonenumber");
        if (picklistval == othermail) {
            console.log('picklistval', picklistval);
            console.log('current value', component.get('v.PC_Value')[0]
                .value);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                if (PC_oldvalue == component.get(
                        "v.AlternatePhone_email")) {
                    update = false;
                } else {
                    PC_Newvalue = component.find('alternate').get(
                        "v.value");
                    update = true;
                }
            } else {
                PC_Newvalue = component.find('alternate').get("v.value");
                update = true;
            }
        } else if (picklistval == otherPhone) {
            if (PC_oldvalue == component.get("v.AlternatePhone_email")) {
                update = false;
            } else {
                //PC_Newvalue = component.get("v.AlternatePhone_email");
                PC_Newvalue = component.find('alternate').get("v.value");
                update = true;
            }
        } else {
            if (picklistval == existingvalue_phone) {
                if (PC_oldvalue == component.get("v.MO_Phonenumber")) {
                    update = false;
                } else {
                    update = true;
                    PC_Newvalue = component.get("v.MO_Phonenumber");
                }
            } else {
                if (PC_oldvalue == component.get("v.MO_Email")) {
                    update = false;
                } else {
                    update = true;
                    PC_Newvalue = component.get("v.MO_Email");
                }
            }
        }

        var notes = component.get('v.notes');
        communityService.executeAction(component, 'UpdateRecord', {
            MediaRecordId: component.get("v.ViewRecordId"),
            updateval: update,
            newval: PC_Newvalue,
            notes: notes,
            Cancelrequest: 'false'
        }, function(returnValue) {
            var initData = JSON.parse(returnValue);
            component.find('modalSpinner').hide();
            component.find('ShowPoP_Up').hide();
            communityService.showToast("success", "success", $A
                .get(
                    "$Label.c.MO_RecordUpdate"
                ));
        });
        component.set("v.notes", '');
        component.set("v.preferred", '');
    },
    CancelRequest: function(component, event, helper) {
        component.set("v.buttonDisable", true);
        component.set("v.disablefield", true);
        component.set("v.disabled", true);
        component.find('CancelRequest').execute();
    },
    closepopup: function(component, event, helper) {
        var message = event.getParam("closeAllPopup");
        if (message == "no") {
            component.set("v.buttonDisable", false);
            component.set("v.disablefield", false);
            component.set("v.disabled", false);
        } else {
            component.find('ShowPoP_Up').hide();
            var cmpEvent = component.getEvent("cmpRefEvent");
            cmpEvent.fire();
        }
    }
})