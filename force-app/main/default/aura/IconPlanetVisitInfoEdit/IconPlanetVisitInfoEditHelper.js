/**
 * Created by AlexKetch on 6/21/2019.
 */
({
    getCustomIconsNames: function (component, event, helper) {
        var x = new XMLHttpRequest();
        x.open("GET", component.get('v.iconsURL'), true);
        x.onreadystatechange = function () {
            if (x.readyState === 4 && x.status === 200) {
                var doc = x.responseXML;
                var symbols = doc.getElementsByTagName('symbol');
                var symbolNames = [];
                for (var i = 0; i < symbols.length; i++) {
                    symbolNames.push(symbols[i].id);
                }
                let customIconDetails = [];
                if (symbolNames.length > 0) {
                    symbolNames.map(function (el) {
                        let iconDetail = {
                            Description__c: null,
                            'Id': null,
                            'Label__c': null,
                            'Name': el
                        };
                        customIconDetails.push(iconDetail);

                    });
                }
                component.set('v.customIconDetails', customIconDetails);
            }
        };
        x.send(null);
    },
    getExistingLegend: function (component, event, helper) {
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');
        helper.enqueue(component, 'c.getExistingLegend', {
            'iconPackageId': component.get('v.existingIconsPackage'),
        }).then(function (result) {
            result.map(function (el) {
                if (el.Id) {
                    delete el.Id
                }
                el.Icons_Package__c = component.get('v.iconPackageId');
            });
            component.set('v.detailIcons', result);
            component.find('createLegendModal').hide();
            $A.util.toggleClass(component.find('spinner'), 'slds-hide');
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            $A.util.toggleClass(component.find('spinner'), 'slds-hide');
            console.log('error:', err[0].message);
            component.find('createLegendModal').hide();
        });
    },
    createVisitPackage: function (component, event, helper) {
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');
        helper.enqueue(component, 'c.createVisitPackage', {
            iconPackageId: component.get('v.iconPackageId'),
            visitPlanId: component.get('v.visitPlanId'),
        })
            .then(function (result) {
                component.set('v.detailIcons', result);
                component.find('createLegendModal').hide();
                $A.util.toggleClass(component.find('spinner'), 'slds-hide');
            }, function (err) {
                if (err && err[0].message) {
                    helper.notify({
                        title: 'error',
                        message: err[0].message,
                        type: 'error',
                    });
                }
                console.log('error:', err[0].message);
                component.find('createLegendModal').hide();
            });
        component.find('createLegendModal').hide();
    },
    getThisLegends: function (component, event, helper) {
        debugger;
        helper.enqueue(component, 'c.getThisLegend', {
            'visitPlanId': component.get('v.visitPlanId')
        }).then(function (result) {
            console.log('results', result);
            component.set('v.detailIcons', result);
            //helper.getCustomIconsNames(component, event, helper);
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            console.log('error:', err[0].message);
        });
    },
    saveIconsLegend: function (component, event, helper) {
        let iconsDetail = component.get('v.detailIcons');
        let filtered = helper.getNotEmptyIcons(iconsDetail);
        let customDetails = component.get('v.customIconDetails');
        helper.enqueue(component, 'c.saveIconInfo', {
            'iconsDetails': filtered,
            'iconPackageId': component.get('v.iconPackageId'),
            'visitPlanId': component.get('v.visitPlanId')
        }).then(function () {
            component.find('customModal').hide();
            helper.notify({
                "title": "Success!",
                "message": "saved successfully.",
                "type": 'success'
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
            component.find('customModal').hide();
        });
        component.find('customModal').hide();
    },
    getNotEmptyIcons: function (iconsDetail) {
        return iconsDetail.filter(function (el) {
            return el.Label__c && el.Description__c
        })
    },


})