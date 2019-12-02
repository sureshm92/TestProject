/**
 * Created by Leonid Bartenev
 */
({
    allItemsMap: {},

    getAllItems: function (component, callback) {
        var helper = this;
        if(helper.allItemsMap[component.get('v.sObjectName')] && helper.allItemsMap[component.get('v.sObjectName')][component.get('v.fieldName')]){
            callback(helper.allItemsMap[component.get('v.sObjectName')][component.get('v.fieldName')]);
        }else{
            communityService.executeAction(component, 'getAllValues', {
                objectName: component.get('v.sObjectName'),
                fieldName: component.get('v.fieldName'),
                iconName: component.get('v.iconName')
            }, function (fieldItems) {
                var fieldFieldItems = {};
                fieldFieldItems[component.get('v.fieldName')] = fieldItems;
                helper.allItemsMap[component.get('v.sObjectName')] = fieldFieldItems;
                callback(fieldItems);
            })
        }
    }

})