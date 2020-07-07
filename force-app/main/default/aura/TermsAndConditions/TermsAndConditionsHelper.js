/**
 * Created by Leonid Bartenev
 */
({
    goBack: function (component) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if(retString !== 'terms-and-conditions' && retString || retString === ''){
            var retPage = communityService.getRetPage(retString);
            communityService.navigateToPage(retPage);
        }else{
            if(!isPortalTC && component.get('v.ctpId')){
                communityService.navigateToPage('study-workspace?id=' + component.get('v.ctpId'));
            }else{
                communityService.navigateToPage('');
            }
        }
    },
    //@Krishna Mahto - PEH-2450 - Start
    hideOkButton: function (component, event, helper) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if(retString !== 'terms-and-conditions' && retString || retString === ''){
            component.set("v.isUserLoggedIn", true);
        }else{
            if(!isPortalTC && component.get('v.ctpId')){
                component.set("v.isUserLoggedIn", true);
            }else{
                component.set("v.isUserLoggedIn", false);
            }
        }
    }
    //@Krishna Mahto - PEH-2450 - End
})