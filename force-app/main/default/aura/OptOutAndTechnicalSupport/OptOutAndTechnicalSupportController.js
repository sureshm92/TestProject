({
	doInit : function(component, event, helper) {
        var language=communityService.getUrlParameter('language');
        if(!language || language===''){
            language='en_US';
        }
        communityService.executeAction(component, 'getInitData', {
                strLanguage: language
            },
            function (retValue) {
                for(let item of retValue){
                    if(item.strCategoryValue==='Opt Out of communication by IQVIA and its affiliates'){
                        component.set("v.optOutTranslatedTitle",item.strTranslatedCategoryValue);
                        component.set("v.optOutSubCategoryList",item.labelValueItemList);
                    }
                    else if(item.strCategoryValue==='Get Technical Support'){
                        component.set("v.techSupportTranslatedTitle",item.strTranslatedCategoryValue);
                        component.set("v.techSupportSubCategoryList",item.labelValueItemList);
                    }
                }
            }                          
        );
	},
    handleChange:function(component,event,helper){
        var selectedOptOutSubCategory=component.get("v.selectedOptOutSubCategory");
        var selectedTechSupportSubCategory=component.get("v.selectedTechSupportSubCategory");
        if((selectedOptOutSubCategory && selectedOptOutSubCategory.length>0) || (selectedTechSupportSubCategory && selectedTechSupportSubCategory.length>0)){
            component.set("v.disabled",false);
        }
        else{
            component.set("v.disabled",true);
        }
    },
    handleSubmit:function(component,event,helper){
        var recipientId=communityService.getUrlParameter('recipientId');
        component.set("v.showSpinner",true);
        communityService.executeAction(component, 'createSupportCases', {
                optOutValueList:  component.get("v.selectedOptOutSubCategory"),
            	techSupportValueList: component.get("v.selectedTechSupportSubCategory"),
            	strContactId:recipientId
            },
            function () {
                component.set("v.showSpinner",false);
                component.set("v.showSuccessMessage",true);
            },
            function(){
                component.set("v.showSpinner",false);
            }                           
        );
        
    }
   
})