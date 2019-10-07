/**
 * Created by AlexKetch on 6/18/2019.
 */
({

    getRelatedVisitPlans: function (component, event, helper) {
        debugger;
        component.find('mainSpinner').show();
        helper.enqueue(component, 'c.getRelatedPlannedVisits', {
            ctpId: component.get('v.recordId')
        }).then(function (result) {
            component.find('mainSpinner').hide();
            component.set('v.visits', result)
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            component.find('mainSpinner').hide();
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
    editVisitLegend: function (component, event, helper) {
        component.find('editLegend').show();
    },
    handleRecordUpdated: function (component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            let ctp = JSON.stringify(component.get('v.CTPrecord'));
            let ctpCLear = JSON.parse(ctp);
            component.set('v.visitPlanId', ctpCLear.Visit_Plan__c);

        } else if (eventParams.changeType === "CHANGED") {
            let ctp = JSON.stringify(component.get('v.CTPrecord'));
            let ctpCLear = JSON.parse(ctp);
            if (!ctpCLear.Visit_Plan__c) {

                component.set('v.visits', []);
            }
            component.set('v.visitPlanId', ctpCLear.Visit_Plan__c);
            helper.getRelatedVisitPlans(component, event, helper);
        } else if (eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if (eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    shiftRight: function (component, event, helper) {
        debugger;
        const elements = component.find('leftIcons');
        let selectedNames = [];
        let newLeft = [];
        if (elements instanceof Array) {
            for (let i = 0; i < elements.length; i++) {
                console.log(JSON.stringify(elements[i]));
                if (elements[i].get('v.selected')) {
                    selectedNames.push(elements[i].get('v.currIcon'));
                } else {
                    newLeft.push(elements[i].get('v.currIcon'));
                }
            }
        } else {
            if (elements.get('v.selected')) {
                selectedNames.push(elements.get('v.currIcon'));
            } else {
                newLeft.push(elements.get('v.currIcon'));
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
        if (elements instanceof Array) {
            for (let i = 0; i < elements.length; i++) {
                console.log(JSON.stringify(elements[i]));
                if (elements[i].get('v.selected')) {
                    selectedNames.push(elements[i].get('v.currIcon'));
                } else {
                    newRight.push(elements[i].get('v.currIcon'));
                }
            }

        } else {
            if (elements.get('v.selected')) {
                selectedNames.push(elements.get('v.currIcon'));
            } else {
                newRight.push(elements.get('v.currIcon'));
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
        let splittedIcons = [];
        if (record.Icons__c) {
            splittedIcons = record.Icons__c.split(';');
        }
        let icons = Object.assign([], component.get('v.allIcons'));

        let iconArr = [];
        for (let i = 0; i < splittedIcons.length; i++) {
            let index = icons.findIndex(function (item) {
                return item.id === splittedIcons[i];
            });
            if (index > -1) {
                iconArr.push(icons[index]);
                icons.splice(index, 1);
            }
        }
        //todo need load of all icons;
        component.set('v.availableIcons', icons);
        // component.set('v.selectedIcons', splittedIcons);
        component.set('v.selectedIcons', iconArr);
    },
    handleSuccessVP: function (component, event, helper) {
        debugger;
        const recId = event.getParam("id");
        component.set('v.visitPlanId', recId);
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
        let record = event.getParam('record');
        component.set('v.visitId', record.Id);
        helper.deleteVisitRecord(component, event, helper)
    },

    getIconsNames: function (component, event, helper) {
        debugger;
        var x = new XMLHttpRequest();
        x.open("GET", component.get('v.iconsURL'), true);
        x.onreadystatechange = function () {
            if (x.readyState === 4 && x.status === 200) {
                var doc = x.responseXML;
                var symbols = doc.getElementsByTagName('symbol');
                var symbolNames = [];
                for (var i = 0; i < symbols.length; i++) symbolNames.push(symbols[i].id);
                component.set('v.allIcons', symbolNames);
            }
        };
        x.send(null);
    },
    deleteVisitRecord: function (component, event, helper) {
        debugger;
        component.find('mainSpinner').show();
        let vId = component.get('v.visitId');
        helper.enqueue(component, 'c.deleteVisit', {
            visitId: vId
        }).then(function () {
            let visits = component.get('v.visits');
            let newVisits = visits.filter(function (e) {
                return e.Id != vId;
            });
            component.set('v.visits', newVisits);
            component.find('mainSpinner').hide();
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
            component.find('mainSpinner').hide();
            console.log('error:', err[0].message);
        })
    },

    getIconsUrl: function (component, event, helper) {
        let service = component.find("iconsStaticResourceService");
        let iconsStaticUrl = service.getStaticResourceUrl(component, event, helper);
        component.set("v.iconsURL", iconsStaticUrl);
    },

    getAllIconsNames: function (component, event, helper) {
        let service = component.find("iconsStaticResourceService");
        service.getIconsData(component, event, helper)
            .then(function (result) {
                component.set('v.allIcons', result.iconNames);
            }, function (errorMessage) {
                component.set('v.error', errorMessage);
            })
    },
    handleSuccessSaveAddVisit:function (component,event,helper) {
        component.find('customModal').hide();
        helper.getRelatedVisitPlans(component, event, helper);
        helper.notify({
            "title": $A.get("$Label.c.Success"),
            "message": $A.get("$Label.c.Success_Creation"),
            "type": $A.get("$Label.c.successType")
        });
    }


})