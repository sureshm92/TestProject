({
    doInit: function (component, event, helper){
        helper.radioGroupValues(component);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.todayDate", today);
    },

    validatequestion: function(component, event, helper){
        var isValidfield, isPositive;
        isValidfield = helper.validateField(component, event, 'dateofbirth') 
        isPositive = helper.isPositiveCovid(component, 'positive' )
        return isValidfield && isPositive;
    },    

    handleInputOnChange: function (component, event, helper) {
        helper.validateInputOnChange(component, event);
    },

    hanldeCalculateDOB: function (component, event, helper) {
        helper.calculateDOB(component, event);
        helper.validateInputOnChange(component, event);
    },

     radioInputChange : function (component, event, helper) {
        helper.radioInputChange(component, event);
        helper.validateInputOnChange(component, event);
    },

})