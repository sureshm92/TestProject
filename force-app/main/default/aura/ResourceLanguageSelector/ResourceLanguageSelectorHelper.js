/**
 * Created by Igor Malyuta on 13.09.2019.
 */

({
    navigate: function (component, resourceType, resourceId) {
        communityService.navigateToPage(
            'resources?resourceType=' + resourceType
            + '&id=' + communityService.getUrlParameter('id')
            + '&resId=' + resourceId +
            '&ret=' + communityService.createRetString()
        );
    }
});