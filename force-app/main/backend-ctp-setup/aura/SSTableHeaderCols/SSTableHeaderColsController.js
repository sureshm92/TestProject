/**
 * Created by Leonid Bartenev
 */
({
    doSort: function (component, event, helper) {
        let sortDirection = component.get('v.filter.sortDirection');
        component.set('v.filter.sortField', event.currentTarget.dataset.order);
        if(sortDirection === 'ASC'){
            component.set('v.filter.sortDirection', 'DESC');
        }else{
            component.set('v.filter.sortDirection', 'ASC');
        }
        component.getEvent('onSort').fire();
    }

})