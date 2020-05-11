({
    doInit: function(component, event, helper){
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(component,'getInitData', {isDelegate : isDelegate}, function (response){
            component.set('v.resourceStructureList', response);
            component.get('v.parent').find('mainSpinner').hide();
        });

    },

    doNavigate: function(component, event, helper){
        var resourceInd = event.currentTarget.getAttribute('data-attributeVal').split(',');
        var resource = component.get('v.resourceStructureList')[resourceInd[0]].resources[resourceInd[1]];
        if(resource.videoLink || resource.link){
            communityService.navigateToPage(resource.videoLink ? resource.videoLink : resource.link);
        } else {
            var url = 'resources?resourceType=' + resource.recordTypeDevName + '&resId=' + resource.resourceId;
            url += '&ret=' + communityService.createRetString();
            communityService.navigateToPage(url);
        }
    },
})