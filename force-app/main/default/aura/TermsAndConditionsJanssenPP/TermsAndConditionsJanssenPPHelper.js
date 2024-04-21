/**
 * Created by Leonid Bartenev
 */
({
    goBack: function (component) {
        sessionStorage.setItem('Cookies', 'Accepted');
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if (component.get('v.isMobileApp')) {
            communityService.preLoginPageRedirection(window.location.href, '');
        }
        if ((retString !== 'terms-and-conditions' && retString) || retString === '') {
            var retPage = communityService.getRetPage(retString);
            communityService.navigateToPage(retPage);
        } else {
            if (!isPortalTC && component.get('v.ctpId')) {
                communityService.navigateToPage('study-workspace?id=' + component.get('v.ctpId'));
            } else {
                communityService.navigateToPage('');
            }
        }
    },

    hideOkButton: function (component, event, helper) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if ((retString !== 'terms-and-conditions' && retString) || retString === '') {
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
    },

    setRTL: function (component) {
        var T_Ctext = component.get('v.tcData.tc.T_C_Text__c');
        if(T_Ctext){
        var res = '<div style=direction:rtl>' + T_Ctext + '</div>';
        component.set('v.tcData.tc.T_C_Text__c', res);
        }
    }
});