/**
 * Created by Leonid Bartenev
 */
({
    doSwitchCollapse: function (component) {
        component.set('v.isCollapsed', !component.get('v.isCollapsed'));
    },
    doSwitchShowMore: function (component) {
        component.set('v.showMore', !component.get('v.showMore'));
    },
      onClickListView: function (component, event, helper){
        communityService.navigateToPage('listviewparticipant');
    },
    doExportFull: function (component) {
        var p = component.get("v.parent");
        p.export();
    },
})