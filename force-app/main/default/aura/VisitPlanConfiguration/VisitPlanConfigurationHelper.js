/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    getRelatedVisitPlans: function (component, event, helper) {
        debugger;
        helper.enqueue(component, 'c.getRelatedPlannedVisits', {
            ctpId: component.get('v.recordId')
        }).then(function (result) {
            component.set('v.visits', result)
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
        })
    },
    addVisit: function (component, event, helper) {
        let copy = [];
        Object.assign(copy, component.get('v.allIcons'));
        component.set('v.availableIcons', copy);
        component.set('v.selectedIcons', []);
        component.set('v.visitId', null);
        component.find('customModal').show();
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            let ctp  = JSON.stringify(component.get('v.CTPrecord'));
            let ctpCLear  = JSON.parse(ctp);
            component.set('v.visitPlanId',ctpCLear.Visit_Plan__c);
        } else if(eventParams.changeType === "CHANGED") {
            let ctp  = JSON.stringify(component.get('v.CTPrecord'));
            let ctpCLear  = JSON.parse(ctp);
            component.set('v.visitPlanId',ctpCLear.Visit_Plan__c);
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    shiftRight: function (component, event, helper) {
        debugger;
        const elements = component.find('leftIcons');
        let selectedNames = [];
        let newLeft = [];
        for (let i = 0; i < elements.length; i++) {
            if (elements[i].get('v.selected')) {
                selectedNames.push(elements[i].get('v.name'));
            } else {
                newLeft.push(elements[i].get('v.name'));
            }
        }
        let selectedIcons = component.get('v.selectedIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            selectedIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons', selectedIcons);
        component.set('v.availableIcons', newLeft);
    },
    shiftLeft: function (component, event, helper) {
        debugger;
        const elements = component.find('rightIcons');
        let selectedNames = [];
        let newRight = [];
        for (let i = 0; i < elements.length; i++) {
            if (elements[i].get('v.selected')) {
                selectedNames.push(elements[i].get('v.name'));
            } else {
                newRight.push(elements[i].get('v.name'));
            }
        }
        let availableIcons = component.get('v.availableIcons');
        for (let i = 0; i < selectedNames.length; i++) {
            availableIcons.push(selectedNames[i]);
        }
        component.set('v.selectedIcons', newRight);
        component.set('v.availableIcons', availableIcons);

    },
    fireEditMode: function (component, event, helper) {
        debugger;
        let record = event.getParam('record');
        component.find('customModal').show();
        component.set('v.visitId', record.Id);

        let splittedIcons = record.Icons__c.split(';');
        let icons = Object.assign([], component.get('v.allIcons'));
        for (let i = 0; i < splittedIcons.length; i++) {
            let index = icons.findIndex(function (item) {
                return item == splittedIcons[i];
            });
            if (index > -1) {
                icons.splice(index, 1);
            }
        }
        //todo need load of all icons;
        component.set('v.availableIcons', icons);
        component.set('v.selectedIcons', splittedIcons);
    },
    handleSuccessVP: function (component, event, helper) {
        debugger;
        const recId  = event.getParam("id");
        component.set('v.visitPlanId',recId);
        helper.enqueue(component, 'c.updateCtp', {
            visitPlanId: component.get('v.visitPlanId'),
            ctpId: component.get('v.recordId')

        }).then(function (result) {
            component.find('createVisitPlan').hide();
            helper.notify({
                "title": $A.get("$Label.c.Success"),
                "message": $A.get("$Label.c.Success_Creation"),
                "type": $A.get("$Label.c.successType")
            });
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
        })
    },
    deleteRecord: function (component, event, helper) {
        $A.util.toggleClass(component.find('spinner'));
        let record = event.getParam('record');
        component.set('v.visitId', record.Id);
        helper.deleteRecord(component, event, helper)
    },
    createVisitPlan: function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact"
        });
        createRecordEvent.fire();
    },
    getIconsNames: function (component, event, helper) {
        var x = new XMLHttpRequest();
        x.open("GET", component.get('v.iconsURL'), true);
        x.onreadystatechange = function () {
            if (x.readyState === 4 && x.status === 200) {
                var doc = x.responseXML;
                var symbols = doc.getElementsByTagName('symbol');
                var symbolNames = [];
                for(var i= 0; i < symbols.length; i++) symbolNames.push(symbols[i].id);
                component.set('v.allIcons',symbolNames);
            }
        };
        x.send(null);
    },
    deleteRecord: function (component, event, helper) {
        debugger;
        let vId = component.get('v.visitId');
        helper.enqueue(component, 'c.deleteVisit', {
            visitId: vId
        }).then(function () {
            let visits = component.get('v.visits');
            let newVisits = visits.filter(function (e) {
                 return e.Id != vId;
            });
            component.set('v.visits', newVisits);
            $A.util.toggleClass(component.find('spinner'));
            helper.notify({
                "title": $A.get("$Label.c.Success"),
                "message": $A.get("$Label.c.success_deleteon"),
                "type": $A.get("$Label.c.successType")
            });
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
        })
    },


})