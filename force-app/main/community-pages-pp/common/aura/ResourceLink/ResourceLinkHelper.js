/**
 * Created by Leonid Bartenev
 */
({
    viewResource: function (resource, languageCode) {
        if (communityService.isMobileSDK()) {
          /**  communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            ); **/
            if(resource.RecordType.DeveloperName=='Video') communityService.navigateToPage(url);
            communityService.navigateToPage('pdfdemo?resId=' + resource.Id+'&lang=' + languageCode);
            return;
        }
        var url =
            'resources?resourceType=' + resource.RecordType.DeveloperName + '&resId=' + resource.Id;
        if (languageCode) url += '&lang=' + languageCode;
        url += '&ret=' + communityService.createRetString();   
        communityService.navigateToPage(url); 
    }
});