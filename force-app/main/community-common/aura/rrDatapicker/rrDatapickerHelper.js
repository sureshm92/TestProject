({
    prepopulateDate: function (component, prepopulateDate) {

        if(prepopulateDate){
            var currentDate = new Date();
            var dd = currentDate.getDate();
            var mm = currentDate.getMonth() + 1;
            var yyyy = currentDate.getFullYear();

            if (dd < 10) dd = '0' + dd;
            if (mm < 10) mm = '0' + mm;

            var newDate = yyyy + "-" + mm + "-" + dd;

            component.set("v.value", newDate);
        }
    }
})