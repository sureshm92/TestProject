({
    DoInit: function(component, event, helper) {
        const values = [
            $A.get("$Label.c.MO_Active"),
            $A.get("$Label.c.MO_Closed"),
        ];
        component.set('v.status', values);
        var activerequest = $A.get("$Label.c.Active_Requests");
        var resultarrayActive = activerequest.toString().split(',');
        component.set("v.activerequest", resultarrayActive);
        var closedrequest = $A.get("$Label.c.Closed_Requests");
        var resultarrayClosed = closedrequest.toString().split(',');
        component.set("v.closedrequest", resultarrayClosed);
    },
    ShowOutreachRecord: function(component, event, helper) {
        var target = event.target;
        var rowIndex = target.getAttribute("data-row-index");
        var tableindex = event.target.value;
        if (tableindex == 0) {
            component.set("v.showfooterbutton", true);
            component.set("v.disabled", false);
            component.set("v.ReqRecordtype",true);
        } else {
            component.set("v.showfooterbutton", false);
            component.set("v.disabled", true);
            component.set("v.ReqRecordtype",false);
        }
        component.set("v.SelectedmediaList", component.get(
            "v.mediaList")[rowIndex]);
        component.find('OpenOutreach').execute();
    }
})