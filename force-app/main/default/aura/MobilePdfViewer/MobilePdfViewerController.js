({
    loadpdf: function (component, event, helper) {
        var pdfjsframe = component.find('pdfFrame');
        var idParamValue = helper.getURLParameterValue().pdfData;
        var resId = helper.getURLParameterValue().resId;
        var lang = helper.getURLParameterValue().lang;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const updates = urlParams.get('updates');
        if (updates) {
            var button = component.find('button');
            $A.util.addClass(button, 'button-hide');
        }
        console.log('idParamValue' + idParamValue);
        console.log('resId::' + resId + 'lang::' + lang);
        console.log('idParamValue' + idParamValue);
        if (typeof idParamValue !== 'undefined') {
            component.set('v.hideDivResource', 'slds-hide');
            component.set('v.isResourceVisible', 'true');
            var ss = idParamValue.split(' ').join('+');
            window.setTimeout(
                $A.getCallback(function () {
                    component.find('spinner').hide();
                    component.set('v.pdfData', ss);
                    helper.loadpdf(component, event);
                }),
                500
            );
        } else {
            if (typeof resId !== 'undefined') {
                component.set('v.hideDivResource', 'slds-hide');
                communityService.executeAction(
                    component,
                    'getBase64Resource',
                    {
                        resourceId: resId,
                        language: lang
                    },
                    function (returnValue) {
                        component.find('spinner').hide();

                        component.set('v.pdfData', returnValue);
                        helper.loadpdf(component, event);
                    }
                );
            } else {
                component.set('v.isResourceVisible', 'false');

                try {
                    var resourceName = helper.getURLParameterValue().resourceName;
                    var webViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
                    var iframe = document.getElementById('frame');
                    iframe.src =
                        $A.get('$Resource.pdfjs_dist') +
                        '/web/viewer.html' +
                        '?file=' +
                        $A.get('$Resource.' + resourceName);
                    component.set('v.hideDiv', 'slds-hide');
                    component.find('spinner').hide();
                } catch (err) {
                    alert(err.message);
                }
            }
        }
    },

    backToPreviousPage: function (cmp, event) {
        window.history.back();
    }
});
