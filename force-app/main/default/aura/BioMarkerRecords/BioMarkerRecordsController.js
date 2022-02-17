({
	doInit : function(cmp, event, helper) {
        var action=cmp.get('c.getAssessedDateForPE');
       //cmp.set('v.perRecordId',cmp.get('v.pe').Id );
        action.setParams({ "perId" : cmp.get('v.pe').Id });
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") { 
                var returnValue = response.getReturnValue();
                cmp.set('v.AssessedDate',returnValue.dateTimeLabelValue);
                cmp.find('mediaId1').fileRecords(cmp.get('v.pe').Id,returnValue.dateTimeLabelValue[0].value);
                cmp.set('v.biomarkerRecords',returnValue.mapBiomarkerKeyValue);
            } 
        });
        $A.enqueueAction(action);  
	},
    
    updateBiomarkerData : function(cmp,evt,helper){
        cmp.find('mediaId1').fileRecords(cmp.get('v.pe').Id,cmp.get('v.AssesedDateSelected'));
        cmp.find('spinner').show();
        var action=cmp.get('c.getFilterbiomarker');
        action.setParams({ "perId" : cmp.get('v.pe').Id,"strAssesedDateTime" : cmp.get('v.AssesedDateSelected')});

        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set('v.biomarkerRecords',result);
                cmp.find('spinner').hide();
            } 
        });
        $A.enqueueAction(action);  
        
    }
})