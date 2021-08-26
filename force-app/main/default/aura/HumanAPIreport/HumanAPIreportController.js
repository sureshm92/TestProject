({
    getListofAvailableReports : function(component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getReportList',
            {
                humanId : component.get("v.pe").Unique_HumanId__c
            },
            function (returnvalue) {
                var reportList = returnvalue.reportList;
                var highlightsReport;
                var detailedReport = [];
                if(reportList != undefined){
                    for(var i=0; i< reportList.length; i++){
                        if(reportList[i].reportName == 'Highlights Report'){
                            highlightsReport = reportList[i];
                            component.set("v.isReportAvailable", true);
                        }else{
                            detailedReport.push(reportList[i]);
                            component.set("v.isReportAvailable", true);
                        }
                    }
                }
                component.set("v.highlightsReport", highlightsReport);
                component.set("v.detailedReport", detailedReport);
            },
            null,
            function () {
                component.find('spinner').hide();
            }
        );
    },

})