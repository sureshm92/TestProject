/**
 * Created by Leonid Bartenev
 */

({
    doInit: function (component) {
        component.set('v.initialized', true);
    },

    doGenerateReport: function (component, event, helper) {
        if (component.get('v.initialized') && component.get('v.isMobileApp')) {
           /** communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            ); 
            return; **/
            communityService.executeAction(
                component,
                'getBase64fromVisitSummaryReportPage',
                {
                    peId: component.get('v.peId'),
                    isRTL : component.get('v.isRTL')

                },
                function (returnValue) {
                 // alert(returnValue);
                  communityService.navigateToPage('mobile-pdf-viewer?pdfData='+returnValue);   
                }
            );
          
           return;
        }
       /** 
         helper.uploadReportData(component, function () {
            window.setTimeout(
                $A.getCallback(function () {
                    helper.generateReport(component);
                }),
                100
            );
        });  **/ 

        const peId = component.get('v.peId');
        const isRTl=  component.get('v.isRTL');
        var pageurl = window.location.href;
        if (pageurl.includes('gsk')){
            window.open('/gsk/apex/VisitSummaryReportPage?peId='+peId+'&isRTL='+isRTl);
        }
        else if(pageurl.includes('janssen')){
            window.open('/janssen/apex/VisitSummaryReportPage?peId='+peId+'&isRTL='+isRTl);
        }
        else{
            window.open('/apex/VisitSummaryReportPage?peId='+peId+'&isRTL='+isRTl);
        } 
         

    }
});