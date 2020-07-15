/**
 * Created by Leonid Bartenev
 */

({
    scrollToPage: function(component, event, helper, pageNumber) {
        var carouselBody = component.find('carouselBody').getElement();
        var carouselBodyWidth = carouselBody.getBoundingClientRect().width;
        var currentPage = component.get('v.currentPage');
        var slideSpeed = (navigator.userAgent.match(/Trident/)) ? 50:500; // Milliseconds
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
    }


})