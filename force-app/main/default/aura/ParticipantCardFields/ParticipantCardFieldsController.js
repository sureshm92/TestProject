({
    openCard: function (component, event, helper) {
        var p = component.get("v.parent"),
            pse =component.get("v.parentSE");
        
        if(p)
            p.preparePathItems();
        else if(pse)
            pse.showCard(); 
        
        component.set('v.viewMore',false);
    },
    
    viewMore: function (component, event, helper) {
        component.set('v.viewMore',true);
    }
})