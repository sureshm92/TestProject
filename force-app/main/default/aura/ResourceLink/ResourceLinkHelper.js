/**
 * Created by Leonid Bartenev
 */
({
    viewResource: function (resource, languageCode) {
        var url = 'resources?resourceType=' + resource.RecordType.DeveloperName + '&resId=' + resource.Id;
        if(languageCode) url += '&lang=' + languageCode;
        url += '&ret=' + communityService.createRetString();
        communityService.navigateToPage(url);
    }
})