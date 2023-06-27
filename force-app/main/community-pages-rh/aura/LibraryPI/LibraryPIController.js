({
    doInit: function (component, event, helper) {
        component.find('mainSpinner').show();
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(
            component,
            'getInitData',
            {
                isDelegate: isDelegate,
                language: null,
                Searchstr: null,
                communityTemplate: communityService.getCurrentCommunityTemplateName()
            },
            function (response) {
                component.set('v.resourceStructureList', response.resources);
                component.set('v.resourceLanguages', response.languages);
                component.set('v.OrgDomainUrl', response.OrgBaseurl);
                component.find('mainSpinner').hide();
            }
        );
    },

    doNavigate: function (component, event, helper) {
        var resourceInd = event.currentTarget.getAttribute('data-attributeVal').split(',');
        var resource = component.get('v.resourceStructureList')[resourceInd[0]].resources[
            resourceInd[1]
        ];
        if (resource.videoLink || resource.link) {
            var urlLink = resource.format == 'Video' ? resource.videoLink : resource.link;
            window.open(urlLink);
        } else {
            // This change is made to open the study document (under library section) in new window for mobile browsers
            var device = $A.get("$Browser.formFactor");
            if (device=='PHONE' && resource.recordTypeDevName=='Study_Document') {
                component.find('mainSpinner').show();
                try{
                    communityService.executeAction(component, 'getBase64Resource', {
                        resourceId:resource.resourceId,
                        language: null 
                    },
                    function (returnValue) {         
                        let urlEvent = $A.get('e.force:navigateToURL');            
                        let byteCharacters = atob(returnValue);
                        let byteNumbers = new Array(byteCharacters.length);
                        for (let i = 0; i < byteCharacters.length; i++) {
                            byteNumbers[i] = byteCharacters.charCodeAt(i); 
                        }
                        let ieEDGE = navigator.userAgent.match(/Edge/g);
                        let ie = navigator.userAgent.match(/.NET/g);
                        let oldIE = navigator.userAgent.match(/MSIE/g);
                        let bytes = new Uint8Array(byteNumbers); //use this if data is raw bytes else directly pass resData
                        let blob = new window.Blob([bytes], {type : 'application/pdf'});
                        let absoluteURL = window.location.origin;
                           if (ie || oldIE || ieEDGE) {
                            window.navigator.msSaveBlob(blob, fileName + '.pdf');
                        } else {
                            let fileURL = URL.createObjectURL(blob);                           
                            let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
                            urlEvent.setParams({
                                url:
                                absoluteURL +
                                urlViewer +
                                '?file=' +
                                fileURL +
                                '&fileName=' +
                                encodeURIComponent(resource.Title__c)
                            });
                            urlEvent.fire();
                        }   
                        component.find('mainSpinner').hide();               
          			});     
                }catch(e)
                {
                    throw new AuraHandledException('Something went wrong: '  + e.getMessage());  
                }
            }else{ 
				var url =
					'resources?resourceType=' +
					resource.recordTypeDevName +
					'&resId=' +
					resource.resourceId;
				url += '&ret=' + communityService.createRetString();
				communityService.navigateToPage(url);
			}
		}
		
    },
    filterLanguage: function (component, event, helper) {
        component.find('mainSpinner').show();
        var srchtxt = component.get('v.searchstring');
        if (srchtxt == '' || srchtxt == ' ' || srchtxt == '  ') {
            srchtxt = null;
        }
        component.set('v.langSelected', event.getSource().get('v.itemValue'));
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(
            component,
            'getInitData',
            {
                isDelegate: isDelegate,
                language: event.getSource().get('v.itemValue'),
                Searchstr: srchtxt,
                communityTemplate: communityService.getCurrentCommunityTemplateName()
            },
            function (response) {
                component.set('v.resourceStructureList', response.resources);
                component.find('mainSpinner').hide();
            }
        );
    },

    doSearch: function (component, event, helper) {
        var srchtxt = component.get('v.searchstring');
        var lang = component.get('v.langSelected');
        if (lang == '' || lang == ' ' || lang == '  ') {
            lang = null;
        }
        if (srchtxt == '' || srchtxt == ' ' || srchtxt == '  ') {
            srchtxt = null;
        }
        var isDelegate = communityService.isDelegate() ? true : false;
        communityService.executeAction(
            component,
            'getInitData',
            {
                isDelegate: isDelegate,
                language: lang,
                Searchstr: srchtxt,
                communityTemplate: communityService.getCurrentCommunityTemplateName()
            },
            function (response) {
                component.set('v.resourceStructureList', response.resources);
            }
        );
    },

    downloadResource: function (component, event, helper) {
        var resourceInd = event.currentTarget.getAttribute('data-attributeVal').split(',');
        var resource = component.get('v.resourceStructureList')[resourceInd[0]].resources[
            resourceInd[1]
        ];
        var x;

        var y;

        var z;

        var d = component.get('v.OrgDomainUrl');

        x = d.indexOf('.com');

        x = x + 4;

        y = d.indexOf('=');

        y = y + 1;

        z = d.substring(y, x);

        var BaseUrl = z;
        if (resource.recordTypeDevName == 'Study_Document'){
            var strUrlParam = window.location.href;
            if (strUrlParam.includes('janssen'))
                var urls =
                    window.location.origin +
                    '/janssen' +
                    '/sfc/servlet.shepherd/document/download/' +
                    resource.fileID;
            else if (!strUrlParam.includes('janssen'))
                var urls =
                    window.location.origin +
                    '/sfc/servlet.shepherd/document/download/' +
                    resource.fileID;

            //  var urls = BaseUrl+'/sfc/servlet.shepherd/document/download/'+resource.fileID;
            let urlEvent = $A.get('e.force:navigateToURL');
            urlEvent.setParams({ url: urls });
            urlEvent.fire();
        }
    },

    handleSectionToggle: function (cmp, event, helper) {
        var openSections = event.getParam('openSections');
        if (openSections.length === 0) {
            cmp.set('v.sectionOpen', true);
        }
        //else{
        //cmp.set('v.sectionOpen', true);        }
    }
});