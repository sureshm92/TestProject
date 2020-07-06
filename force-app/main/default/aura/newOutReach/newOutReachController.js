/**
 * Created by Vicky on 21.05.2019.
 */
({   
    doInit: function (component, event, helper) {
        component.find('modalSpinner').show();
        component.set('v.isCheckPhoneNumber', false);
        component.set('v.isCheckPhonenull', false);
        component.set('v.isthirdcheck', true);
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
    studyDatafun: function (component, event, helper) {
        var study = component.get('v.study');
        console.log('studyHelper>>'+JSON.stringify(study));
        communityService.executeAction(component, 'getstudyData', {
            dataStudy:study
        }, function (returnValue) {
            component.set("v.studyData",returnValue);
            console.log('returnValue>>'+JSON.stringify(returnValue));
            //  component.find('modalSpinner').hide();
            component.set('v.reqFieldsFilled', true);
            component.set("v.preferred", '');
            component.set("v.media", '');
            component.set("v.startdt", '');
            component.set("v.enddt", '');
            component.set("v.notes", '');
        });
    },
    
    studyType: function (component, event, helper) {
        
        var site = component.get('v.site');
        //console.log('STUDYType>>'+JSON.stringify(site));
        communityService.executeAction(component, 'getstudyType', {
            site:site
        }, function (returnValue) {
            var studyData = JSON.parse(returnValue);
            component.set("v.studyEmail",studyData.preEmail);
            if((studyData.prePhone == null || studyData.prePhone == undefined)){
                component.set('v.isCheckPhoneNumber', true);
                component.set('v.isCheckPhonenull', false);
                component.set('v.isthirdcheck', false);
            }
            if((studyData.prePhone != null || studyData.prePhone != undefined)){
                component.set("v.studyPhone",studyData.prePhone);
                component.set('v.isCheckPhonenull', true);
                component.set('v.isCheckPhoneNumber', false);
                component.set('v.isthirdcheck', false);
            }
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
        var email = component.get('v.emailS');
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var emailErrorval = $A.get("$Label.c.TST_Invalid_email_address");
        if (!email.match(regExpEmailformat)) 
        {
            component.set("v.emailError", emailErrorval);
            component.set("v.emailS", '');
        }else{
            component.set("v.emailError", '');
        }
        
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
        var actualemailPhone;
        //if(email && !communityService.isValidEmail(email)){
        emailVal = emailS;
        //}
        //if(email && !communityService.isValidEmail(email)){
        stemailVal = studyEmail;
        //}
        if((emailS != '' || emailS != undefined) && (phone != '' || phone != undefined) && cntValidEmail && !cntemail && !cntPhone){
            actualemailPhone = emailS;
        }
        if((emailS != '' || emailS != undefined) && (phone == '' || phone == undefined) && cntValidEmail && !cntemail && !cntPhone){
            actualemailPhone = emailS;
        }
        if((phone != '' || phone != undefined) && (emailS != '' || emailS != undefined) && cntValidPhone && !cntemail && !cntPhone){
            actualemailPhone = phone;
        }
        if((phone != '' || phone != undefined) && (emailS == '' || emailS == undefined) && cntValidPhone && !cntemail && !cntPhone){
            actualemailPhone = phone;
        }
        
        
        if((stemailVal != '' || stemailVal != undefined) && (studyPhone != '' || studyPhone != undefined) && cntemail){
            prefferedtype = stemailVal;
        }
        if((stemailVal != '' || stemailVal != undefined) && (studyPhone == '' || studyPhone == undefined) && cntemail){
            prefferedtype = stemailVal;
        }
        if((studyPhone != '' || studyPhone != undefined) && (stemailVal != '' || stemailVal != undefined) && cntPhone){
            prefferedtype = studyPhone;
        }
        if((studyPhone != '' || studyPhone != undefined) && (stemailVal == '' || stemailVal == undefined) && cntPhone){
            prefferedtype = studyPhone;
        }
        component.find('modalSpinner').show();
        
        communityService.executeAction(component, 'inviteNewMedia', {
            study:study,
            site:site,
            prefferedtype: prefferedtype,
            actualemailPhone: actualemailPhone,
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