/**
 * Created by Leonid Bartenev
 */

({
    scrollToPage: function(component, event, helper, pageNumber) {
        var carouselBody = component.find('carouselBody').getElement();
        var carouselBodyWidth = carouselBody.getBoundingClientRect().width;
        var currentPage = component.get('v.currentPage');
        var slideSpeed = 500; // Milliseconds
        var frameRate = 25;
        var frameTime = slideSpeed / frameRate;
        var frameCount = 0;
        var increment = (carouselBodyWidth * (pageNumber - currentPage)) / frameRate;


        var slideInterval = setInterval(function () {
            frameCount++;
            window.requestAnimationFrame(function () {
                carouselBody.scrollLeft += increment;
            });

            if (frameCount === frameRate) {
                clearInterval(slideInterval);
                currentPage = pageNumber;
                window.requestAnimationFrame(function () {
                    carouselBody.scrollLeft = carouselBodyWidth * currentPage;
                });
                component.set('v.currentSlide', component.get('v.slides')[pageNumber]);
            }
        }, frameTime);

        component.set('v.currentPage', pageNumber);

        helper.updateDots(component, event, helper);
    },

    updateDots: function(component, event, helper) {
        var dots = component.find('dot');
        var currentPage = component.get('v.currentPage');

        dots.forEach(function(self, index) {
            if (index === currentPage) {
                self.getElement().classList.add('sc-pagination__dot_selected');
            } else {
                self.getElement().classList.remove('sc-pagination__dot_selected');
            }
        });
    },

    show: function (component, tourName) {
        var helper = this;
        if(!tourName){
            var tourNamesMap = component.get('v.tourNamesMap');
            tourName = tourNamesMap[communityService.getUserMode()];
        }
        component.set('v.showOnLogin', communityService.showTourOnLogin());
        component.set('v.currentPage', 0);
        communityService.executeAction(component, 'getSlides', {
            tourName: tourName,
            formFactor: $A.get('$Browser.formFactor'),
            multimode: communityService.getCommunityTypes().length > 1
        }, function (returnValue) {
            var tour = JSON.parse(returnValue);
            component.set('v.title', tour.title);
            component.set('v.slides', tour.slides);
            if(tour.slides.length > 0) component.set('v.currentSlide', tour.slides[0]);
            component.find('spinner').hide();
            component.find('carouselBody').getElement().scrollLeft = 0;
            component.set('v.visible', true);
        });
    }


})