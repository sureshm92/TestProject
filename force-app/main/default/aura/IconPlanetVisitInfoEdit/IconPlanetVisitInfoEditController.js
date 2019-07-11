/**
 * Created by Yehor Dobrovolskyi
 */
({
    onInit: function (component, event, helper) {
    },
    loadIconsDescription: function (component, event, helper) {
        debugger;
        helper.getThisLegends(component, event, helper);
      /*  helper.getCustomIconsNames(component, event, helper);*/
    },
    openLegendCreation: function (component, event, helper) {
        component.find('createLegendModal').show();
    },
    onInputChange: function (component, event, helper) {
        debugger;
        let value = event.getParam("value");
        component.set('v.existingIconsPackage', value[0]);
        helper.getExistingLegend(component, event, helper);
    },
    preload: function (component, event, helper) {
        /*   component.find('visitPlan').set('v.value', component.get('v.visitPlanId'));*/
    },
    handleLegendCreation: function (component, event, helper) {
        debugger;
        const recId = event.getParams().response.id;
        component.set('v.iconPackageId', recId);
        helper.createVisitPackage(component, event, helper);
    },
    cansel: function (component, event, helper) {
        debugger;
        component.find('createLegendModal').hide();
    },
    submitIcon: function (component, event, helper) {
        component.find('editFormIcon').submit();
    },
    onError: function (component, event, helper) {
        debugger;
        component.find('createLegendModal').hide();
    },

    closeModal: function (component, event, helper) {
        component.find('customModal').hide();
    },

    saveIconsLegend: function (component, event, helper) {
        helper.saveIconsLegend(component, event, helper);

    },

    show: function (component, event, helper) {
        component.find('customModal').show();
    },
});