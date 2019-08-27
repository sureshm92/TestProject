/**
 * Created by Nikita Abrazhevitch on 20-Aug-19.
 */

({
    sortAndSetAccountsByName: function (component, accounts) {
        accounts.sort(function (a, b) {
            var nameA = a.Name.toUpperCase();
            var nameB = b.Name.toUpperCase();
            if (nameA < nameB) {
                return -1;
            }
            if (nameA > nameB) {
                return 1;
            }
            return 0;
        });
        component.set('v.studySiteAccounts', accounts);
    },
});