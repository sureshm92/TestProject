/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        var pe = component.get('v.pEnrollment');
        if(!pe) return;
        var peStatus = pe.Participant_Status__c;
        var iconName, color, label;
        if(peStatus === 'Failed Review'){
            iconName = 'icon-close-solid';
            label = $A.get("$Label.c.PG_PS_L_Failed_Medical_Record_Review");
            color = 'red';
        }else if(peStatus === 'Pending Referral'){
            iconName = 'icon-check-solid';
            label = $A.get("$Label.c.PG_PS_L_Passed_Medical_Record_Review");
            color = 'green';
        }else if(peStatus === 'Failed Referral'){
            iconName = 'icon-close-solid';
            label = $A.get("$Label.c.PG_PS_L_Failed_referral");
            if(pe.Non_Referral_Reason__c) label = pe.Non_Referral_Reason__c;
            color = 'red';
        }
        component.set('v.colorClass', color);
        component.set('v.iconName', iconName);
        component.set('v.statusLabel', label);

    }
})