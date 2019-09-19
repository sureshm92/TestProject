/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        helper.spinnerShow(component);
        helper.enqueue(component, 'c.getReportDataWrappers', {})
            .then(function (res) {
                let reportDataList = JSON.parse(res);
                component.set('v.peId', reportDataList[0].peId);
                component.set('v.reportDataList', reportDataList);
                helper.spinnerHide(component);
            }, function (err) {
                if (err && err[0].message) {
                    component.set('v.errorMessage', err[0].message);
                }
                console.log('error:', err[0].message);
                helper.spinnerHide(component);
            }).catch(function (err) {
            console.log('error:', err);
            helper.spinnerHide(component);

        });
    },

    onGenerateReport: function (component, event, helper) {
        try {
            helper.spinnerShow(component);
            var index = event.currentTarget.dataset.ind;
            let reportData = component.get('v.reportDataList')[index];
            component.set('v.reportData', reportData);
            helper.generateReport(component, helper);
        } catch (e) {
            console.error(e);
            helper.spinnerHide(component);
        }
    },
});