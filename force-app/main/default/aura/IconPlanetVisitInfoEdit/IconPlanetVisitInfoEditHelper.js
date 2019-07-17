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
                return helper.enqueue(component, 'c.getIconDetails', {});
            }, function (errorMessage) {
                component.set('v.errorMessage', errorMessage);
                return helper.enqueue(component, 'c.getThisLegend', {
                    'visitPlanId': component.get('v.visitPlanId')
                });
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
    saveIconsLegend: function (component, event, helper) {
        debugger;
        let iconsDetails = component.get('v.iconDetails');
        let filtered = helper.getNotEmptyIcons(iconsDetails);
        helper.enqueue(component, 'c.saveIconInfo', {
            'iconsDetails': filtered,
        }).then(function () {
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
        });
    },
    getNotEmptyIcons: function (iconsDetail) {
        return iconsDetail.filter(function (el) {
            return el.Label__c && el.Description__c
        })
    },


})