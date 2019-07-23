/**
 * Created by AlexKetch on 6/21/2019.
 */
({

    getIconsResourceName: function (component, event, helper) {
        let staticResName = component.get('v.IconsPackageName');
        let path = component.get('v.IconsPackageFIlePath');
        let iconsStaticURL = $A.get('$Resource.' + staticResName) + path;
        component.set('v.iconsURL', iconsStaticURL);
    },
    getIconDetails: function (component, event, helper) {
        helper.getCustomIconsNames(component)
            .then(function (customIcons) {
                component.set('v.iconDetails', customIcons);
                return helper.enqueue(
                    component,
                    'c.getIconDetails',
                    {visitPlanId: component.get('v.visitPlanId')});
            }, function (errorMessage) {
                component.set('v.error', errorMessage);
            }).then(function (dbresult) {
            let customIcons = component.get('v.iconDetails');
            for (let i = 0; i < customIcons.length; i++) {
                let index = dbresult.findIndex(function (item) {
                    return item.Name == customIcons[i].Name;
                });
                if (index > -1) {
                    customIcons[i] = dbresult[index];
                    dbresult.splice(index, 1);
                }
            }
            component.set('v.iconDetails', customIcons);
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

                }
            };
            x.send(null);
        }));
    },
    saveIconsLegend: function (component, event, helper, callback, errorCallback) {
        debugger;
        let iconsDetails = component.get('v.iconDetails');
        let notEmpty = helper.getNotEmptyIcons(iconsDetails);
        let readyToGoIcons = helper.setIconsVisitPlan(component, notEmpty);
        helper.enqueue(component, 'c.saveIconInfo', {
            'iconsDetails': readyToGoIcons,
        }).then(function () {
            callback();
        }, function (err) {
            if (err && err[0].message) {
                console.log('error:', err[0].message);
                errorCallback(err[0].message);
            }
        });
    },
    getNotEmptyIcons: function (iconsDetail) {
        return iconsDetail.filter(function (el) {
            return el.Label__c && el.Description__c
        })
    },
    setIconsVisitPlan: function (component, iconsDetail) {
        const visitPlan = component.get('v.visitPlanId');
        iconsDetail.map(function (el) {
            el.Visit_Plan__c = visitPlan;
        });
        return iconsDetail;
    },


})