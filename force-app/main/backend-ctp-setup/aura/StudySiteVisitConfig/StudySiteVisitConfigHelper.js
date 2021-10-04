/**
 * Created by Igor Malyuta on 19.09.2019.
 */

({
    setSearchResponse: function (component, searchResponse) {
        component.set('v.haveEmptyAssigment', searchResponse.haveEmptyAssigment);
        component.set('v.ssItems', searchResponse.studySiteItems);
        component.set('v.pagination', searchResponse.pagination);
        component.set('v.visitPlans', searchResponse.visitPlans);
        component.find('spinner').hide();
    },

    updateItems: function (component, saveCurrentState) {
        component.find('spinner').show();
        let helper = this;
        let ssItemsJSON = null;
        if (saveCurrentState) ssItemsJSON = JSON.stringify(component.get('v.ssItems'));
        communityService.executeAction(
            component,
            'getItems',
            {
                ssItemsJSON: ssItemsJSON,
                filterJSON: JSON.stringify(component.get('v.filter')),
                paginationJSON: JSON.stringify(component.get('v.pagination'))
            },
            function (searchResponse) {
                helper.setSearchResponse(component, searchResponse);
            }
        );
    }
});
