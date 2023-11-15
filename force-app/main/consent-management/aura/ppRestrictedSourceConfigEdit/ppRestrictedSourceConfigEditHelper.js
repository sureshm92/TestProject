({
    init: function (component, event, helper) {
        let recordId = component.get('v.recordId');
        var pageRef = component.get('v.pageReference');
        //component.set('v.isShowModal',true);
        if (pageRef != null) {
            var state = pageRef.state;
            console.log('state::'+JSON.stringify(state));
            if (state != null) {
                var base64Context = state.inContextOfRef;
                if (base64Context) {
                    if (base64Context.startsWith('1.')) {
                        console.log('base64Context::'+JSON.stringify(base64Context));
                        base64Context = base64Context.substring(2);
                        console.log('base64Context::'+JSON.stringify(base64Context));
                        var addressableContext = window.atob(base64Context);
                        console.log('addressableContext::'+JSON.stringify(addressableContext));
                        var pageReferencePrevious = JSON.parse(addressableContext);
                        console.log('pageReferencePrevious::'+JSON.stringify(pageReferencePrevious));
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
    },
    getURLParameterValue: function(component) {
 
        var querystring = location.search.substr(1);
        console.log('querystring-' + JSON.stringify(querystring));
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
  
        console.log('paramValue-' + JSON.stringify(paramValue));
        //return paramValue;
    }
})