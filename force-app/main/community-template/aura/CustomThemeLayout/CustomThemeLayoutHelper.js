/**
 * Created by Leonid Bartenev
 */
({
    init: function (component) {
        let isDummy = communityService.isDummy();
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isDummy', isDummy);
        if (!isDummy) {
            component.set('v.allModes', communityService.getAllUserModes());
            component.set(
                'v.showModeSwitcher',
                !(
                    communityService.getAllUserModes().length === 1 &&
                    communityService.getAllUserModes()[0].subModes.length <= 1
                )
            );
        }
        component.set('v.currentMode', communityService.getCurrentCommunityMode());
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
        component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
        component.set('v.template', communityService.getCurrentCommunityTemplateName());
        component.set('v.urlPathPrefix', communityService.getCommunityURLPathPrefix());
        component.set('v.communityName', communityService.getCurrentCommunityName());
        component.set('v.communityApiName', communityService.getCommunityName());

        /*communityService.executeAction(component, 'isCurrentSessionMobileApp', null,
            function (returnValue) {
                component.set('v.isMobileApp', returnValue);
            });*/
        component.set('v.isMobileApp', communityService.isMobileSDK());
        component.set('v.isInitialized', true);
    },
    connectCometd : function(component,event) {
        var helper = this;
        var cometd = new org.cometd.CometD();
        // Configure CometD
        var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/49.0/';
        cometd.configure({
          url: cometdUrl,
          requestHeaders: { Authorization: 'OAuth '+ component.get('v.sessionId')},
          appendMessageTypeToURL : false
        });
        cometd.websocketEnabled = false;
        // Establish CometD connection
        cometd.handshake(function(handshakeReply) {
          if (handshakeReply.successful) {
            cometd.subscribe('/event/bellNotification__e', function(message) {
                var msg = message.data.payload;
                if (message.data.payload.ContactId__c == component.get("v.contactId")){
                    helper.getSendResult(component,event);
                }

            });
          }
          else
            console.error('Failed to connected to CometD.');
        });
      //  $A.enqueueAction(action);

	},

    getSendResult: function(component,event){
        let notificationData;
        var action = component.get('c.getSendResults');
        var isExecuteSession = sessionStorage.getItem('isExecute');
        action.setParams({ contactId: component.get("v.contactId"), isExecute : isExecuteSession});
        sessionStorage.setItem('isExecute', 'false');
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS'){
                var res = response.getReturnValue();
                if(res != null){
                var numberOfUnreadNotifications = 0;
                for (var i = 0; i < res.allSendResult.length; i++) {
                    if (!res.allSendResult[i].Is_Read__c) {
                        numberOfUnreadNotifications++;
                    }

                    if(res.allSendResult[i].Push_Message_Body__c.includes('URL')){
                        var tempBody = res.allSendResult[i].Push_Message_Body__c.split('{')[0];
                        var tempData = res.allSendResult[i];
                        tempData.Push_Message_Body__c = tempBody;
                        res.allSendResult[i] = tempData;
                    }
                }
                component.set("v.allNotificationData", res.allSendResult);
                notificationData = res.allSendResult.splice(0, 5);
                component.set("v.sendResultsData", notificationData);

                if (numberOfUnreadNotifications >= 0 && numberOfUnreadNotifications <= 99) {
                    component.set("v.unreadNotificationsCount", numberOfUnreadNotifications);
                    component.set("v.unreadNotifyCount", numberOfUnreadNotifications);
                 } else if(numberOfUnreadNotifications > 99 ){
                    let count;
                    count = "99+" ;
                    component.set("v.unreadNotificationsCount", count);
                    component.set("v.unreadNotifyCount", numberOfUnreadNotifications);
                 }
                }
            }else{
                console.error(response);
            }
        });
        $A.enqueueAction(action);

    },

    loadMoreNotifications: function(component){

        let sendResultLength = component.get('v.sendResultsData').length;
        let newLength = component.get('v.sendResultsData').length + 5;
        if (newLength > ((component.get('v.allNotificationData').length))) {
          newLength = component.get('v.allNotificationData').length;
        }
        let data = component.get('v.allNotificationData').slice(sendResultLength,newLength);
        let sendResult = component.get('v.sendResultsData').concat(data);
        component.set("v.sendResultsData", sendResult);
      //  component.set("v.isSaving", false);
      },


      updateReadtoUnRead : function(component, index){
        var action = component.get('c.updateReadNotification');
        action.setParams({ sendResultId: component.get("v.unreadSendResultId")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {
                var sendResultList = JSON.parse(JSON.stringify(component.get('v.sendResultsData')));
                var tempNotificationData = sendResultList[index];
                tempNotificationData.Is_Read__c = result.Is_Read__c;
                sendResultList[index] = tempNotificationData;
                component.set('v.sendResultsData',sendResultList);

                let count = component.get('v.unreadNotifyCount');
                if(result.Is_Read__c == true){
                  count-- ;
                }
                if (count >= 0 && count <= 99) {
                            component.set("v.unreadNotificationsCount", count);
                            component.set("v.unreadNotifyCount", count);
                } else if(count > 99 ){
                           let numberOfUnreadNotifications = "99+" ;
                            component.set("v.unreadNotificationsCount", numberOfUnreadNotifications);
                            component.set("v.unreadNotifyCount", count);
                }

            } else if (state === 'ERROR') {
                var errors = response.getError();
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
      },

      removeSendResult: function(component, index){

        var allSendResult = component.get("v.allNotificationData");
        allSendResult.splice(index, 1);
        component.set("v.allNotificationData", allSendResult);

        var sendResult = component.get("v.sendResultsData");
        let count = component.get('v.unreadNotifyCount');
        var closesSndResultList = JSON.parse(JSON.stringify(sendResult));
        var removeNotifyData = closesSndResultList[index];
        if((removeNotifyData.Is_Read__c == false)){
            count-- ;
          }
          component.set("v.isDeleted", false);
          if (count >= 0 && count <= 99) {
              component.set("v.unreadNotificationsCount", count);
              component.set("v.unreadNotifyCount", count);
          } else if(count > 99 ){
                  let numberOfUnreadNotifications = "99+" ;
                      component.set("v.unreadNotificationsCount", numberOfUnreadNotifications);
                   component.set("v.unreadNotifyCount", count);
          }

        closesSndResultList.splice(index, 1);
        component.set("v.sendResultsData", closesSndResultList);

        let sendResultIndex = component.get('v.sendResultsData').length;
        let newIndex = sendResultIndex+1;
        let data = component.get('v.allNotificationData').slice(sendResultIndex,newIndex);
        let sendResultData = component.get('v.sendResultsData').concat(data);
        component.set("v.sendResultsData", sendResultData);

        var action = component.get('c.isActivate');
        action.setParams({ sendResultId: component.get("v.closeSendResultId")});
        action.setCallback(this, function(response) {
          //  var resultData = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {


            } else if (state === 'ERROR') {
                var errors = response.getError();
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);

      }
});