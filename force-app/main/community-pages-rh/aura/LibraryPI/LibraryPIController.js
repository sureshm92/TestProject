({
    doInit: function(component, event, helper) {
        component.find('mainSpinner').show();
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(component, 'getInitData', {
            isDelegate: isDelegate,
            language: null,
            Searchstr: null,
            communityTemplate: communityService.getCurrentCommunityTemplateName()
        }, function(response) {
            component.set('v.resourceStructureList', response.resources);
            component.set('v.resourceLanguages', response.languages);
            component.find('mainSpinner').hide();
        });
    },
    
    doNavigate: function(component, event, helper){
        var resourceInd = event.currentTarget.getAttribute('data-attributeVal').split(',');
        var resource = component.get('v.resourceStructureList')[resourceInd[0]].resources[resourceInd[1]];
        if(resource.videoLink || resource.link){
            var urlLink = resource.format == 'Video' ? resource.videoLink : resource.link;
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({url: urlLink});
            urlEvent.fire();    
        } else {
            var url = 'resources?resourceType=' + resource.recordTypeDevName + '&resId=' + resource.resourceId;
            url += '&ret=' + communityService.createRetString();
            communityService.navigateToPage(url);
        }
    },
    filterLanguage: function(component, event, helper) {
        component.find('mainSpinner').show();
        var srchtxt = component.get("v.searchstring");
        if (srchtxt == "" || srchtxt == " " || srchtxt == "  ") {
            srchtxt = null;
        }
        component.set("v.langSelected", event.getSource().get(
            'v.itemValue'));
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(component, 'getInitData', {
            isDelegate: isDelegate,
            language: event.getSource().get('v.itemValue'),
            Searchstr: srchtxt,
            communityTemplate: communityService.getCurrentCommunityTemplateName()
        }, function(response) {
            component.set('v.resourceStructureList', response.resources);
            component.find('mainSpinner').hide();
        });
    },
    
    doSearch: function(component, event, helper) {
        var srchtxt = component.get("v.searchstring");
        var lang = component.get("v.langSelected");
        if (lang == "" || lang == " " || lang == "  ") {
            lang = null;
        }
        if (srchtxt == "" || srchtxt == " " || srchtxt == "  ") {
            srchtxt = null;
        }
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(component, 'getInitData', {
            isDelegate: isDelegate,
            language: lang,
            Searchstr: srchtxt
        }, function(response) {
            component.set('v.resourceStructureList', response.resources);
        });
    },
    
    downloadResource: function(component, event, helper){
        var resourceInd = event.currentTarget.getAttribute('data-attributeVal').split(',');
        var resource = component.get('v.resourceStructureList')[resourceInd[0]].resources[resourceInd[1]];
        if(resource.format=='Study Document'){
            var urls = window.location.origin+'/sfc/servlet.shepherd/document/download/'+resource.fileID;            
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({url: urls});
            urlEvent.fire();    
        }
    },
    
    handleSectionToggle: function ( cmp, event,helper) {            
        var openSections = event.getParam('openSections');        
        if ( openSections.length === 0 ) {
            cmp.set('v.sectionOpen',true );
        }
        //else{
        //cmp.set('v.sectionOpen', true);        }
    },  
    
    
})