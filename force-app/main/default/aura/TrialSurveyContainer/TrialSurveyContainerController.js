({  
    
    doInit: function(component, event, helper) {  
        var state = component.get( "v.pageReference" ).state;
        var base64Context = state.inContextOfRef;
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        //Fetching Record Type Id
        var recordTypeId = state.recordTypeId;
        var recordId = addressableContext.attributes.recordId;
        component.set('v.ctpId', recordId);
        component.set('v.recordTypeId', recordTypeId);
        component.find('spinner').show();
        if(component.get('v.recordTypeId')){
            communityService.executeAction(component, 'getRecordTypeNameById', {
            recordTypeId: recordTypeId
            }, function(response) {
                component.set('v.recordtypeName', response);
                component.find('spinner').hide();
            });
        }
        component.find('spinner').hide();
    }  
    
})