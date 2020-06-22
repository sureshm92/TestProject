/**
 * Created by Nargiz Mamedova on 6/16/2020.
 */

({
    doInit: function(component){
        component.set('v.reset', true);
        let currentMode = component.get('v.currentMode');
        let label;
        if(currentMode.participantState === 'ALUMNI' && !currentMode.isDelegate) label = $A.get("$Label.c.Viewing_as_Self");
        else {
            if(currentMode.userMode === 'Participant') label = $A.get("$Label.c.Viewing_as_Participant");
            if(currentMode.userMode === 'PI') label = $A.get("$Label.c.Viewing_as_Investigative_Site");
            if(currentMode.userMode === 'HCP') label = $A.get("$Label.c.Viewing_as_Referring_Provider");
            if(currentMode.isDelegate) label += ' ' + $A.get("$Label.c.Space_Delegate");
        }
        component.set('v.viewMode', label);
        component.set('v.reset', false);
    },
});