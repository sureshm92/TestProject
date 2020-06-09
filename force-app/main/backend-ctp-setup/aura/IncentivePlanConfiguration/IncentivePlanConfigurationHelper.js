/**
 * Created by Alexey Moseev on 5/7/20.
 */

({
    setSearchResponse: function(component, searchResponse) {
        component.set('v.haveEmptyAssigment', searchResponse.haveEmptyAssigment);
        component.set('v.ssItems', searchResponse.studySiteItems);
        component.set('v.pagination', searchResponse.pagination);
        component.set('v.incentivePlans', searchResponse.incentivePlans);

        let setOfSS = new Set();
        if (component.get('v.setOfSS')) {
            setOfSS = component.get('v.setOfSS');
        }
        for (let index = 0; index < searchResponse.studySiteItems.length; index++) {
            let item = searchResponse.studySiteItems[index];
            setOfSS.add(item.ss.Id);
        }
        component.set('v.setOfSS', setOfSS);

        if (!component.get('v.initilizedMap')) {
            var allSelectedIPs = {};
            if (component.get('v.allSelectedIPs')) {
                allSelectedIPs = component.get('v.allSelectedIPs');
            }
            for (let index = 0; index < searchResponse.incentivePlans.length; index++) {
                if (!allSelectedIPs[searchResponse.incentivePlans[index].value]) {
                    allSelectedIPs[searchResponse.incentivePlans[index].value] = new Set();
                }
            }
            component.set('v.allSelectedIPs', allSelectedIPs);
            component.set('v.initilizedMap', true);
        }

        component.find('spinner').hide();
    },

    updateItems: function(component, saveCurrentState) {
        component.find('spinner').show();
        let helper = this;
        let ssItemsJSON = null;
        if (saveCurrentState) ssItemsJSON = JSON.stringify(component.get('v.ssItems'));

        communityService.executeAction(component, 'getItems', {
            ssItemsJSON: ssItemsJSON,
            filterJSON: JSON.stringify(component.get('v.filter')),
            paginationJSON: JSON.stringify(component.get('v.pagination'))
        }, function (searchResponse) {
            helper.setSearchResponse(component, searchResponse);
        });
    }

});