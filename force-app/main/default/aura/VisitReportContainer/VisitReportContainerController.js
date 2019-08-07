/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.show();
        }
        helper.enqueue(component, 'c.getReportDataWrappers', {})
            .then(function (res) {
                    component.set('v.reportDataList', JSON.parse(res));
                    let spinner = component.find('spinner');
                    if (spinner) {
                        spinner.hide();
                    }
                },
                function (err) {
                    if (err && err[0].message) {
                        component.set('v.errorMessage', err[0].message);
                    }
                    console.log('error:', err[0].message);
                    let spinner = component.find('spinner');
                    if (spinner) {
                        spinner.hide();
                    }
                });
    },

    onGenerateReport: function (component, event, helper) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.show();
        }
        var index = event.currentTarget.dataset.ind;
        let reportData = component.get('v.reportDataList')[index];
        component.set('v.reportData', reportData);
        helper.onGenerateReport(component, helper);
    },
});