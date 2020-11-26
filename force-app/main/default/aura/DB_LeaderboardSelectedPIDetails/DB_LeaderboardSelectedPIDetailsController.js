({
    doinit: function (component, event, helper) {
        var selectedpi = component.get('v.piData.selectedPi');
        var studysiteranklist = component.get('v.pIStudySiteRank');
        var piStudySites = [];
        for (var i in studysiteranklist) {
            if (studysiteranklist[i].pi_Id == selectedpi) {
                piStudySites.push(studysiteranklist[i]);
            }
        }
        component.set('v.pIStudySiteRank', piStudySites);
    }
});
