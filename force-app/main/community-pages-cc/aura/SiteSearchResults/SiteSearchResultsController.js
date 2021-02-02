({
    doNavigate: function (component, event, helper) {
        debugger;
        let index = event.currentTarget.dataset.index;
        //TO DO: move to filteredResultSet
        let siteData = component.get('v.resultSet')[index];
        //communityService.navigateToPage('study-workspace?id=' + siteData.ctpId);
        window.open('study-workspace?id=' + siteData.ctpId, '_blank');
    }
});
