/**
 * Created by Leonid Bartenev
 */
({
    doSearchByTerm: function (component, event, helper) {
        const callback = event.getParam('arguments').callback;
        var searchTerm = component.get('v.searchTerm');
        var value = component.get('v.value');
        var searchResults = [];
        helper.getAllItems(component, function (allItems) {
            for(var i = 0; i < allItems.length; i++){
                var item = allItems[i];
                if(item.id.toLowerCase().indexOf(searchTerm.toLocaleString()) !== -1 && value.indexOf(item.id) === -1){
                    searchResults.push(item);
                }
            }
            callback(searchResults);
        })
    },

    doSearchByValue: function (component, event, helper) {
        const callback = event.getParam('arguments').callback;
        var value = component.get('v.value');
        var selection = [];
        helper.getAllItems(component, function (allItems) {
            for(var i = 0; i < allItems.length; i++){
                var item = allItems[i];
                if(value.indexOf(item.id) !== -1){
                    selection.push(item);
                }
            }
            callback(selection);
        });
    }

})