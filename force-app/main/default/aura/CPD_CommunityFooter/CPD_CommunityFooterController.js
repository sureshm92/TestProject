({
    doInit :  function(component, event, helper){
        component.set('v.isArabic',true);
    },
    clicktoRedirect : function(component, event, helper) {
        event.preventDefault();
        var name = event.currentTarget.name;
        if(name === 'privacy')  helper.pageNavigate(event,'https://c19trials.com/#!/PrivacyPolicy');
        if(name === 'terms')  helper.pageNavigate(event,'https://c19trials.com/#!/TermsOfUse');
    },
    
})