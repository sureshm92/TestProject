({
    init: function (component, event, helper) {
        let recordId = component.get('v.recordId');
        var pageRef = component.get('v.pageReference');
        if (pageRef != null) {
            var state = pageRef.state;
            if (state != null) {
                var base64Context = state.inContextOfRef;
                if (base64Context) {
                    if (base64Context.startsWith('1.')) {
                        base64Context = base64Context.substring(2);
                        var addressableContext = window.atob(base64Context);
                        var pageReferencePrevious = JSON.parse(addressableContext);
                        if (
                            pageReferencePrevious != null &&
                            pageReferencePrevious.attributes != null
                        ) {
                            if (
                                pageReferencePrevious.attributes.objectApiName ===
                                'Clinical_Trial_Profile__c'
                            ) {
                                recordId = pageReferencePrevious.attributes.recordId;
                            } 
                            component.set('v.recordId', recordId);
                            component.set('v.showLWC',true);
                        }
                    }
                }
            }
        }
    }
})