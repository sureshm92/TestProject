({
    trimLongText: function (returnValue) {
        let wrappers = returnValue.wrappers;
        if (wrappers) {
            for (let i = 0; i < wrappers.length; i++) {
                if (wrappers[i].resource) {
                    let title = wrappers[i].resource.Title__c;
                    if (wrappers[i].resource.Title__c) {
                        wrappers[i].resource.Title__c =
                            title.length > 55 ? title.substring(0, 52) + '...' : title;
                    }
                    let description = wrappers[i].resource.Description__c;
                    if (wrappers[i].resource.Description__c) {
                        wrappers[i].resource.Description__c =
                            description.length > 120
                                ? description.substring(0, 117) + '...'
                                : description;
                    }
                }
            }
        }
        return returnValue;
    }
});
