/**
 * Created by Admin on 8/28/2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();

        helper.enqueue(component, 'c.getInitData', {
            ctpId: component.get('v.recordId'),
            isFirstLoad: true
        }).then(function (data) {

            console.log(JSON.stringify(data));
            component.set('v.permission', data.permission);
            if (data.vendorItems.length > 0) {
                component.set('v.vendorItems', data.vendorItems);
                component.set('v.selectedVendors', data.vendors);
                component.set('v.selectedByCountry', data.countryCodes);
                component.set('v.selectedByStudySite', data.selectedSSIds);
                component.set('v.initialized', true);

                component.find('spinner').hide();
            } else {
                helper.enqueue(component, 'c.getAllData', {
                    'ctpId': component.get('v.recordId')
                }).then(function (data) {
                    component.set('v.vendorItems', data.vendorItems);
                    component.set('v.selectedVendors', data.vendors);
                    component.set('v.initialized', true);

                    component.find('spinner').hide();
                }, function (err) {
                    if (err && err[0].message) {
                        helper.notify({
                            title: 'error',
                            message: err[0].message,
                            type: 'error',
                        });
                    }
                    component.find('spinner').hide();
                    console.log('error:', err[0].message);
                });
            }
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }
            component.find('spinner').hide();
            console.log('error:', err[0].message);
        });
    },

    addVendor: function (component, event, helper) {
        helper.addVendor(component, helper);
    },

    getFilteredSS: function (component, event, helper) {
        helper.getFilteredItem(component, helper);
    },


    onAddTravelVendor: function (component, event, helper) {
        let newVendor = component.find('addTravelVendor').get('v.record');
        let vendors = component.get('v.selectedVendors');
        vendors.push(newVendor);
        component.set('v.selectedVendors', vendors);
        helper.addVendor(component, helper);
        component.find('customModal').hide();
    },

    showModal: function (component, event, helper) {
        component.find('customModal').show();
    },

    closeModal: function (component, event, helper) {
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
        component.find('addTravelVendor').submitForm();
    },

    doSave: function (component, event, helper) {
        component.find('spinner').show();


        let vendorItems = component.get('v.vendorItems');
        let allSettings = [];
        let studySites = component.get('v.selectedByStudySite');
        let countries = component.get('v.selectedByCountry');
        let vendors = component.get('v.selectedVendors');

        if ((studySites || countries)  && vendors.length === 0 ){
            helper.notify({
                title: 'Warning!',
                message: 'Select travel vendor first.',
                type: 'warning',
            });
            component.find('spinner').hide();
            return;
        }

            let isAnyLookUpSelected = studySites || countries;

        if (isAnyLookUpSelected) {
            vendorItems.forEach(function (vendorItem) {
                helper.checkOnIsManualStudySites(studySites, countries, vendorItem);
                allSettings = allSettings.concat(vendorItem.vendorSettings);
            });
        } else {
            allSettings = helper.uncheckAllCheckBoxForVendorSettings(vendorItems, allSettings);
        }
            console.log('allSettings ' + JSON.stringify(allSettings));
            helper.enqueue(component, 'c.saveData', {
                'ctpId': component.get('v.recordId'),
                'settings': allSettings
            }).then(function () {
                component.find('spinner').hide();
                helper.notify({
                    title: 'Success!',
                    message: 'Successfully saved.',
                    type: 'success',
                });
            }, function (err) {
                if (err && err[0].message) {
                    helper.notify({
                        title: 'error',
                        message: err[0].message,
                        type: 'error',
                    });
                }
                
                component.find('spinner').hide();
                console.log('error:', err[0].message);
            });

    },

    navToRecord: function (component, event, helper) {
        window.open('/' + event.target.getAttribute("data-ssid"));
    },

    columnCheckboxStateChange: function (component, event, helper) {
        let target = event.target.dataset.vendor;
        let checked = event.target.dataset.state === 'Enabled';
        let items = component.get('v.vendorItems');
        let page = component.get('v.currentPage');
        items.forEach(function (item) {
            let settings = item.vendorSettings;
            settings.forEach(function (setting) {
                if (setting.TravelVendor__c === target) {
                    setting.isEnable__c = checked;
                }
            });
        });
        component.set('v.vendorItems', items);
        component.set('v.currentPage', page);

        component.find('spinner').show();


        let vendorItems = component.get('v.vendorItems');
        let allSettings = [];
        let studySites = component.get('v.selectedByStudySite');
        let countries = component.get('v.selectedByCountry');
        let vendors = component.get('v.selectedVendors');

        if ((studySites || countries)  && vendors.length === 0 ){
            helper.notify({
                title: 'Warning!',
                message: 'Select travel vendor first.',
                type: 'warning',
            });
            component.find('spinner').hide();
            return;
        }

        let isAnyLookUpSelected = studySites || countries;

        if (isAnyLookUpSelected) {
            vendorItems.forEach(function (vendorItem) {
                helper.checkOnIsManualStudySites(studySites, countries, vendorItem);
                allSettings = allSettings.concat(vendorItem.vendorSettings);
            });
        } else {
            allSettings = helper.uncheckAllCheckBoxForVendorSettings(vendorItems, allSettings);
        }
        console.log('allSettings ' + JSON.stringify(allSettings));
        helper.enqueue(component, 'c.saveData', {
            'ctpId': component.get('v.recordId'),
            'settings': allSettings
        }).then(function () {
            component.find('spinner').hide();
        }, function (err) {
            if (err && err[0].message) {
                helper.notify({
                    title: 'error',
                    message: err[0].message,
                    type: 'error',
                });
            }

            component.find('spinner').hide();
            console.log('error:', err[0].message);
        });
    }
})