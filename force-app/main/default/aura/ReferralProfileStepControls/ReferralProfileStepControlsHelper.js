/**
 * Created by Leonid Bartenev
 */
({
    saveSelectedStatus: function (component) {
        var parent = component.get('v.parent');
        var rootComponent = component.get('v.rootComponent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        parent.find('spinner').show();
        var statusReason = step.selectedStatus.split(';');
        var status, reason;
        status = statusReason[0];
        if (statusReason.length > 1) reason = statusReason[1];
        var notes = step.notes;
        rootComponent.find('changePEStatusByPIAction').execute(pe, status, reason, notes, function (pe, steps) {
            parent.set('v.pe', pe);
            parent.set('v.statusSteps', steps);
            parent.doCallback();
        }, function () {
            parent.find('spinner').hide();
        });
    },
    getEmptyFieldNames: function (component, form) {
        var fieldNames = '';

        if (!form.get('v.participant').First_Name__c) fieldNames += ' "First Name"';
        if (!form.get('v.participant').Last_Name__c) fieldNames += ' "Last Name"';
        if (!form.get('v.participant').Date_of_Birth__c) fieldNames += ' "Date of Birth"';
        if (!form.get('v.participant').Gender__c) fieldNames += ' "Sex"';
        if (!form.get('v.participant').Phone__c) fieldNames += ' "Primary daytime telephone number"';
        if (!form.get('v.participant').Phone_Type__c) fieldNames += ' "Phone Type"';
        if (!form.get('v.participant').Email__c && form.find('emailInput').get('v.validity').valid) fieldNames += ' "Email address"';
        if (!form.get('v.participant').Mailing_Zip_Postal_Code__c ||  form.get('v.participant').Mailing_Zip_Postal_Code__c === '') fieldNames += ' "Zip/Postal code"';

        if (form.get('v.visitPlanRequired') && !form.get('v.pe').Visit_Plan__c) fieldNames += ' "Arm/Cohort"';
        if (form.find('screeningId').get('v.validity') && !form.find('screeningId').get('v.validity').valid) fieldNames += ' "Screening/Subject ID"';
        if (form.find('mrnId').get('v.validity') && !form.find('mrnId').get('v.validity').valid) fieldNames += ' "MRN/Internal ID"';

        return fieldNames;
    }
})