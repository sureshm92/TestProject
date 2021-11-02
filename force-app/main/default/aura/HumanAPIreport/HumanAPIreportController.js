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
      if (component.get("v.pe").Participant__r.Email__c != null) {
        component.find("spinner").show();
        communityService.executeAction(
          component,
          "requestMedicalRecords",
          {
            humanId: component.get("v.pe").Human_Id__c,
            uniqueId: component.get("v.pe").Unique_HumanId__c,
            email: component.get("v.pe").Participant__r.Email__c,
            peId: component.get("v.pe").Id
          },
          function (returnvalue) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              title: "Requested Successfully",
              type: "success",
              message:
                "We have notified the patient to authorize medical vendor(s)"
            });
            toastEvent.fire();
            helper.getRequestHistory(component, event, helper);
          },
          null,
          function () {
            component.find("spinner").hide();
          }
        );
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Requested Not Completed",
          type: "Error",
          message: "Please Update Participant's Email first"
        });
        toastEvent.fire();
      }
    }
  });
  