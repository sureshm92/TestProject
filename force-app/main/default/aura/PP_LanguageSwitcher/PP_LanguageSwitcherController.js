/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
       
        component.set('v.userMode', communityService.getUserMode());
        communityService.executeAction(component, 'getInitData',  null, function (returnValue) {
            let initData = JSON.parse(returnValue);
			
            
            component.set('v.languages', initData.languages);
			component.set('v.countries', initData.countries);
			component.set('v.statesByCountryMap', initData.statesByCountryMap);
            component.set('v.optionalLanguages', initData.optionalLanguages);
            component.set('v.locales',   initData.locales);
            component.set('v.timezones', initData.timezones);
			
            let personWrapper = component.get('v.personWrapper');                        
            //helper.setPersonSnapshot(component);
           
   
            console.log(initData.languages);
            setTimeout($A.getCallback(function () {
                component.set('v.languageKey',   initData.languageKey);
                component.set('v.secondLangKey', initData.secondLangKey);
                component.set('v.thirdLangKey',  initData.thirdLangKey);
                component.set('v.localeKey',     initData.localeKey);
                component.set('v.timezoneKey',   initData.timezoneKey);
				//sneha-added- on 6/6/2020
				component.set('v.countryKey',   initData.countryKey);                				
				var statesByCountryMap = component.get('v.statesByCountryMap');		
				var countryCode = component.get("v.countryKey");		
				component.set('v.states', statesByCountryMap[countryCode]);							 										
                component.set('v.initialized',   true);				
				component.set('v.personWrapper.zip',   personWrapper.zip);
            }), 50);
			
			setTimeout(
                $A.getCallback( function() {                    
					component.set('v.stateKey',   initData.stateKey);
                }), 100);
        })
    },

    doChangeLanguage: function(component){
		
        if(!component.get('v.initialized')) return;
        var languageKey   = component.get('v.languageKey');		
		var countryName, stateName, zipcode;
		//Sneha-Logic to fetch the Country Name through country code and pass it to the controller
		if(component.get('v.userMode') == 'Participant'){
			
			var tempcountries = component.get("v.countries"),		
			value = component.find("countryList").get("v.value"),		
			index = tempcountries.findIndex(item => item.value == value);	
			countryName = index >= 0? tempcountries[index].label: null;
			
			//Sneha-Logic to fetch the State Name through state code and pass it to the controller
			var tempstates = component.get("v.states"),
			statevalue = component.find("stateList").get("v.value"),		
			stateindex = tempstates.findIndex(item => item.value == statevalue);	
			stateName = stateindex >= 0? tempstates[stateindex].label: null;
			//if(component.get('v.personWrapper.zip')!=null)
			zipcode = component.get('v.personWrapper.zip');		
		}	
		
        var secondLangKey = component.get('v.secondLangKey');		
        var thirdLangKey  = component.get('v.thirdLangKey');
        var localeKey     = component.get('v.localeKey');
        var timezoneKey   = component.get('v.timezoneKey');
        component.find('spinner').show();
		
        communityService.executeAction(component, 'changeLanguage', {
            languageKey:   languageKey,
            secondLangKey: secondLangKey,
            thirdLangKey:  thirdLangKey,
            localeKey:     localeKey,
            timezoneKey:   timezoneKey,
			countryName:   countryName,
			stateName:	   stateName,
			zipcode:	   zipcode
        }, function () {
            location.reload()
        }, function () {
            component.find('spinner').hide();
        })
    },

    //Sneha-Method to fetch the corresponding states based on the country selected
	updateStates: function (component, event, helper){				
		var statesByCountryMap = component.get('v.statesByCountryMap');		
		var countryCode = component.get("v.countryKey");		
		component.set('v.states', statesByCountryMap[countryCode]);		
	}
    
    

})