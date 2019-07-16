/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.show();
        }
        var action = component.get("c.getReportDataWrappers");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.reportDataList', JSON.parse(response.getReturnValue()));
                component.set('v.isReportData', true);
                console.log(component.get('v.reportData'));
                helper.onGenerateReport(component, helper);
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.errorMessage', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            let spinner = component.find('spinner');
            if (spinner) {
                spinner.hide();
            }
        });
        $A.enqueueAction(action);
    },

    onGenerateReport: function (component, event, helper) {
        var index = event.currentTarget.dataset.ind;
        let reportData = component.get('v.reportDataList')[index];
        component.set('v.reportData', reportData);
        console.log('reportData ===> ', JSON.stringify(reportData));
        helper.onGenerateReport(component, helper);
    },
});