({
  getRequestHistory: function (component, event, helper) {
    component.find("spinner").show();
    communityService.executeAction(
      component,
      "getRequestHistory",
      {
        peId: component.get("v.pe").Id
      },
      function (returnvalue) {
        component.set("v.requestHistory", returnvalue);
      },
      null,
      function () {
        component.find("spinner").hide();
      }
    );
  }
});
