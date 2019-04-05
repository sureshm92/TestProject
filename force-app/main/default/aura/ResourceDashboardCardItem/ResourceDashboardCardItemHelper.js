(
    {
        trimLongText : function (returnValue) {
            let wrappers = returnValue.wrappers;
            for (let i = 0; i < wrappers.length; i++) {
                let title = wrappers[i].resource.Title__c;
                wrappers[i].resource.Title__c = title.length > 40 ? title.substring(0, 37) + '...' : title;
                let description = wrappers[i].resource.Description__c;
                wrappers[i].resource.Description__c = description.length > 83 ? description.substring(0, 80) + '...' : description;
            }
            return returnValue;
        }
    }
)