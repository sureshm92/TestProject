({
    getListofAvailableReports: function (component, event, helper) {
      component.find("spinner").show();
      communityService.executeAction(
        component,
        "getReportList",
        {
          humanId: component.get("v.pe").Unique_HumanId__c
        },
        function (returnvalue) {
          var reportList = returnvalue.reportList;
          var highlightsReport;
          var detailedReport = [];
          if (reportList != undefined) {
            for (var i = 0; i < reportList.length; i++) {
              if (reportList[i].reportName == "Highlights Report") {
                highlightsReport = reportList[i];
                component.set("v.isReportAvailable", true);
              } else {
                detailedReport.push(reportList[i]);
                component.set("v.isReportAvailable", true);
              }
            }
          }else{
              helper.getRequestHistory(component, event, helper);
          }
          component.set("v.highlightsReport", highlightsReport);
          component.set("v.detailedReport", detailedReport);
        },
        null,
        function () {
          component.find("spinner").hide();
        }
      );
    },
  
    requestRecords: function (component, event, helper) { 
        component.find("spinner").show();
        communityService.executeAction(
          component,
          "requestMedicalRecords",
          {
            humanId: component.get("v.pe").Human_Id__c,
            uniqueId: component.get("v.pe").Unique_HumanId__c,
            email: component.get("v.pe").Participant__r.Email__c,
            peId: component.get("v.pe").Id,
            ParticipantId : component.get("v.pe").Participant__c,
            isAdult : component.get("v.pe").Participant__r.Adult__c 
          },
          function (returnvalue) {
              if(returnvalue != 'EmailError'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                  title: "Requested Successfully",
                  type: "success",
                  message: $A.get('$Label.c.RH_MedicalRetrive_Succces') 
                });
                toastEvent.fire();
                helper.getRequestHistory(component, event, helper);
              }
              else if(returnvalue == 'EmailError'){
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      title: "Requested Not Completed",
                      type: "Error",
                      message: $A.get('$Label.c.RH_MedicalRetrieve_EmailError') 
                  });
                  toastEvent.fire();
              }
                  else if(returnvalue == 'APIError'){
                      var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      title: "Requested Not Completed",
                      type: "Error",
                      message: "Oops! Something went wrong, Please contact Admin"
                  });
                  toastEvent.fire();
                  }
          },
          null,
          function () {
            component.find("spinner").hide();
          }
        );
    }
  });
  