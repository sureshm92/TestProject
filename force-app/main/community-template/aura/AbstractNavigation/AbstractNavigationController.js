/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
    },

    doChangeItemsList: function (component, event, helper) {
        try {
            //if(communityService.isInitialized()) return;
            helper.initItemsMap();
            var userMode = component.get('v.mode');
            var menuItems = helper.itemsMap[userMode];
            component.set('v.menuItems', menuItems);
            component.set('v.scrollRequired', false);
            component.set('v.scrollDirection', 'left');
            var scrollEnableCheckHandler = $A.getCallback(function () {
                var navMenuCmp = component.getConcreteComponent().find('navMenu');
                if (navMenuCmp) {
                    var navMenu = navMenuCmp.getElement();
                    component.set('v.scrollRequired', navMenu.scrollWidth > navMenu.clientWidth);
                }
            });
            setTimeout(scrollEnableCheckHandler, 300); 
            window.addEventListener('resize', scrollEnableCheckHandler);
            helper.updateCurrentPage(component);
        } catch (e) {
            console.error(e);
        }
    },

    doCurrentPageChange: function (component, event, helper) {
        helper.updateCurrentPage(component);
    },

    onClick: function (component, event, helper) {
        var pageName = event.currentTarget.dataset.pageName;
        helper.updateDocumentTitle(component, pageName);
        communityService.navigateToPage(pageName);
    },
    onClickResource: function (component, event, helper){
        var pageName = 'resources-pi';
        helper.updateDocumentTitle(component, pageName);
        communityService.navigateToPage('library');
    },

    doScroll: function (component, event, helper) {
        var direction = component.get('v.scrollDirection');
        var navMenuCmp = component.getConcreteComponent().find('navMenu');
        if (navMenuCmp) {
            var navMenu = navMenuCmp.getElement();
            var navMenuWidth = navMenu.getBoundingClientRect().width;
            try{
                if (direction === 'right') {
                    component.set('v.scrollDirection', 'left');
                    navMenu.scrollLeft = 0;
                } else {
                    navMenu.scrollLeft = 3000;
                    component.set('v.scrollDirection', 'right');
                }
            }catch (e) {
            }
        }
    }


})