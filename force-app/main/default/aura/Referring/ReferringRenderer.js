/**
 * Created by Leonid Bartenev
 */
({
    unrender : function(component){
        this.superUnrender();
        if(!component.serveyGizmoResultHandler) window.removeEventListener('message', component.serveyGizmoResultHandler);
    }

})