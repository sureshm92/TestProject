({
    // Your renderer method overrides go here
    unrender: function (component, event) {
        this.superUnrender();
        if (sessionStorage) {
            console.log('unredner');
            console.log(component.get('v.isNext'));
            if (!component.get('v.isNext')) {
                console.log('inside if');
                sessionStorage.removeItem('validationfailed');
            }
        }
    }
});
