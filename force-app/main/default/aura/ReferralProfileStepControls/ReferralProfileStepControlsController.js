/**
 * Created by Kryvolap on 04.09.2018.
 */
({
    doSaveSelectedStatus: function (component, event, helper) {
        var parent = component.get('v.parent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        if(step.selectedStatus === 'Enrollment Success'){
            var formComponent = parent.find('editForm');
            formComponent.set('v.isFinalUpdate', true);
            formComponent.checkFields();
            var missingFields = helper.getEmptyFieldNames(component, formComponent);
            if(!formComponent.get('v.isValid')){
                parent.set('v.saveAndChangeStep', true);
                debugger;
                document.getElementById('personalInfoAnchor').scrollIntoView({behavior: "smooth", block: "start", inline: "nearest"});
                setTimeout(function(){
                    communityService.showSuccessToast('', $A.get('$Label.c.RP_Missing_Fields') + ': ' + missingFields, 1000);
                }, 1000);
            } else{
                helper.saveSelectedStatus(component);
            }
        } else {
            helper.saveSelectedStatus(component);
        }
    },

    onStatusChange: function (component, event, helper) {
        var statusReason = component.get('v.step').selectedStatus;
        if (statusReason) {
            statusReason = statusReason.split(';');
            if (statusReason.length > 1 && statusReason[1] === "Other") {
                component.set('v.notesRequired', true);
            } else {
                component.set('v.notesRequired', false);
            }
        }
    }
})