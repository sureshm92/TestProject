/**
 * Created by Vicky on 21.05.2019.
 */
({   
    doInit: function (component, event, helper) {
        component.find('modalSpinner').show();
        
        helper.clearInviteFields(component, event, helper);
        helper.studyContact(component, event, helper);
        helper.mediaType(component, event, helper);
    },
    
    doExecute: function (component, event, helper) {
        
        component.find('modalSpinner').hide();
        helper.clearInviteFields(component, event, helper);
        component.set('v.refreshView', true);
        component.set('v.refreshView', false);
        component.set('v.isDuplicate', false);
        component.set('v.providerFound', false);
        component.set('v.isphone', false);
        component.set('v.isemail', false);
        component.checkfields(component,event,helper);
        component.find('inviteRPDialog').show();
    },
    
    
    preferredType: function (component, event, helper) {
        var study = component.get('v.study');
        var preferred = component.get('v.preferred');
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var emailLabel = $A.get("$Label.c.PG_MRC_RF_Email");
        var phoneLabel = $A.get("$Label.c.PG_MRC_RF_Phone");
        
        if(preferred==othermail){
            component.set('v.isemail', true);
            component.set('v.isphone', false);
        }
        if(preferred==otherPhone){
            component.set('v.isemail', false);
            component.set('v.isphone', true);
        }
        if(preferred==emailLabel){
            component.set('v.isemail', false);
            component.set('v.isphone', false);
        }
        if(preferred==phoneLabel){
            component.set('v.isemail', false);
            component.set('v.isphone', false);
        }
        
    },
    studyType: function (component, event, helper) {
        var study = component.get('v.study');
        console.log('STUDYType>>'+JSON.stringify(study));
        communityService.executeAction(component, 'getstudyType', {
            study:study
        }, function (returnValue) {
            var studyData = JSON.parse(returnValue);
            component.set("v.studyEmail",studyData.preEmail);
            component.set("v.studyPhone",studyData.prePhone);
            helper.studyDatafun(component, event, helper,study);
            component.find('modalSpinner').hide();
        });
    },
    startdateController : function(component, event, helper){
        var startdt = component.get('v.startdt');
        var enddt = component.get('v.enddt');
        var startdate = $A.get("$Label.c.Start_Date");
        if((enddt != '') && (startdt > enddt)){
            component.set("v.startrequestedError", startdate);
            component.set("v.startdt", '');
        }else{
            component.set("v.startrequestedError", '');
        }
    },
    enddateController : function(component, event, helper){
        var startdt = component.get('v.startdt');
        var enddt = component.get('v.enddt');
        var enddate = $A.get("$Label.c.End_Date");
        if(enddt < startdt){
            component.set("v.endrequestedError", enddate);
            component.set("v.enddt", '');
        }else{
            component.set("v.endrequestedError", '');
        }
    },
    emailFormatType : function(component, event, helper){
        var email = event.getSource().get('v.value');
        if(email && communityService.isValidEmail(email)){
            event.getSource().setCustomValidity('');
            event.getSource().reportValidity();
            component.find('modalSpinner').show();
        }
        if(email && !communityService.isValidEmail(email)){
            
            event.getSource().setCustomValidity($A.get('$Label.c.TST_Invalid_email_address'));
            
            event.getSource().reportValidity();
        }
        
    },
    phoneFormatType : function(component, event, helper){
        
        var phone = component.get('v.phone');
        var reg = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/;
        var isPhoneValid = reg.test(phone);
        if (isPhoneValid == false) 
        {
            component.set("v.phone", '');
            
            
        }
        return true;
    },
    submit : function (component, event, helper) {
        var study = component.get('v.study');
        var site = component.get('v.site');
        var studyEmail = component.get('v.studyEmail');
        var studyPhone = component.get('v.studyPhone');
        
        var cntValidEmail;
        var cntValidPhone;
        var cntemail;
        var cntPhone;
        var preferred = component.get('v.preferred');
        
        var othermail = $A.get("$Label.c.Other_Email");
        var otherPhone = $A.get("$Label.c.Other_Phone_Number");
        var emailLabel = $A.get("$Label.c.PG_MRC_RF_Email");
        var phoneLabel = $A.get("$Label.c.PG_MRC_RF_Phone");
        
        if(preferred == emailLabel){
            cntemail=true;
        }else{
            cntemail=false;
        }
        if(preferred == phoneLabel){
            cntPhone=true;
        }else{
            cntPhone=false;
        }
        if(preferred == othermail){
            cntValidEmail=true;
        }else{
            cntValidEmail=false;
        }
        if(preferred == otherPhone){
            cntValidPhone=true;
        }else{
            cntValidPhone=false;
        }
        var preferred = component.get('v.preferred');
        var media = component.get('v.media');
        var phone = component.get('v.phone');
        var emailS = component.get('v.emailS');
        var startdt = component.get('v.startdt');
        var enddt = component.get('v.enddt');
        var notes = component.get('v.notes');
        var prefferedtype='';
        var emailVal='';
        var stemailVal='';
        var startdate;
        var endDate;
        
        emailVal = emailS;
        stemailVal = studyEmail;
        
        if((emailVal == '' || emailVal == undefined) && (phone == '' || phone == undefined) && (stemailVal != '' || stemailVal != undefined) && (studyPhone != '' || studyPhone != undefined) && cntValidEmail && !cntemail && !cntPhone){
            prefferedtype = emailVal;
        }
        if((emailVal != '' || emailVal != undefined) && (phone == '' || phone == undefined) && (stemailVal == '' || stemailVal == undefined) && (studyPhone == '' || studyPhone == undefined) && cntValidEmail && !cntemail && !cntPhone){
            prefferedtype = emailVal;
        }
        if((emailVal != '' || emailVal != undefined) && (phone == '' || phone == undefined) && (stemailVal != '' || stemailVal == undefined) && (studyPhone != '' || studyPhone == undefined) && cntValidEmail && !cntemail && !cntPhone){
            prefferedtype = emailVal;
        }
        if((phone != '' || phone != undefined) && (emailVal == '' || emailVal == undefined) && (stemailVal != '' || stemailVal != undefined) && (studyPhone != '' || studyPhone != undefined) && cntValidPhone && !cntemail && !cntPhone){
            prefferedtype = phone;
        }
        if((phone != '' || phone != undefined) && (emailVal == '' || emailVal == undefined) && (stemailVal == '' || stemailVal == undefined) && (studyPhone == '' || studyPhone == undefined) && cntValidPhone && !cntemail && !cntPhone){
            prefferedtype = phone;
        }
        
        
        if((stemailVal != '' || stemailVal != undefined) && (phone == '' || phone == undefined) && (emailVal == '' || emailVal == undefined) && (studyPhone != '' || studyPhone != undefined) && cntemail){
            prefferedtype = stemailVal;
        }
        if((stemailVal != '' || stemailVal != undefined) && (phone == '' || phone == undefined) && (emailVal == '' || emailVal == undefined) && (studyPhone == '' || studyPhone == undefined) && cntemail){
            prefferedtype = stemailVal;
        }
        if((studyPhone != '' || studyPhone != undefined) && (phone == '' || phone == undefined) && (emailVal == '' || emailVal == undefined) && (stemailVal != '' || stemailVal != undefined) && cntPhone){
            prefferedtype = studyPhone;
        }
        if((studyPhone != '' || studyPhone != undefined) && (phone == '' || phone == undefined) && (emailVal == '' || emailVal == undefined) && (stemailVal == '' || stemailVal == undefined) && cntPhone){
            prefferedtype = studyPhone;
        }
        component.find('modalSpinner').show();
        
        communityService.executeAction(component, 'inviteNewMedia', {
            study:study,
            site:site,
            prefferedtype: prefferedtype,
            media: media,
            startdt: startdt,
            enddt: enddt,
            notes: notes
        }, function (returnValue) {
            component.find('modalSpinner').hide();
            var cmpEvent = component.getEvent("cmpRefEvent");
            cmpEvent.fire();
            helper.clearInviteFields(component, event, helper)
            component.find('inviteRPDialog').hide();
            communityService.showToast("success", "success", $A.get("$Label.c.Outreach_Message"));
        });
        
        
    },
    
    checkReqFields : function (component, event, helper) {
        helper.checkFields(component,event,helper);
    },
    doClearInviteAndHide: function (component, event, helper) {
        helper.clearInviteFields(component, event, helper)
        component.find('inviteRPDialog').hide();
    }
})