/**
 * Created by Leonid Bartenev
 */
({
    getModeLabel: function (mode) {
        if(mode === 'PI'){
            return $A.get("$Label.c.CTL_L_PI_MODE");
        }else if(mode === 'HCP'){
            return $A.get("$Label.c.CTL_L_HCP_MODE");
        }else{
            return $A.get("$Label.c.CTL_L_Patricipant_MODE")
        }
    },

    setAvailableModes : function(component){
        component.set('v.isInitialized', true);
        component.set('v.mode', communityService.getUserMode());
        var modes = communityService.getCommunityTypes();
        var resModes = [];
        for(var i = 0; i< modes.length; i++){
            resModes.push({
                label: this.getModeLabel(modes[i]),
                value: modes[i]
            })
        }
        component.set('v.availableModes', resModes);
    }

})