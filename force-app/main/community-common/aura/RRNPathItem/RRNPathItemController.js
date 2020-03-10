/**
 * Created by Leonid Bartenev
 */
({
    doNavigateToPage: function (component) {
        var page = component.get('v.page');
        if(page !== 'empty') communityService.navigateToPage(page);
    }
})