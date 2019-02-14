/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var iconsURL = component.get('v.iconsURL');
        helper.getIconsNames(iconsURL, function (iconNames) {
            component.set('v.iconNames', iconNames);
        });
        /*iconsURL = component.get('v.apolloIconsURL');
        helper.getIconsNames(iconsURL, function (iconNames) {
            component.set('v.apolloIconNames', iconNames);
        });*/

        helper.getInfoForFilterInfoAndSummaryInfo(component);
        component.set('v.chartData', [
            {segment: "Accepted", value: 8, color: '#00C221'},
            {segment: "On Hold", value: 0, color: '#FF9300'},
            {segment: "Declined", value: 4, color: '#E20000'},
            {segment: "Acceptance Pending", value: 6, color: '#297DFD'}
        ]);
        component.set('v.chartData2', [
            {segment: "Accepted", value: 12, color: '#00C221'},
            {segment: "On Hold", value: 4, color: '#FF9300'},
            {segment: "Declined", value: 5, color: '#E20000'},
            {segment: "Pending Approval/Activation", value: 20, color: '#297DFD'}
        ]);
    },

    toggleFilter: function (component, event, helper) {
        console.log("Filter status= " + component.get("v.filterInfo").isActive);
    }
})