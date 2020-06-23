/**
 * Created by Andrii Kryvolap.
 */
({
    checkValidity : function (component, event, helper, stepWrapper){
        let isCurrentStepValid = true;
        let currentOutcomeSuccess = stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1;
        console.log('currentOutcomeSuccess ' + currentOutcomeSuccess);
        //@krishna Mahto - For REF-1390- start
        let ivsd = false;
        let ivst= false;
        //@krishna Mahto - For REF-1390- end
        
        stepWrapper.formFieldGroups.forEach(function (group) {
            group.fields.forEach(function (field) {
                 //@krishna Mahto - For REF-1390- start
                if(field.field =="Initial_visit_scheduled_date__c" && stepWrapper.cardTitle =="Contact Attempt" ){
                    ivsd=true;
                }
                if(field.field =="Initial_visit_scheduled_time__c" && stepWrapper.cardTitle =="Contact Attempt" ){
                    ivst=true;
                }
                 //@krishna Mahto - For REF-1390- end
                console.log(field.field + ' ' + field.value + ' required:' + field.required + ' valid:' + field.valid + ' dependent:' + field.dependent + ' type: ' + field.type);
                if (isCurrentStepValid &&
                    ((field.required && ((!field.dependent && currentOutcomeSuccess) || (field.dependent && field.dependentActive))) && (!field.value || field.value.trim() === '' || (field.value == 'false' && field.type == 'checkbox'))
                        || field.valid === false)) {
                    isCurrentStepValid = false;
                }
            });
            
        });
        //@krishna Mahto - For REF-1390- start
        if(ivst && ivst){
            component.set("v.isDateTimeFieldsAvailable",true);
        }
         //@krishna Mahto - For REF-1390- end
        let notesRequired = component.get('v.notesRequired');
        isCurrentStepValid = isCurrentStepValid && ((stepWrapper.outcomeList === undefined || stepWrapper.outcomeList.length== 0)
            ||(stepWrapper.outcome === undefined || stepWrapper.outcome ==='')
            ||!notesRequired
            ||(stepWrapper.notes !== undefined && stepWrapper.notes.trim() !== '')
        );
        console.log('isCurrentStepValid ' + isCurrentStepValid );
        component.set('v.stepWrapper.isCurrentStepValid', isCurrentStepValid);
        let partInfoForm = component.get('v.partInfoForm');
        partInfoForm.statusDetailValidityCheck();
    },
})