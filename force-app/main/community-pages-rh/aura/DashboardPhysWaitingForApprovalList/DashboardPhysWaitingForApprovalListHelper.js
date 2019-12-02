/**
 * Created by Leonid Bartenev
 */
({
    getItem: function(component, hcpeId){
        var hcpeList = component.get('v.hcpeList');
        for(var i = 0; i < hcpeList.length; i++){
            if(hcpeList[i].data.Id === hcpeId) return hcpeList[i];
        }
        return null;
    }
})