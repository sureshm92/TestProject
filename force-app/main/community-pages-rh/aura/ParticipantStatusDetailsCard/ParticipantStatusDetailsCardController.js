/**
 * Created by Andrii Kryvolap.
 */
({
    doInit : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    updateReasonList : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.stepWrapper.currentOutcomeSuccess',stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1);
        component.set('v.reasonList', stepWrapper.reasonMap[stepWrapper.outcome]);
        helper.checkValidity(component, event, helper, stepWrapper)
    },
    updateNotesRequired : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.notesRequired', stepWrapper.notesRequiredMap[stepWrapper.outcome+';'+stepWrapper.reason]);
    },
    doSaveChanges : function (component, event, helper) {
        var parent = component.get('v.parent');
        parent.doUpdatePatientStatus();
    },
    doCheckDependentFields : function (component, event, helper) {

        var stepWrapper = component.get('v.stepWrapper');
        helper.checkValidity(component, event, helper, stepWrapper);
        var updateInProgress = component.get('v.updateInProgress');
        if(!updateInProgress){
            component.set('v.updateInProgress', true);
            var params = event.getParam('arguments');
            var fieldName = params.fieldName;
            if(stepWrapper.fieldDependencyMap.hasOwnProperty(fieldName)){
                var dependentFields = stepWrapper.fieldDependencyMap[fieldName];
                for(var i = 0; i < stepWrapper.formFieldGroups.length; i++ ){
                    for( var j = 0; j < stepWrapper.formFieldGroups[i].fields.length;j++){
                        if(dependentFields.indexOf(stepWrapper.formFieldGroups[i].fields[j].field)!=-1){
                            if(params.value==='false'){
                                stepWrapper.formFieldGroups[i].fields[j].required = false;
                                stepWrapper.formFieldGroups[i].fields[j].value = '';
                                stepWrapper.formFieldGroups[i].fields[j].readonly = true;
                            }
                            else{
                                stepWrapper.formFieldGroups[i].fields[j].required = true;
                                stepWrapper.formFieldGroups[i].fields[j].readonly = false;
                            }
                        }
                    }
                }
                // stepWrapper.formFieldGroups.forEach(function (group) {
                //     group.fields.forEach(function (field) {
                //         if(dependentFields.indexOf(field.field)!=-1){
                //             if(params.value==='false'){
                //                 field.required = false;
                //                 field.value = false;
                //                 field.readonly = true;
                //             }
                //             else{
                //                 field.required = true;
                //                 field.readonly = false;
                //             }
                //         }
                //     });
                // });
                component.set('v.stepWrapper.formFieldGroups', stepWrapper.formFieldGroups);
            }
            component.set('v.updateInProgress', false);
        }
    },
})