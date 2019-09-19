/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        helper.updatePathSteps(component);
    },

    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if(!isCollapsed){
            component.find('statusHistory').loadHistory();
        }
    },

    showEditParticipantInformation: function (component, event, helper) {
        console.log('hi');
        var rootComponent = component.get('v.parent');
        console.log('rootComponent', JSON.parse(JSON.stringify(rootComponent)));
        var pe = component.get('v.pe');
        console.log('pe', JSON.parse(JSON.stringify(pe)));
        var pathItems = helper.preparePathItems(component);
        console.log('pathItems', JSON.parse(JSON.stringify(pathItems)));
        var anchor = event.currentTarget.value;
        console.log('anchor', JSON.parse(JSON.stringify(anchor)));
        rootComponent.find('updatePatientInfoAction').execute(pe, pathItems, anchor, rootComponent, function (enrollment) {
            component.set('v.pe', enrollment);
        });
    },
})