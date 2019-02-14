/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var map = L.map('mapId');

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: ''
        }).addTo(map);

        /*L.tileLayer('http://{s}.tile.openstreetmap.se/hydda/full/{z}/{x}/{y}.png', {
            maxZoom: 18,
            subdomains: 'abc'
        }).addTo(map);*/

        /*L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.openstreetmap.org/" target="_blank">Humanitarian OpenStreetMap Team</a>'
        }).addTo(map);*/

        /*L.tileLayer('https://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}', {
            maxZoom: 16
        }).addTo(map);*/

        //var googleLayer = new L.Google('ROADMAP');
        //map.addLayer(googleLayer);

        var accounts = component.get('v.accounts');
        var markers = [];
        for(var i = 0; i < accounts.length; i++){
            var accountWrapper = accounts[i];
            var account = accountWrapper.clinic;
            if(!account.BillingLatitude || !account.BillingLongitude) continue;
            var latLng = [account.BillingLatitude, account.BillingLongitude];
            markers.push(
                L.marker(latLng, {account: account})
                    .bindPopup('<b>' + accountWrapper.name + '</b><br/> ' + accountWrapper.addrStreet + '<br/>' + accountWrapper.addrCity)
                    .on('mouseover', function(event){
                        this.openPopup();
                    })
                    .on('mouseout', function(event){
                        this.closePopup();
                    })
                    .on('click', function(event) {
                        if(communityService.getUserMode() === 'PI') communityService.navigateToPage('clinic-profile?id=' + event.target.options.account.Id);
                    })
                    .addTo(map)
            );
        }

        var group = new L.featureGroup(markers);
        map.fitBounds(group.getBounds());

        component.set("v.map", map);
    }

});