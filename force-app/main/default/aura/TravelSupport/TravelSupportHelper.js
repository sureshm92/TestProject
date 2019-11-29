/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

({
    checkOnDisclaimer: function (component, event) {
        let isShowMore = component.get('v.isShowDisclaimer');
        if (isShowMore) {
            component.set('v.selectedVendor', null);
            component.set('v.isShowDisclaimer', false);
            let message = component.get('v.message');
            let htmlMessage = message.replace(new RegExp('\\n', 'g'), '<br/>');
            component.set('v.htmlMessage', htmlMessage);
        }
    },

    redirectToUrl: function (component, event) {
        let eUrl = $A.get('e.force:navigateToURL');
        eUrl.setParams({
            'url': component.get('v.selectedVendor').Link_Vendor__c
        });
        component.find('popup').cancel();
        eUrl.fire();
    },

    transformToHtmlMessage: function (component, event) {
        let message = component.get('v.message');
        let htmlMessage = message.replace(new RegExp('\\n', 'g'), '<br/>');
        component.set('v.htmlMessage', htmlMessage);
    },

    getAvailableVendors: function (component, event, helper) {
        helper.enqueue(component, 'c.getInitData')
            .then(function (result) {
                let ps = JSON.parse(result);
                if (result) {
                    let studySiteId = ps.pe.Study_Site__c;
                    component.set('v.studySiteId', ps.pe.Study_Site__c);
                    helper.enqueue(component, 'c.getVendors',
                        {
                            studySiteId: studySiteId
                        }
                    ).then(function (result) {
                        console.log(JSON.stringify(result));
                        if (result) {
                            component.set('v.vendors', result);
                        }
                    }, function (err) {
                        if (err && err[0].message) {
                            helper.notify({
                                title: 'error',
                                message: err[0].message,
                                type: 'error',
                            });
                        }
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
            });

        component.find('spinner').hide();
    },
});