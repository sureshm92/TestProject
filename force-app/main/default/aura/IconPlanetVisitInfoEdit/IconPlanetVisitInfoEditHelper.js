/**
 * Created by AlexKetch on 6/21/2019.
 */
({
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
    getPackageId: function (component, event, helper) {
        debugger;
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');
        helper.enqueue(component, 'c.getPackageId', {
            visitPlanId: component.get('v.visitPlanId'),
        }).then(function (result) {
            component.set('v.iconPackageId', result);
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
        });
    },
    createVisitPackage: function (component, event, helper) {
        $A.util.toggleClass(component.find('spinner'), 'slds-hide');
        helper.enqueue(component, 'c.createVisitPackage', {
            iconPackageId: component.get('v.iconPackageId'),
            visitPlanId: component.get('v.visitPlanId'),
        }).then(function (result) {
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
        helper.getCustomIconsNames(component)
            .then(function (customIcons) {
                component.set('v.customIconDetails', customIcons);
                return helper.enqueue(component, 'c.getThisLegend', {
                    'visitPlanId': component.get('v.visitPlanId')
                });
            }, function (errorMessage) {
                component.set('v.errorMessage', errorMessage);
                return helper.enqueue(component, 'c.getThisLegend', {
                    'visitPlanId': component.get('v.visitPlanId')
                });
            }).then(function (dbresult) {
            let customIcons = component.get('v.customIconDetails');
            for (let i = 0; i < customIcons.length; i++) {
                let index = dbresult.findIndex(function (item) {
                    return item.Name == customIcons[i].Name;
                });
                if (index > -1) {
                    if (dbresult[index].Custom_Icon__c) {
                        customIcons[i] = dbresult[index];
                        dbresult.splice(index, 1);
                    }
                }
            }
            component.set('v.detailIcons', dbresult);
            component.set('v.customIconDetails', customIcons);
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
        });
    },
    getCustomIconsNames: function (component) {
        return new Promise($A.getCallback(function (resolve, reject) {
            var x = new XMLHttpRequest();
            x.open("GET", component.get('v.iconsURL'), true);
            x.onreadystatechange = function () {
                if (x.readyState === 4 && x.status === 200) {
                    var doc = x.responseXML;
                    if (doc) {
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
                                    'Custom_Icon__c': true,
                                    'Name': el
                                };
                                customIconDetails.push(iconDetail);

                            });
                        }
                        resolve(customIconDetails);
                    } else {
                        reject($A.get('$Label.c.Icons_package_not_found'));
                    }

                } else {

                }
            };
            x.send(null);
        }));
    },
    /*getThisLegends: function (component, event, helper) {
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
    },*/
    saveIconsLegend: function (component, event, helper) {
        debugger;
        let iconsDetailStandart = component.get('v.detailIcons');
        let customIconDetails = component.get('v.customIconDetails');
        let filtered = helper.getNotEmptyIcons(iconsDetailStandart);
        let filteredCustom = helper.getNotEmptyIcons(customIconDetails);
        const allIconsfiltered = [...filtered, ...filteredCustom];
        helper.enqueue(component, 'c.saveIconInfo', {
            'iconsDetails': allIconsfiltered,
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