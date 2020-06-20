({
    doExecute: function(component, event, helper) {

        component.find('ShowPoP_Up').show();
        component.find('modalSpinnerpopup').show();
        component.set('v.isEmailPhone', false);
        component.set("v.buttonDisable", false);
        component.set("v.ErrorMsg", "");
        component.set("v.notes", '');
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
                component.set("v.MO_AlternateValue", resultData.MO_AlternateValue);
                var Picklist_option = [];

                if (component.get("v.MOEmail") == false &&
                    component.get("v.MOPhone") == true &&
                    component.get("v.Other") == false) {
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ': ' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ': ' + component.get(
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
                    component.set('v.isEmailPhone', true);
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
                            ) + ': ' + component.get(
                                "v.MO_Phonenumber")
                        });
                    }
                    if (component.get("v.MO_Email") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Email"
                            ) + ': ' + component.get(
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
                            ) + ': ' + component.get(
                                "v.MO_Email")
                        });
                    }
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ': ' + component.get(
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
                    component.set('v.isEmailPhone', true);
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
                            ) + ': ' + component.get(
                                "v.MO_Email")
                        });
                    }
                    if (component.get("v.MO_Phonenumber") != 'null') {
                        Picklist_option.push({
                            value: $A.get(
                                "$Label.c.PG_MRC_RF_Phone"
                            ) + ': ' + component.get(
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
                        component.get("v.MO_AlternateValue")
                    );
                } else if (Picklist_option[0].value == otherpone) {
                    if (component.get("v.ActiveReqRecord")) {
                        component.set("v.disabled", false);

                    } else {
                        component.set("v.disabled", true);
                    }
                    component.set("v.AlternatePhone_email",
                        component.get("v.MO_AlternateValue"));
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
        component.set("v.ErrorMsg", "");
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var picklistval = component.find('preferredId').get('v.value');
        if (picklistval == othermail) {
            component.set("v.disabled", false);
            component.set('v.isEmailPhone', true);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                component.set("v.AlternatePhone_email", component.get(
                    "V.MO_AlternateValue"));
            } else {
                component.set("v.AlternatePhone_email", "");
            }
        } else if (picklistval == otherPhone) {
            component.set("v.disabled", false);
            component.set('v.isEmailPhone', true);
            if (component.get('v.PC_Value')[0].value == picklistval) {
                component.set("v.AlternatePhone_email", component.get(
                    "V.MO_AlternateValue"));
            } else {
                component.set("v.AlternatePhone_email", "");
            }
        } else {
            component.set("v.disabled", true);
            component.set('v.isEmailPhone', false);
            component.set("v.AlternatePhone_email", "");
        }
    },
    CancelPoPUp: function(component, event, helper) {
        component.find('ShowPoP_Up').hide();
        component.set("v.isEmailPhone", false);
    },
    updateMO: function(component, event, helper) {
        var btnclickId = event.getSource().getLocalId();
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var picklistval = component.find('preferredId').get('v.value');
        var PC_oldvalue = component.get("V.MO_AlternateValue");
        var PC_Newvalue = "";
        var update = true;
        var other = false;
        var existingvalue_phone = $A.get("$Label.c.PG_MRC_RF_Phone") +
            ': ' + component.get("v.MO_Phonenumber");
        if (picklistval == othermail) {
            other = true;
                PC_Newvalue = component.find('alternate').get(
                    "v.value");
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!PC_Newvalue.match(regExpEmailformat)) {
                    component.set("v.ErrorMsg", $A.get('$Label.c.TST_Invalid_email_address'));
                    component.set("v.Validated", false);
                } else {
                    component.set("v.Validated", true);
                    component.set("v.ErrorMsg", "");
                }
                update = true;
        } else if (picklistval == otherPhone) {
                other = true;
                PC_Newvalue = component.find('alternate').get("v.value");
                var regNumbers = /^[a-zA-Z]+$/;
                if (!PC_Newvalue.match(regNumbers)) {
                    if(PC_Newvalue == '' || PC_Newvalue == ' ' || PC_Newvalue == '  '){
                         component.set("v.Validated", false);
                            component.set("v.ErrorMsg", $A.get("$Label.c.Invalid_Phone"));
                    }else{
                         component.set("v.Validated", true);
                    component.set("v.ErrorMsg", "");
                    }
                   
                    
                } else {
                    component.set("v.Validated", false);
                    component.set("v.ErrorMsg", $A.get("$Label.c.Invalid_Phone"));
                }
                update = true;
        } else {
            if (picklistval == existingvalue_phone) {
                    update = true;
                    PC_Newvalue = component.get("v.MO_Phonenumber");
                    component.set("v.Validated", true);
            } else {
                    update = true;
                    PC_Newvalue = component.get("v.MO_Email");
                    component.set("v.Validated", true);
            }
        }
        if (component.get("v.Validated") && btnclickId=='save') {
            component.find('modalSpinner').show();
            var notes = component.get('v.notes');
            communityService.executeAction(component, 'UpdateRecord', {
                MediaRecordId: component.get("v.ViewRecordId"),
                updateval: update,
                newval: PC_Newvalue,
                notes: notes,
                other: other,
                Cancelrequest: 'false'
            }, function(returnValue) {
                var initData = JSON.parse(returnValue);
                component.find('modalSpinner').hide();
                component.find('ShowPoP_Up').hide();
                helper.showToast();
            });
            component.set("v.notes", '');
            component.set("v.preferred", '');   
        }
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
        }else if(message == "closewarningpopup")
        {
            component.find('CancelRequest').close();            
        }else {
            component.find('ShowPoP_Up').hide();
            var cmpEvent = component.getEvent("cmpRefEvent");
            cmpEvent.fire();
        }
    },

})