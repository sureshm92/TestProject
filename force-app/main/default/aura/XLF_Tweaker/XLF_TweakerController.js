/**
 * Created by Slav on 22.10.2019.
 */

({
        	//----------------------------------------------------------//
        	// retrieve list of all Documents available to current User	//
        	//----------------------------------------------------------//
        	init: function (component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

        		var action = component.get("c.getDocuments");
        		action.setCallback (this, function(response) {
        			if (response.getState() === "SUCCESS") {
       					component.set('v.documents', response.getReturnValue());
        			} else if (response.getState() === "ERROR") {
        			    var errors = response.getError();
                        component.set("v.toastType", "error");
                        component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                        $A.enqueueAction(component.get('c.showToast'));
        			}
                    spinner.hide();
        		})
        		$A.enqueueAction(action);
        	},

        	//----------------------------------------------------------//
        	// file selection change event handler                      //
        	//----------------------------------------------------------//
            onHighlightChange: function (component, event, helper) {
                var highlighted = component.find("file_select");
                component.set('v.highlighted', highlighted.get("v.value"));
            },

        	//----------------------------------------------------------//
        	// ZIP file selection change event handler                  //
        	//----------------------------------------------------------//
            onZipHighlightChange: function (component, event, helper) {
                var highlighted = component.find("zip_select");
                component.set('v.zipHighlighted', highlighted.get("v.value"));
            },

        	//----------------------------------------------------------//
        	// start tweaking process on remote for a file             	//
        	//----------------------------------------------------------//
        	startProcess: function (component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

                var docName = component.get("v.highlighted");
        		var action = component.get("c.startTweaking");
        		action.setParams({ docName : docName });
        		action.setCallback (this, function (response) {
        			if (response.getState() === "SUCCESS") {
                        var returnValue = response.getReturnValue();
                        var idx = returnValue.search(':');
                        var code = returnValue.substring(0, idx);
                        var text = returnValue.substring(idx + 1);
                        if (code == 'true') {
                            component.set("v.toastType", "success");
                            component.set("v.toastMessage", text);
                            $A.enqueueAction(component.get('c.showToast'));
                        } else if (code == 'false') {
                            component.set("v.toastType", "error");
                            component.set("v.toastMessage", text);
                            $A.enqueueAction(component.get('c.showToast'));
                        } else if (code == 'zip') {
                            var zip = new JSZip();
                            zip.loadAsync(text, {base64: true}).then(function (zip) {
                                var names = Object.keys(zip.files).map(function (name) {
                                    return name;
                                });
                                component.set("v.zip", text);
                                component.set("v.zipNames", names);
                                component.set('v.isZipModalOpen', true);
                            });
                        } else {
                            component.set("v.toastType", "error");
                            component.set("v.toastMessage", 'ERROR: unknown error');
                            $A.enqueueAction(component.get('c.showToast'));
                        }
        			} else if (response.getState() === "ERROR") {
        			    var errors = response.getError();
                        component.set("v.toastType", "error");
                        component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                        $A.enqueueAction(component.get('c.showToast'));
        			}
                    spinner.hide();
        		})
        		$A.enqueueAction(action);
            },

        	//----------------------------------------------------------//
        	// start tweaking process on remote for a file             	//
        	//----------------------------------------------------------//
        	startZipProcess: function (component, event, helper) {
                var spinner = component.find('spinner');
                spinner.show();

                var fileName = component.get("v.zipHighlighted");
        	    var text = component.get("v.zip");
                var zip = new JSZip();
                zip.loadAsync(text, {base64: true}).then(function(zip) {
                    zip.file(fileName).async("string").then(function(body){
                        var action = component.get("c.startZipTweaking");
                        action.setParams({ fileName : fileName, body : body });
                        action.setCallback (this, function(response) {
                            if (response.getState() === "SUCCESS") {
                                var returnValue = response.getReturnValue();
                                var idx = returnValue.search(':');
                                var code = returnValue.substring(0, idx);
                                var text = returnValue.substring(idx + 1);
                                if (code == 'true') {
                                    component.set("v.toastType", "success");
                                    component.set("v.toastMessage", text);
                                    $A.enqueueAction(component.get('c.showToast'));
                                } else if (code == 'false') {
                                    component.set("v.toastType", "error");
                                    component.set("v.toastMessage", text);
                                    $A.enqueueAction(component.get('c.showToast'));
                                } else {
                                    component.set("v.toastType", "error");
                                    component.set("v.toastMessage", 'ERROR: unknown error');
                                    $A.enqueueAction(component.get('c.showToast'));
                                }
                            } else if (response.getState() === "ERROR") {
                                var errors = response.getError();
                                component.set("v.toastType", "error");
                                component.set("v.toastMessage", 'APEX EXCEPTION: ' + errors[0].message);
                                $A.enqueueAction(component.get('c.showToast'));
                            }
                            spinner.hide();
                        });
                        $A.enqueueAction(action);
                        component.set('v.isZipModalOpen', false);
                    });
                });
            },

        	//----------------------------------------------------------//
        	// closes ZIP Modal (fired when clicked on Cancel)          //
        	//----------------------------------------------------------//
            closeZipModal: function (component, event, helper) {
                component.set('v.isZipModalOpen', false);
            },

        	//----------------------------------------------------------//
        	// display message as Toast	                                //
        	//----------------------------------------------------------//
            showToast: function (component, event, helper) {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "type" : component.get("v.toastType"),
                    "duration" : 15000,
                    "message" : component.get("v.toastMessage")
                });
                toast.fire();
            },

        	//----------------------------------------------------------//
        	// navigate to White List                                   //
        	//----------------------------------------------------------//
            gotoWhiteList: function (component, event, helper) {
                var action = $A.get("e.force:navigateToComponent");
                    action.setParams({
                        componentDef: "c:XLF_PatternList",
                        componentAttributes: {
                            mode: 'WHITE'
                        }
                    });
                action.fire();
            },

        	//----------------------------------------------------------//
        	// navigate to Black List                                   //
        	//----------------------------------------------------------//
            gotoBlackList: function (component, event, helper) {
                var action = $A.get("e.force:navigateToComponent");
                    action.setParams({
                        componentDef: "c:XLF_PatternList",
                        componentAttributes: {
                            mode: 'BLACK'
                        }
                    });
                action.fire();
            }
});