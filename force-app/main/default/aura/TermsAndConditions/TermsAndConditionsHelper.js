/**
 * Created by Leonid Bartenev
 */
({
    goBack: function (component) {
        var retString = communityService.getUrlParameter('ret');
        var isPortalTC = component.get('v.isPortalTC');
        if(retString || retString === ''){
            var retPage = communityService.getRetPage(retString);
            communityService.navigateToPage(retPage);
        }else{
            if(!isPortalTC && component.get('v.ctpId')){
                communityService.navigateToPage('study-workspace?id=' + component.get('v.ctpId'));
            }else{
                communityService.navigateToPage('');
            }
        }
    }
})