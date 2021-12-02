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

        component.set('v.isCallLWCComponent', true);
        //When refresh happen after cancel/Save button click, the trialSurvey component gets called again internally. 
        //On Cancel/Save, we are passing current CTP id in URL to nevigate to current CTP page.  
        //To Avoid the unneccessary call, reading current CTP id from the URL parameter and stopping the trialSurvey LWC call on Cancel/Save button. 
        var urlpath = window.location.pathname;
        if(urlpath.indexOf(component.get('v.ctpId'))>-1){
        	component.set('v.isCallLWCComponent', false);
         	
        }
    },

    //Handle the "refresh" event dispached from trilaSurvey LWC component to refresh the page. 
    refresh : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        component.set('v.isCallLWCComponent', false);
     }
    
})