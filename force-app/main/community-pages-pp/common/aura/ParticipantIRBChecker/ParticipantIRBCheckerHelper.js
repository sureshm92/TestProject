/**
 * Created by Igor Malyuta on 03.09.2019.
 */

({
    peBySession: {},

    isToastDisplayed : function (peId) {
        var isDisplayed = this.peBySession[peId] !== undefined;
        this.peBySession[peId] = peId;
        return isDisplayed;
    },

    showToast : function (component) {
        if(!component.get('v.isNewSession') && this.isToastDisplayed(component.get('v.peId'))) return;

        var template = component.get('v.displayText') + ' {0}';
        var accUrl = 'account-settings?langloc';
        var urlLabel = $A.get('$Label.c.PP_IRB_Button_Review');

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'warning',
            mode: 'sticky',
            message: 'This is a required message',
            messageTemplate: template,
            messageTemplateData: [{
                url: accUrl,
                label: urlLabel
            }]
        });
        toastEvent.fire();
    }
});