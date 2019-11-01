/**
 * Created by Slav on 22.10.2019.
 */

({
        	//----------------------------------------------------------//
        	// retrieve list of all Patterns records (WHITE or BLACK) 	//
        	//----------------------------------------------------------//
            init : function(component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

                var action = component.get("c.getRecords");
                action.setParams({ "mode" : component.get('v.mode') });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS" ) {
                        component.find("datatable").set("v.draftValues", null);     // this hides the Cancel/Save buttons and resets updated rows
                        var result = response.getReturnValue();
                        component.set("v.keyPrefix", result.jobId);
                        component.set("v.data", result.records);
                        $A.enqueueAction(component.get('c.handleColumnSort'));
                    } else if (state === "ERROR") {
        			    var errors = response.getError();
                        component.set("v.toastType", "error");
                        component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                        $A.enqueueAction(component.get('c.showToast'));
                    }
                    spinner.hide();
                });
                $A.enqueueAction(action);
            },

        	//----------------------------------------------------------//
            // row select event handler                                 //
        	//----------------------------------------------------------//
            handleRowSelect: function(component, event, helper) {
                var selectedRows = event.getParam('selectedRows');
                component.set("v.selectedRows", selectedRows);
                component.set("v.selectedRowsCount", selectedRows.length);
            },

            //----------------------------------------------------------//
            // adds a new empty row at the bottom of the table          //
            //----------------------------------------------------------//
            handleAdd: function (component, event, helper) {
                var records = component.get("v.data");
                records.push({});
                component.set("v.data", records);
            },

            //----------------------------------------------------------//
            // this function updates all edited records                 //
            //----------------------------------------------------------//
            handleSave: function (component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

                var records = event.getParam('draftValues');
                for (var i=0; i<records.length; i++) {
                    records[i].Active__c = true;
                }

                var action = component.get("c.saveRecords");
                action.setParams({ "mode" : component.get('v.mode'), "records" : records });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS" ) {
                        component.find("datatable").set("v.draftValues", null);     // this hides the Cancel/Save buttons and resets updated rows
                        var result = response.getReturnValue();
                        var status = (result.success) ? "success" : "error";
                        component.set("v.toastType", status);
                        component.set("v.jobId", result.jobId);
                        component.set("v.toastMessage", result.message);
                        $A.enqueueAction(component.get('c.showToast'));
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        component.set("v.toastType", "error");
                        component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                        $A.enqueueAction(component.get('c.showToast'));
                    }
                    spinner.hide();
                });
                $A.enqueueAction(action);
            },

            //----------------------------------------------------------//
            // delete selected rows                                     //
            //----------------------------------------------------------//
            handleDelete: function (component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

                var records = component.get('v.selectedRows');
                for ( var i=0; i<records.length; i++) {
                    records[i].Active__c = false;
                }

                var action = component.get("c.saveRecords");
                action.setParams({ "mode" : component.get('v.mode'), "records" : records });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS" ) {
                        var result = response.getReturnValue();
                        var status = (result.success) ? "success" : "error";
                        component.set("v.toastType", status);
                        component.set("v.jobId", result.jobId);
                        component.set("v.toastMessage", result.message);
                        $A.enqueueAction(component.get('c.showToast'));
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        component.set("v.toastType", "error");
                        component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                        $A.enqueueAction(component.get('c.showToast'));
                    }
                    spinner.hide();
                });
                $A.enqueueAction(action);
            },

            //----------------------------------------------------------//
            // navigate to deployment status page                       //
            //----------------------------------------------------------//
            checkDeployStatus: function (component, event, helper) {
                window.open("/changemgmt/monitorDeploymentsDetails.apexp?asyncId=" + component.get("v.jobId"), "_blank");
            },

            //----------------------------------------------------------//
            // sort Patterns                                            //
            //----------------------------------------------------------//
            handleColumnSort: function (component, event, helper) {
                var fieldName     = 'Pattern__c';
                var sortDirection = 'asc';
                if (event != null) {
                    fieldName = event.getParam('fieldName');
                    sortDirection = event.getParam('sortDirection');
                }
                component.set("v.sortedBy", fieldName);
                component.set("v.sortedDirection", sortDirection);
                helper.sortData(component, fieldName, sortDirection);
            },

        	//----------------------------------------------------------//
        	// display message as Toast	                                //
        	//----------------------------------------------------------//
            showToast: function (component, event, helper) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "type" : component.get("v.toastType"),
                    "duration" : 15000,
                    "message": component.get("v.toastMessage")
                });
                toast.fire();
            },

        	//----------------------------------------------------------//
        	// navigate back to XLF Tweaker                             //
        	//----------------------------------------------------------//
            backToTweaker: function (component, event, helper) {
                var action = $A.get("e.force:navigateToComponent");
                    action.setParams({
                        componentDef: "c:XLF_Tweaker",
                        componentAttributes: {
                            // Attributes here.
                        }
                    });
                action.fire();
            }
});