({
	doExecute : function(component, event, helper) {
		 component.set('v.showImport',true);
         var params = event.getParam('arguments');
         var studySiteId = params['studySiteId'];
         component.set('v.studySiteId', studySiteId);
         var studySiteType = params['studySiteType'];
         component.set('v.studySiteType', studySiteType);
         var trial = params['trial'];
         component.set('v.studyId', trial.Id); 
         console.log('siteid----'+component.get('v.studySiteId')+''+component.get('v.studyId'));
         console.log('trial---'+JSON.stringify(trial));
         communityService.executeAction(
                        component,
                        'getSite',
                        {
                            siteId: component.get('v.studySiteId')
                        },
                        function (returnValue) {
                            component.set('v.siteName', returnValue);
                            console.log('returnValue'+returnValue);
                        }
           );
	},
    handleImportParticipant : function(component, event, helper) {
		  component.set('v.showImport',false);
	}
})