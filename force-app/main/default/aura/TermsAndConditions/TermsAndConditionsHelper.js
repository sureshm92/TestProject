/**
 * Created by Leonid Bartenev
 */
({
    goBack: function (component) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if (component.get('v.isMobileApp')) {
            window.open(window.location.origin);
        }
        if (
            (retString !== 'terms-and-conditions' && retString) ||
            retString === ''
        ) {
            var retPage = communityService.getRetPage(retString);
            communityService.navigateToPage(retPage);
        } else {
            if (!isPortalTC && component.get('v.ctpId')) {
                communityService.navigateToPage(
                    'study-workspace?id=' + component.get('v.ctpId')
                );
            } else {
                communityService.navigateToPage('');
            }
        }
    },
    //@Krishna Mahto - PEH-2450 - Start
    hideOkButton: function (component, event, helper) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if (
            (retString !== 'terms-and-conditions' && retString) ||
            retString === ''
        ) {
            component.set('v.isUserLoggedIn', true);
        } else {
            if (!isPortalTC && component.get('v.ctpId')) {
                component.set('v.isUserLoggedIn', true);
            } else if (!communityService.isDummy()) {
                component.set('v.isUserLoggedIn', true);
            } else {
                component.set('v.isUserLoggedIn', false);
            }
        }
    }, //@Krishna Mahto - PEH-2450 - End

    setRTL: function (component) {
        var T_Ctext = component.get('v.tcData.tc.T_C_Text__c');
        var res = T_Ctext.replaceAll('<p>', '<p style=' + '"direction:rtl">');
        var res = res.replaceAll('<h1>', '<h1 style=' + '"direction:rtl">');
        var res = res.replaceAll('<ul>', '<ul style=' + '"direction:rtl">');
        component.set('v.tcData.tc.T_C_Text__c', res);
    }
});
