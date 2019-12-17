/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set('v.userMode', communityService.getUserMode());
        var trialId = communityService.getUrlParameter('id');
        component.set('v.trialId', trialId);
        var siteId = communityService.getUrlParameter('siteId');
        component.set('v.siteId', siteId);
            component.set('v.isInitialized', true);
        //     component.set('v.skipUpdate', false);
            spinner.hide();
        // });
    },
    doExport: function (component) {
        var exportURL = communityService.getCommunityURLPathPrefix().replace('/s','/apex') + '/exportexcelpage';

        var params = [];
        params.push('userMode=' + component.get('v.userMode'));
        if(params.length > 0) exportURL += '?' + params.join('&');
        console.log('Export URL: ' + exportURL);
        window.open(exportURL, '_blank');
    },

})