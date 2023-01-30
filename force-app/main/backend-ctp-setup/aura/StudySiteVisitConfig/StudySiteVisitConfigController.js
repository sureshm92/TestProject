/**
 * Created by Igor Malyuta on 18.09.2019.
 */

({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        var options = [];
        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_PE_AND_STUDY_SITE"), 'value': 'option1'});
        options.push({'label':' ' + $A.get("$Label.c.ASSOCIATE_VISIT_PLAN_TO_STUDY_SITE_ONLY"), 'value': 'option2'});
        component.set('v.options',options);
        communityService.executeAction(
            component,
            'getInitData',
            {
                ctpId: component.get('v.recordId')
            },
            function (initData) {
                component.set('v.filter', initData.filter);
                component.set('v.viewModePage', initData.viewMode);
                helper.setSearchResponse(component, initData.searchResponse);
                component.set('v.initialized', true);
                component.set('v.studySiteVisitPlan' ,initData.studySiteVisitPlan);
            }
        );
    },

    doUpdate: function (component, event, helper) {
        helper.updateItems(component);
    },

    doSaveAndUpdate: function (component, event, helper) {
        helper.updateItems(component, true);
    },

    onCountriesChange: function (component, event, helper) {
        component.set('v.filter.selectedSSIds', '');
        helper.updateItems(component);
    },

    doSort: function (component, event, helper) {
        helper.updateItems(component);
    },

    doAddVP: function (component, event, helper) {
        component.find('actionVP').execute(
            null,
            function (vpId) {
                let vpIds = component.get('v.filter.pageFeatureIds');
                if (vpIds) vpIds += ';' + vpId;
                component.set('v.filter.pageFeatureIds', vpIds);
                helper.updateItems(component);
            },
            'create'
        );
    },

    //Visit Plan column actions: ---------------------------------------------------------------------------------------
    columnCheckboxStateChange: function (component, event, helper) {
        let vpId = event.target.dataset.vp;
        let state = event.target.dataset.state === 'Enabled';
        component.set('v.vpId',vpId);
        component.set('v.state',state);
        var ssItems = component.get('v.ssItems');
        var ssIds = [];
        var ssIdsToLock = [];
        if(ssItems!=undefined && ssItems!=null){
            for(let i=0; i<ssItems.length; i++){
                if(ssItems[i].emptyAssignments == true){
                    ssIds.push(ssItems[i].ss.Id);
                }
            }
        }
        if(state){
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'totalPEs',
                {
                    ctpId: component.get('v.recordId'),
                    filterJSON:JSON.stringify(component.get('v.filter'))
                },
                function (response) {                  
                    if(response !=undefined && response.count >0){
                        component.find('spinner').hide();  
                        component.set('v.isModalOpen',true);
                        if(response.limitReached == true){
                            component.set('v.popupMessage',$A.get("$Label.c.TOTAL_PE_WITHOUT_VP_LIMIT").replace('##PEs',response.count));
                        }else{
                            component.set('v.popupMessage',$A.get("$Label.c.TOTAL_PE_WITHOUT_VP").replace('##PEs',response.count));
                        }
                        var cmpTarget = component.find('PopupModal');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open');                        
                    }else{
                        communityService.executeAction(
                            component,
                            'setVisitPlanForAll',
                            {
                                visitPlanId: vpId,
                                state: state,
                                filterJSON: JSON.stringify(component.get('v.filter')),
                                paginationJSON: JSON.stringify(component.get('v.pagination')),
                                ssItemsJSON: JSON.stringify(component.get('v.ssItems')),
                                studySiteVisitPlanJSON: undefined,
                                ctpId: component.get('v.recordId'),
                                ssIdsWithoutChangetoVisitPlan: undefined,
                                runBatch: false
                            },
                            function (searchResponse) {
                                helper.setSearchResponse(component, searchResponse);
                            }
                        );                        
                    }
                }
            );
        }else if(!state){
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'getLatestBatchStatusForStudy',
                {
                    filterJSON: JSON.stringify(component.get('v.filter')),
                    ctpId: component.get('v.recordId')
                },
                function (response) {
                    ssIdsToLock = response;
                    if(typeof ssIdsToLock != "undefined"
                       && ssIdsToLock != null
                       && ssIdsToLock.length != null
                       && ssIdsToLock.length > 0){
                        component.set('v.isNotificationModalOpen',true);
                        var cmpTarget = component.find('NotificationPopupModal');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open');  			
                        
                    }
                    communityService.executeAction(
                        component,
                        'setVisitPlanForAll',
                        {
                            visitPlanId: vpId,
                            state: state,
                            filterJSON: JSON.stringify(component.get('v.filter')),
                            paginationJSON: JSON.stringify(component.get('v.pagination')),
                            ssItemsJSON: JSON.stringify(component.get('v.ssItems')),
                            studySiteVisitPlanJSON: undefined,
                            ctpId: component.get('v.recordId'),
                            ssIdsWithoutChangetoVisitPlan: ssIdsToLock,
                            runBatch: false
                        },
                        function (searchResponse) {
                            helper.setSearchResponse(component, searchResponse);
                        }
                    );

                }
            );
            
            
        }else{
            component.find('spinner').show();
            communityService.executeAction(
                component,
                'setVisitPlanForAll',
                {
                    visitPlanId: vpId,
                    state: state,
                    filterJSON: JSON.stringify(component.get('v.filter')),
                    paginationJSON: JSON.stringify(component.get('v.pagination')),
                    ssItemsJSON: JSON.stringify(component.get('v.ssItems')),
                    studySiteVisitPlanJSON: undefined,
                    ctpId: component.get('v.recordId'),
                    ssIdsWithoutChangetoVisitPlan: undefined,
                    runBatch: false
                },
                function (searchResponse) {
                    helper.setSearchResponse(component, searchResponse);
                }
            );

        }
    },
	
    exitNotificationModal: function (component, event, helper) {
        var cmpTarget = component.find('NotificationPopupModal');
        $A.util.removeClass(cmpTarget, 'slds-backdrop--open');  
        component.set('v.isNotificationModalOpen',false);
    },
    
    saveModal: function (component, event, helper) {
        component.find('spinner').show();
        var cmpTarget = component.find('PopupModal');
        $A.util.removeClass(cmpTarget,'slds-backdrop--open');
        component.set('v.isModalOpen',false);
        var vpId = component.get('v.vpId');
        var state = component.get('v.state');
        var c = component.find("currentItemOptions");
        let studySiteVisitPlan = {};
        if(component.get('v.optionselected')=='option1'){
            var ssItems = component.get('v.ssItems');
            var ssIds = [];
            if(ssItems!=undefined && ssItems!=null){
                for(let i=0; i<ssItems.length; i++){
                    if(ssItems[i].emptyAssignments == true){
                        let ssId = ssItems[i].ss.Id;
                            studySiteVisitPlan[ssItems[i].ss.Id]=component.get('v.vpId');
                        
                    }
                }
            }
        }else if(component.get('v.optionselected')=='option2'){
            studySiteVisitPlan = {};
        }
        component.set('v.enableOKButton',false);
        communityService.executeAction(
            component,
            'setVisitPlanForAll',
            {
                visitPlanId: vpId,
                state: state,
                filterJSON: JSON.stringify(component.get('v.filter')),
                paginationJSON: JSON.stringify(component.get('v.pagination')),
                ssItemsJSON: JSON.stringify(component.get('v.ssItems')),
                studySiteVisitPlanJSON: JSON.stringify(studySiteVisitPlan),
                ctpId: component.get('v.recordId'),
                ssIdsWithoutChangetoVisitPlan: undefined,
                runBatch: component.get('v.optionselected')=='option1'
            },
            function (searchResponse) {
                helper.setSearchResponse(component, searchResponse);
            }
        );
    },

    cancelModal: function (component, event, helper) {
        var cmpTarget = component.find('PopupModal');
        $A.util.removeClass(cmpTarget,'slds-backdrop--open');
		component.set('v.isModalOpen',false);
        var visitPlan = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        component.set('v.enableOKButton',false);
    },    
    
    selectButton: function (component, event, helper) {
        component.set('v.enableOKButton',true);
        var checked = event.getSource().get("v.value");
        var option = event.getParam("value");
        component.set('v.optionselected',option);
    },    

    doColumnVisitEdit: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(
            menuCmp.get('v.plan').value,
            function () {
                helper.updateItems(component);
            },
            'edit'
        );
    },

    doColumnVisitView: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(
            menuCmp.get('v.plan').value,
            function () {
                helper.updateItems(component);
            },
            'view'
        );
    },

    doColumnVisitClone: function (component, event, helper) {
        let menuCmp = event.getSource();
        component.find('actionVP').execute(
            menuCmp.get('v.plan').value,
            function () {
                helper.updateItems(component);
            },
            'clone'
        );
    },

    doColumnVisitDelete: function (component, event, helper) {
        let menuCmp = event.getSource();
        let planId = menuCmp.get('v.plan').value;
        let vpIds = component.get('v.filter.pageFeatureIds');
        if (vpIds) {
            let items = vpIds.split(';');
            let resItems = [];
            for (let i = 0; i < items.length; i++) {
                if (items[i] !== planId) resItems.push(items[i]);
            }
            component.set('v.filter.pageFeatureIds', resItems.join(';'));
        }
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'deleteVisitPlan',
            {
                planId: planId,
                filterJSON: JSON.stringify(component.get('v.filter')),
                paginationJSON: JSON.stringify(component.get('v.pagination'))
            },
            function (searchResponse) {
                helper.setSearchResponse(component, searchResponse);
            }
        );
    },

    handleRecordUpdate: function(component, event, helper) {
        
    }
});