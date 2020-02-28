/**
 * Created by AlexKetch on 4/16/2019.
 */
({
    showUpdateWarning: function (component, event, helper) {
        var modalBody;
        debugger;
        $A.createComponent("c:ResourceUpdateWarning", {},
            function (content, status, errorMessage) {
                if (status === "SUCCESS") {
                    debugger;
                    helper.showCustomModal({
                        header: "Application Confirmation",
                        body: content,
                        showCloseButton: true,
                        cssClass: "mymodal",
                        closeCallback: function () {
                            alert('You closed the alert!');
                        }
                    });
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
    },

    togglePopUp: function (component, event, helper) {
        let cmp = component.find('modalDialog');
        $A.util.toggleClass(cmp, 'slds-hide');
    },
    toggleToast: function (component, event, helper) {
        let cmp = component.find('toast');
        if (cmp) {
            cmp.destroy();
        }
    },

    onSetupdatedDate: function (component, event, helper) {
        debugger;
        helper.enqueue(component, 'c.setUpdateDate', {recordId: component.get('v.recordId')})
            .then(res => {
                    return new Promise($A.getCallback(function (resolve, reject) {
                        helper.togglePopUp(component, event, helper);
                        window.setTimeout(
                            $A.getCallback(function () {
                                resolve();
                            }), 500);
                    }));
                },
                err => {
                    if (err && err[0].message) {
                        helper.notify({
                            title: 'error',
                            message: err[0].message,
                            type: 'success',
                        });
                    }
                    console.log('error:', err[0].message);
                })
            .then(res => {
                helper.toggleToast(component, event, helper);
            });
    },
    onhandleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            let loaded = component.get("v.resourceRecord");
            console.log('loaded', JSON.stringify(loaded));

        } else if (eventParams.changeType === "CHANGED") {
            let resource = component.get("v.resourceRecord");
            if (resource.RecordType.Name == 'Article' || resource.RecordType.Name == 'Video') {
                if ((!resource.Updated_Date__c)) {
                    helper.togglePopUp(component, event, helper);
                }
            }

        } else if (eventParams.changeType === "REMOVED") {
            // record is deleted
            console.log('removed');
        } else if (eventParams.changeType === "ERROR") {
            console.log('error', component.get('v.targetError'));
            // there’s an error while loading, saving, or deleting the record
        }
    }
})