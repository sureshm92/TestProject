/**
 * Created by Leonid Bartenev
 */
({
    doDataChange: function (component, event, helper) {
        var dataList = component.get('v.dataList');
        var sum = 0;
        for(var i = 0; i < dataList.length; i++){
            sum += dataList[i].value;
        }
        component.set('v.total', sum);
    }
})