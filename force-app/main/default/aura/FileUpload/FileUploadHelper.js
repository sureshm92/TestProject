({
    openPopup : function(component){
        var isPopupOpen = component.get('v.isPopupOpen');
        component.set('v.isPopupOpen', !isPopupOpen);
    },
})