({
    recordChange : function(component, event, helper)
    {
        component.set('v.siteRankWrapper', null);
        window.setTimeout
        (
              $A.getCallback(function() {
                helper.getSitesCount(component, event, helper);        
                helper.loadData(component, event, helper);
            }), 50
        );
  

    },
        
})