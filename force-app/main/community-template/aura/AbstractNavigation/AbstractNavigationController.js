/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
    },

    doChangeItemsList: function (component, event, helper) {
        try {
            helper.initItemsMap();
            let userMode = component.get('v.mode');
            let menuItems = helper.itemsMap[userMode];
            component.set('v.menuItems', menuItems);
            component.set('v.scrollRequired', false);
            component.set('v.scrollDirection', 'left');
            let scrollEnableCheckHandler = $A.getCallback(function () {
                let navMenuCmp = component.getConcreteComponent().find('navMenu');
                if (navMenuCmp) {
                    let navMenu = navMenuCmp.getElement();
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
        let pageName = event.currentTarget.dataset.pageName;
        helper.updateDocumentTitle(component, pageName);
        communityService.navigateToPage(pageName);
    },

    onClickResource: function (component, event, helper){
        let pageName = 'resources-pi';
        helper.updateDocumentTitle(component, pageName);
        communityService.navigateToPage('library');
    },

    doScroll: function (component, event, helper) {
        let direction = component.get('v.scrollDirection');
        let navMenuCmp = component.getConcreteComponent().find('navMenu');
        if (navMenuCmp) {
            let navMenu = navMenuCmp.getElement();
            let navMenuWidth = navMenu.getBoundingClientRect().width;
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