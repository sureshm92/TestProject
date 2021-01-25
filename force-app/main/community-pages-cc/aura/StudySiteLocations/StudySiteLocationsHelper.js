({
    sortAndSetAccountsByName: function (component, accounts) {
        accounts.sort(function (a, b) {
            var nameA = a.Name.toUpperCase();
            var nameB = b.Name.toUpperCase();
            if (nameA < nameB) {
                return -1;
            }
            if (nameA > nameB) {
                return 1;
            }
            return 0;
        });
        component.set('v.studySiteAccounts', accounts);
    },
    
    getCountryData: function(component, event, helper){
        communityService.executeAction(component, 'getInitData', null, function (initData) {
            component.set('v.countriesLVList', initData.countriesLVList);
            component.set('v.statesByCountryMap', initData.statesByCountryMap);            
        });
    }
});