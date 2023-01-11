// rr_community_js
// Author: Leonid Bartenev

//Community Service Module:
window.communityService = (function () {

    let isInitializedFlag = false;
    let executeValidParams = true;
    let isTCAcceptedFlag;
    let communityMode;
    let communityDelegateId;
    let communityURLPathPrefix;
    let isDelegate;
    let stickyBarEnabled = true;
    let stickyBarTop;
    let debugMode = false; //turn on/off output server stack traces in toast messages
    let showOnLoginMap;
    let showCurrentTourOnLogin;
    let alreadyShowedMap = {};
    let isNewSession;
    let language;
    let preventedCookies = [];
    let participantState;
    let baseUrl;
    let currentUserMode;
    let allUserModes;
    let showPastStudies;
    let subDomain;
    let messagesVisible;
    let trialMatchVisible;
    let eDiaryVisible;
    let currentCSSTheme = 'Community_CSS_Stub';
    let isDummy;
    let sponsorName;
    let isMobileApp;
    let hasIQVIAStudiesPI;
    let communityName;
    let participantData;
    const pagesWithSharedPrivacyPolicy = new Set(['my-team','new-team-member','account-settings'])

    //community service functions:
    let service = {
        initialize: function (component) {
            if(service.isInitialized()) return;
            service.executeAction(component, 'getCommunityData', null, function (returnValue) {
                let communityData = JSON.parse(returnValue);
                preventedCookies = communityData.preventedCookies;
                isDummy = communityData.isDummy;
                if(!isDummy) {
                    service.deleteCookies(preventedCookies);
                    console.log('preventedCookies: ' + JSON.stringify(preventedCookies));
                }
                subDomain = communityData.subDomain;
                communityMode = isDummy ? 'PI' : communityData.communityMode;
                communityDelegateId = communityData.communityDelegateId;
                isDelegate = communityData.isDelegate;
                communityURLPathPrefix = communityData.pathPrefix;
                isTCAcceptedFlag = communityData.isTCAccepted;
                messagesVisible = communityData.messagesVisible;
                trialMatchVisible = communityData.trialMatchVisible;
                eDiaryVisible = communityData.eDiaryVisible;
                language = communityData.language;
                participantState = communityData.state;
                participantData = communityData.participantData;
                baseUrl = communityData.baseUrl;
                isInitializedFlag = true;
                allUserModes = communityData.allUserModes;
                showPastStudies = communityData.showPastStudies;
                sponsorName = communityData.sponsorName;
                isMobileApp = communityData.isMobileApp;
                hasIQVIAStudiesPI = communityData.hasIQVIAStudiesPI;
                communityName=communityData.communityName;
                service.setCurrentCommunityMode(communityData.currentUserMode, null, true);
                service.setCookie('RRLanguage', communityData.language, 365);
                console.log('CommunityService initialized:');
                console.log('is TC accepted: ' + isTCAcceptedFlag);
                console.log('URL path prefix: ' + communityURLPathPrefix);
                //console.log('isMobileApp: '+isMobileApp);
                component.init();
                if (!service.isTCAccepted() && service.getPageName() !== 'terms-and-conditions' && service.getPageName() !== 'privacy-policy' && service.getCurrentCommunityName() !=='IQVIA Patient Portal')  {
                    service.navigateToPage('terms-and-conditions?ret=' + service.createRetString());
                } else {
                    $A.get('e.c:EventCommunityInitialized').fire();
                }
            })
        },

        executeAction: function (component, actionName, params, successCallback, errorCallback, finalCallback) {
            service.logError(function () {
                let action = component.get('c.' + actionName);
                if (params) {
                    if (service.parametersHaveValidInputs(params)) {
                        if(executeValidParams ===  true){
                          service.showErrorToast('Error', $A.get('$Label.c.TST_JS_Injection_Error'));
                        }
                        if (errorCallback) errorCallback();
                        if (finalCallback) finalCallback();
                    }
                    action.setParams(params);
                }
                action.setCallback(this, function (response) {
                    try {
                        if (response.getState() === "SUCCESS") {
                            if (successCallback) successCallback(response.getReturnValue());
                        } else {
                            if (errorCallback) errorCallback(response);
                            let errMessage = service.getErrorMessage(response);
                            if (debugMode) errMessage = 'Action: ' + actionName + ', Error: ' + errMessage;
                            throw new Error(errMessage);
                        }
                    } catch (e) {
                        if(!isDummy) {
                            console.error(e);
                            let message = e.message;
                            if (!debugMode) message = e.message.split('\n')[0];
                            console.log('ERROR', message);
                            let exceptionHandler = component.find('exceptionHandler');
                            if(message.includes('INVALID_EMAIL_ADDRESS')) {
                                message = 'Invalid Email';
                            } else  {
                                if(message.includes('[LanguageLocaleKey]')) {
                                    message = 'This language is not yet supported';
                                } else {
                                    service.showErrorToast('ERROR', message);
                                }
                            }
                            exceptionHandler.execute(message);
                        }
                        //throw e;
                    } finally {
                        if (finalCallback) finalCallback();
                    }
                });
                $A.enqueueAction(action);
            })
        },

        deleteCookies: function (preventedCookies) {
            for (let i in preventedCookies) {
                let cookieDelete = preventedCookies[i] + "=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                console.log('cookieDelete: ' + cookieDelete);
                document.cookie = cookieDelete;

                cookieDelete = 'LSKey[c]' + cookieDelete;
                console.log('cookieDelete: ' + cookieDelete);
                document.cookie = cookieDelete;
            }
        },

        logError: function (loggedLogic) {
            try {
                loggedLogic();
            } catch (e) {
                console.error(e);
                if (debugMode) service.showErrorToast('Error', e.message);
            }
        },

        //Getters/setters:
        isShowPastStudies: function(){
            return showPastStudies;
        },

        getSubDomain: function(){
            return subDomain;
        },

        getTemplateProperty: function(propertyName){
            if(currentUserMode.template.properties) return currentUserMode.template.properties[propertyName];
            return null;
        },

        getCurrentCommunityMode: function(){
            return currentUserMode;
        },

        getCurrentSponsorName: function(){
            return sponsorName;
        },

        getHasIQVIAStudiesPI: function(){
            return hasIQVIAStudiesPI;
        },

        getPagesWithSharedPrivacyPolicy: function(){
            return pagesWithSharedPrivacyPolicy;
        },

        getCurrentCommunityName: function(){
            return currentUserMode.template.communityName;
        },

        getCommunityName: function () {
            return communityName;
        },

        getCurrentCommunityTemplateName: function(){
            return currentUserMode.template.templateName;
        },

        setCurrentCommunityMode: function(mode, page, init){
            currentUserMode = mode;
            let redirectURL = mode.template.redirectURL;
            if(page) redirectURL += '/s/' + page;
            if(!init && !isDummy && mode.template.needRedirect) document.location.href = redirectURL;
                service.setThemeCSS();
                  },

        getMessagesVisible : function () {
            return messagesVisible;
        },

        setMessagesVisible : function(visible) {
            messagesVisible = visible;
        },

        getTrialMatchVisible : function () {
            return trialMatchVisible;
        },

        setTrialMatchVisible : function(visible) {
            trialMatchVisible = visible;
        },
        
        getEDiaryVisible : function () {
            return eDiaryVisible;
        },

        setEDiaryVisible : function(visible) {
            eDiaryVisible = visible;
        },

        setThemeCSS: function(){
            if(isDummy) return;
            let cssLink = document.querySelector('link[href*="' + currentCSSTheme + '"]');
            try{
                currentCSSTheme = service.getTemplateProperty('ThemeCSS');
                if(cssLink) cssLink.setAttribute('href', currentCSSTheme);
            }catch (e) {
                console.log(e);
            }
        },

        getAllUserModes: function(){
            return allUserModes
        },

        getParticipantState: function(){
            return participantState;
        },
        getParticipantData: function(){
            return participantData;
        },

        getLanguage: function(){
            return language;
        },

        getBaseUrl: function() {
            return baseUrl;
        },
        
        isTCAccepted: function () {
            return isTCAcceptedFlag;
        },
        setTCAccepted: function () {
            isTCAcceptedFlag = true;
        },
        getUserMode: function () {
            return currentUserMode.userMode
        },
        getDelegateId: function () {
            return currentUserMode.currentHCPDelegate
        },
        isDelegate: function(){
            return isDelegate;
        },
        isDummy: function() {
            return isDummy;
        },
        getCommunityURLPathPrefix: function () {
            return communityURLPathPrefix
        },

        isInitialized: function () {
            if (isInitializedFlag) {
                if (isDummy || communityMode !== null) {
                    return true;
                } else {
                    service.navigateToPage('no-data-to-display');
                }
            }
            return false;
        },

        getFullPageName: function () {
            if (document.location.href.slice(-1) === '/') return '';
            let urlParts = document.location.href.split('/');
            if (urlParts.length > 0) return urlParts[urlParts.length - 1];
        },

        getUrlParameter: function (sParam) {
            let sPageURL = document.location.search.substring(1),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? '' : sParameterName[1];
                }
            }
        },

        replaceUrlParameter: function (sParam, value) {
            let urlWithoutParams = document.location.href.split('?')[0];
            let sPageURL = document.location.search.substring(1),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;
            let resURL = urlWithoutParams + '?';
            let params = [];
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');
                if (sParameterName[0] === sParam) {
                    params.push(sParameterName[0] + '=' + value);
                } else {
                    params.push(sURLVariables[i])
                }
            }
            return resURL + params.join('&');
        },

        getPageName: function () {
            let fullPageName = service.getFullPageName();
            let nameParts = fullPageName.split('?');
            return nameParts[0];
        },

        navigateToPage: function (pageName) {
            if(isDummy) return;
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                url: '/' + pageName
            });
            console.log('Navigate to page: ' + pageName);
            urlEvent.fire();
        },

        navigateToHome: function () {
            service.navigateToPage('');
        },

        redirectToPage: function (pageName) {
            console.log('Redirect to page: ' + pageName);
            document.location.href = communityURLPathPrefix + '/' + pageName;
        },

        createRetString: function () {
            return encodeURIComponent(service.getFullPageName());
        },

        getRetPage: function (retString) {
            return decodeURIComponent(retString);
        },

        getErrorMessage: function (response) {
            let errorMsg = 'Unknown error';
            let errors = response.getError();
            if (errors && errors[0] && errors[0].message) errorMsg = errors[0].message;
            return errorMsg;
        },

        logErrorFromResponse: function (response) {
            if (response.getState() === 'ERROR') {
                console.log('Aura Response Error: ' + service.getErrorMessage(response));
            }
        },

        showToast: function (title, type, message, duration) {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                duration: duration ? duration : undefined,
                mode: duration ? 'dismissible' : 'sticky'
            });
            toastEvent.fire();
        },

        showErrorToast: function (title, errorMessage, duration) {
            service.showToast(title, "error", errorMessage, duration);
        },

        showSuccessToast: function (title, message, duration) {
            service.showToast(title, 'success', message, duration);
        },

        showWarningToast: function (title, message, duration) {
            service.showToast(title, 'warning', message, duration);
        },

        showInfoToast: function (title, message, duration) {
            service.showToast(title, 'info', message, duration);
        },

        showErrorToastFromResponse: function (response) {
            service.showErrorToast('Error', service.getErrorMessage(response));
        },

        showTour: function (tourName) {
            let event = $A.get('e.c:OnboargingSlideTourShow');
            event.fire();
            alreadyShowedMap[communityMode] = true;
        },

        isTourAlreadyShowed: function () {
            return alreadyShowedMap[communityMode];
        },

        setShowOnLoginMap: function (showMap) {
            //todo remove
        },

        setShowOnLogin: function (showOnLigin) {
            showCurrentTourOnLogin = showOnLigin;
        },

        showTourOnLogin: function () {
            return showCurrentTourOnLogin;
        },

        getShowOnLoginMap: function () {
            return showOnLoginMap;
        },

        setIsNewSession: function (isNew) {
            isNewSession = isNew;
        },

        isNewSession: function () {
            return isNewSession;
        },

        setStickyBarPosition: function () {
            setTimeout(
                function () {
                    let mainBarHeight = 50;
                    if (allUserModes.length > 1 && window.innerWidth <= 550) mainBarHeight = 80;
                    document.getElementById('stickyBar').classList.remove('sticky');
                    let stickyBar = document.getElementById('stickyPositionTarget');
                    stickyBarTop = stickyBar.offsetTop - mainBarHeight;
                }, 100
            )
        },

        getCookie: function (cname) {
            console.log('in getCookie function');
            console.log('cname: ' + cname);

            if (!preventedCookies || preventedCookies.indexOf(cname) !== -1) {
                console.log(cname + ' cookie ignored get');
                return "";
            }

            let name = cname + "=";
            let decodedCookie = decodeURIComponent(document.cookie);
            let ca = decodedCookie.split(';');
            for (let i = 0; i < ca.length; i++) {
                let c = ca[i];
                while (c.charAt(0) === ' ') {
                    c = c.substring(1);
                }
                if (c.indexOf(name) === 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return "";
        },

        setCookie: function (cname, cvalue, exdays) {
            console.log('in setCookie function');
            console.log('cname: ' + cname);
            console.log('cvalue: ' + cvalue);

            if (preventedCookies && preventedCookies.indexOf(cname) !== -1) {
                console.log(cname + ' cookie ignored set');
                return;
            }

            let d = new Date();
            d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
            let expires = "expires=" + d.toUTCString();
            document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
        },

        isValidEmail: function (email) {
            let re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            return re.test(String(email).toLowerCase());
        },

        scrollToStickyBar: function () {
            window.scroll({
                top: stickyBarTop,
                behavior: "smooth"
            });
        },

        scrollToTop: function (noSmooth) {
            let params = {
                top: 0
            };
            if (!noSmooth) params.behavior = 'smooth';
            window.scroll(params);
        },

        scrollInto: function (tag) {
            document.getElementById(tag).scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        },

        stickyBarOnScrollHandler: function () {
            let stickyBar = document.getElementById('stickyBar');
            if (stickyBarTop) {
                if (window.pageYOffset >= stickyBarTop) {
                    stickyBar.classList.add('sticky');
                } else {
                    stickyBar.classList.remove('sticky');
                }
            }
        },

        logOut: function () {
            window.location.replace(baseUrl + '/secur/logout.jsp');
        },

        parametersHaveValidInputs: function (params) {
            let paramsJSON = JSON.stringify(params);
            let re = /javascript|<.*>/gm;
            return re.test(String(paramsJSON).toLowerCase());
        },

        parametersEscapeHTML: function (params) {
            let paramsJSON = JSON.stringify(params);
            paramsJSON = paramsJSON.replace(/</g, "&lt;").replace(/>/g, "&gt;");
            return JSON.parse(paramsJSON);
        },
        //depricated - use isMobileSDK
        isCurrentSessionMobileApp: function() {
            return isMobileApp;
        },

        isMobileSDK: function() {
            if(/SalesforceMobileSDK/.test( navigator.userAgent)) { 
                return true;
            }
            return false;
        },

        isMobileOS: function() {
            if(/android|iphone|ipad|ipod/i.test(navigator.userAgent.toLowerCase()) ) {
                return true;
            } 
            return false;
        },

        preLoginPageRedirection: function(currentUrl, redirectPage){
            let urlEvent = $A.get('e.force:navigateToURL');
            let redirectUrl = '';
            if (currentUrl.includes('janssen')) {
                redirectUrl = window.location.origin + '/janssen/s/' + redirectPage;
            } else if (currentUrl.includes('gsk')) {
                redirectUrl =  window.location.origin + '/gsk/s/' + redirectPage;
            } else if (currentUrl.includes('Covid19')) {
                redirectUrl =  window.location.origin + '/Covid19/s/' + redirectPage;
            } else {
                redirectUrl =  window.location.origin + '/s/' + redirectPage;
            }
            urlEvent.setParams({
                url: redirectUrl
            });
            urlEvent.fire();
        }
    };

    window.onscroll = function () {
        if (stickyBarEnabled) service.stickyBarOnScrollHandler();
    };

    return service;

}());

console.log('RR Community JS loaded');