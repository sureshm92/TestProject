/**
 * Created by Yehor Dobrovolskyi
 */
({
    onInit: function (component, event, helper) {
       helper.getIconsDescription(component, event, helper);
    },
    loadIconsDescription: function (component, event, helper) {
        helper.getIconsDescription(component, event, helper);
    },

    closeModal: function (component, event, helper) {
        component.find('customModal').hide();
    },

    submitForm: function (component, event, helper) {
      helper.onSubmit(component, event, helper);

    },

    show: function (component, event, helper) {
        component.find('customModal').show();
    },
});