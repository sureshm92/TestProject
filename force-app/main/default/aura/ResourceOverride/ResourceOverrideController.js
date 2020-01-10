/**
 * Created by Slav on 27.12.2019.
 */

({
        //----------------------------------------------------------//
        // retrieve necessary information from server               //
        //----------------------------------------------------------//
    	init: function (component, event, helper) {
            helper.resetMessages(component);
    		var apexMethod = component.get("c.getMetadata");
    		apexMethod.setParams({ recordTypeId : component.get("v.pageReference").state.recordTypeId });
    		apexMethod.setCallback (this, function(response) {
    			if (response.getState() === "SUCCESS") {
    			    var returnValue = response.getReturnValue();
    			    helper.parseMetadata(component, returnValue);
    			} else {
                    var errors = response.getError();
					component.set('v.isError', true);
					component.set('v.message', errors[0].message);
    			}
    		})
    		$A.enqueueAction(apexMethod);
    	},

    handleChange: function (component, event) {
    	    console.log(component.get("v.Countries"));
    	    var selectedOptionValue = event.getParam("value");
    	    component.set("v.Countries__c", selectedOptionValue.toString());
    	    alert(selectedOptionValue.toString());
    },

        //----------------------------------------------------------//
        // saves or updates the new/current record                  //
        //----------------------------------------------------------//
        save: function (component, event, helper) {
    	    debugger;
            helper.resetMessages(component);
            if (!helper.validateForm(component, event, helper)) return;
            helper.buildRecord(component);
    		var apexMethod = component.get("c.saveResource");
    		apexMethod.setParams({
    		    recordTypeId : component.get("v.recTypeId"),
    		    recordId : component.get("v.recordId"),
                resource : component.get("v.record")
            });
    		apexMethod.setCallback (this, function(response) {
    			if (response.getState() === "SUCCESS") {
    			    var returnValue = response.getReturnValue();
    			    if (returnValue.isError) {
                        component.set('v.isError', true);
    			    } else {
    			        component.set('v.isSuccess', true);
    			        component.set('v.recordId', returnValue.recordId);
    			        component.set('v.resourceName', returnValue.resourceName);
    			        component.set('v.availableLanguages', returnValue.availableLanguages);
    			        if (returnValue.availableLanguages.length > 0) {
    			            component.set('v.uploadLanguage', returnValue.availableLanguages[0]);
    			        }
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
        uploadComplete: function (component, event, helper) {
            helper.resetMessages(component);
            var uploadedFiles = event.getParam("files");
            var apexMethod = component.get("c.updateContentDocument");
            apexMethod.setParams({
                documentId : uploadedFiles[0].documentId,
                fileName   : uploadedFiles[0].name,
                recordId   : component.get('v.recordId'),
                language   : component.get('v.uploadLanguage')
            });
            apexMethod.setCallback (this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (returnValue.isError) {
                        component.set('v.isError', true);
                    } else {
                        component.set('v.isSuccess', true);
    			        component.set('v.availableLanguages', returnValue.availableLanguages);
    			        if (returnValue.availableLanguages.length > 0) {
    			            component.set('v.uploadLanguage', returnValue.availableLanguages[0]);
    			        }
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
        // clears all input fields and attributes on the component  //
        //----------------------------------------------------------//
        reset: function (component, event, helper) {
            component.set('v.recTypeDevName', null);
            helper.resetForm(component);
            helper.resetMessages(component);
            $A.enqueueAction(component.get('c.init'));
        },

        //----------------------------------------------------------//
        // return to the previous window                            //
        //----------------------------------------------------------//
        closeModal: function (component, event, helper) {
            window.history.back();
        },
});