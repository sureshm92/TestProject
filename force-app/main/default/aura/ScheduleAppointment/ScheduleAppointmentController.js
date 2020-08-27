({
    init : function (component) {
        // Find the component whose aura:id is "flowId"
        //alert(component.get("v.recordId"));
        var flow = component.find("flowId");
        // In that component, start your flow. Reference the flow's Unique Name.
        var inputVariables = [{name:'SiteId', type:'String', value:component.get("v.recordId")}];
        flow.startFlow("New_Appointment001",inputVariables);
        
         //var flow1 = component.find("flowIdReschedule");
         //flow1.startFlow("Modify_Outbound_Appointment");
    },
})