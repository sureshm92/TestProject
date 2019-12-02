/**
 * Created by Leonid Bartenev
 */
({
    render: function(component, helper){
        var data = component.get('v.data');
        var cmpClass = component.get('v.class');
        var cmpRoot = communityService.createElement('div');
        if(cmpClass) cmpRoot.setAttribute('class', cmpClass);
        if(data) {
            cmpRoot.innerHTML = window.atob(data);
        }else{
            cmpRoot.innerHTML = '<div style="height: 400px; background: gray; color: white">TEST</div>'
        }
        return cmpRoot;
    },

    rerender: function(component, helper){
        var data = component.get('v.data');
        var cmpClass = component.get('v.class');
        var cmpRoot = communityService.createElement('div');
        if(cmpClass) cmpRoot.setAttribute('class', cmpClass);
        if(data) {
            cmpRoot.innerHTML = window.atob(data);
        }else{
            cmpRoot.innerHTML = '<div style="height: 400px; background: gray; color: white">TEST</div>'
        }
        return cmpRoot;
    }
})