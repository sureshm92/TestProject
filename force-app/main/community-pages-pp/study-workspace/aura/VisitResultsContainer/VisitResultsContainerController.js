(
    {
        doInit: function (component, event, helper) {
            component.set('v.initialized', false);
            let spinner = component.find('mainSpinner');
            if (spinner) spinner.show();

            let resultMode = component.get('v.labResultsMode');
            const resultLabelByValue = {
                'Biomarkers': $A.get('$Label.c.Visit_Results_Tab_Biomarkers'),
                'Labs': $A.get('$Label.c.Visit_Results_Tab_Labs'),
                'Vitals': $A.get('$Label.c.Visit_Results_Tab_Vitals')
            };
            component.set('v.resultModeLabel', resultLabelByValue[resultMode]);

            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'getInitData', {
                    visitResultsMode: resultMode,
                    visitResultSharings: component.get('v.visitResultSharings')
                }, function (returnValue) {
                    component.set('v.initData', returnValue);
                    component.set('v.initialized', true);
                    component.set('v.togglePosition', returnValue.toggleState);
                    if (spinner) spinner.hide();
                });
            }
        },

        switchToggle: function (component, event, helper) {
            let spinner = component.find('mainSpinner');
            if (spinner) spinner.show();

            communityService.executeAction(component, 'switchToggleRemote', {
                visitResultsMode: component.get('v.labResultsMode'),
                isToggleOn: component.get('v.togglePosition')
            }, function () {
                if (spinner) spinner.hide();
            })
        }
    }
)