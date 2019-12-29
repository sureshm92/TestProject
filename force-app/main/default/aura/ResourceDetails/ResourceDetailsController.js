/**
 * Created by Slav on 24.12.2019.
 */

({
        //----------------------------------------------------------//
        // retrieve necessary information from server               //
        //----------------------------------------------------------//
    	select: function (component, event, helper) {
            component.set('v.isInfo', false);
            component.set('v.isSuccess', false);
            component.set('v.isError', false);
    		var apexMethod = component.get("c.getResource");
    		var pageReference = component.get("v.pageReference");
    		apexMethod.setParams({ recordId : component.get("v.recordId"), recordTypeId : pageReference.state.recordTypeId });
    		apexMethod.setCallback (this, function(response) {
    			if (response.getState() === "SUCCESS") {
    			    var returnValue = response.getReturnValue();
    			    var res = returnValue.resource;
    			    component.set("v.res", res);
                    // ------ parse Resource__c object into local fields ------
                    component.set("v.recordId", res.Id);
                    component.set("v.res_title", res.Title__c);
                    component.set("v.res_doctype", res.document_type__c);
                    component.set("v.res_description", res.Description__c);
                    component.set("v.res_video", res.Video__c);
                    component.set("v.res_language", res.Language__c);
                    component.set("v.res_version", res.Version_Date__c);
                    // ------ additional attributes from server ------
    			    component.set("v.languages", returnValue.languages);
    			    component.set("v.docTypes", returnValue.docTypes);
    			    component.set("v.videoHelpText", returnValue.videoHelpText);
    			    component.set("v.developerName", returnValue.developerName);
    			    component.set("v.redirect", returnValue.redirect);
    			    if (returnValue.redirect != null) {
                        $A.enqueueAction(component.get("c.redirect"));
//                        component.set('v.isError', true);
//        			    component.set("v.message", returnValue.message);
//                        $A.util.addClass(component.find("reset"), "slds-hide");			// hide New button
//                        $A.util.addClass(component.find("save"), "slds-hide");			// hide Save button
                    } else {
                        component.set('v.isInfo', true);
                        component.set('v.message', 'Fill in the required fields and click Save. The File Upload will be enabled after successful save');
                    }
    			} else {
                    var errors = response.getError();
					component.set('v.isError', true);
					component.set('v.message', errors[0].message);
    			}
    		})
    		$A.enqueueAction(apexMethod);
    	},

        //----------------------------------------------------------//
        // redirects to the standard "NEW" page                     //
        //----------------------------------------------------------//
    	redirect: function (component, event, helper) {
    	    var redirectAction = $A.get("e.force:navigateToURL");
            redirectAction.setParams({
              "url" : component.get("v.redirect")
            });
            redirectAction.fire();
//          $A.get("e.force:closeQuickAction").fire();
        },

        //----------------------------------------------------------//
        // saves or updates the new/current record                  //
        //----------------------------------------------------------//
        save: function (component, event, helper) {
            component.set('v.isInfo', false);
            component.set('v.isSuccess', false);
            component.set('v.isError', false);
            helper.buildResource(component);
    		var apexMethod = component.get("c.saveResource");
    		apexMethod.setParams({ recordId : component.get("v.recordId"), resource : component.get("v.res") });
    		apexMethod.setCallback (this, function(response) {
    			if (response.getState() === "SUCCESS") {
    			    var returnValue = response.getReturnValue();
    			    if (returnValue.isError) {
                        component.set('v.isError', true);
    			    } else {
    			        component.set('v.isSuccess', true);
    			        component.set('v.recordId', returnValue.recordId);
    			    }
                    component.set('v.message', returnValue.message);
    			} else {
                    var errors = response.getError();
					component.set('v.isError', true);
					component.set('v.message', errors[0].message);
    			}
    		})
    		$A.enqueueAction(apexMethod);
        },

        //----------------------------------------------------------//
        // File Upload handler                                      //
        //----------------------------------------------------------//
        uploadComplete: function (component, event) {
            var uploadedFiles = event.getParam("files");
        },

        //----------------------------------------------------------//
        // clears all input fields and attributes on the component  //
        //----------------------------------------------------------//
        reset: function (component, event, helper) {
            component.set("v.recordId", null);
            component.set('v.res', null);
            component.set("v.res_title", null);
            component.set("v.res_doctype", null);
            component.set("v.res_description", null);
            component.set("v.res_video", null);
            component.set("v.res_language", null);
            component.set("v.res_version", null);
            $A.enqueueAction(component.get('c.select'));
        },

        //----------------------------------------------------------//
        // return to the previous window                            //
        //----------------------------------------------------------//
        closeModal: function (component, event, helper) {
//            window.history.back(3);
          $A.get("e.force:closeQuickAction").fire();
        },

        
});