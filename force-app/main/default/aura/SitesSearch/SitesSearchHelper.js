/**
 * Created by Kryvolap on 03.04.2019.
 */
({
    doUpdateStudyTitle: function (component) {
        if (component.isValid()) {
            var studyTitles = document.getElementsByClassName("study-title");
            for (var i = 0; i < studyTitles.length; i++) {
                var studyTitle = studyTitles.item(i);
                if (studyTitle != null) {
                        if (window.innerWidth < 768) {
                            this.clampLine(studyTitle,3);
                        } else {
                            this.clampLine(studyTitle,1);
                        }
                }
            }
        }
    },

    clampLine:function(studyTitle,numberOfRows){
        var width = studyTitle.style.width;
        if(width === '0' || !width){
            width=studyTitle.parentNode.offsetWidth;
        }
        var innerText = studyTitle.innerText.replace(/\n/g, ' ');
        studyTitle.innerHTML = '';
        var text = innerText.split(' ');
        var currentWord = 0;
        if (numberOfRows > 1) {
            parentLoop:
                for (let i = 0; i < numberOfRows - 1; i++) {
                    var measure = document.createElement('span');
                    measure.style.whiteSpace='nowrap';
                    measure.style.display='inline-block';
                    studyTitle.appendChild(measure);
                    for (let j = currentWord; j < text.length; j++) {
                        measure.appendChild(document.createTextNode(text[j] + " "));
                        if (measure.getBoundingClientRect().width > width) {
                            measure.removeChild(measure.lastChild);
                            continue parentLoop;
                        }
                        currentWord++;
                    }
                }
        }
        var lastElement = document.createElement('span');
        for (let i = currentWord; i < text.length; i++) {
            lastElement.appendChild(document.createTextNode(text[i] + " "));
        }
        lastElement.style.display='inline-block';
        lastElement.style.overflow = 'hidden';
        lastElement.style.textOverflow = 'ellipsis';
        lastElement.style.whiteSpace = 'nowrap';
        lastElement.style.width = '100%';
        studyTitle.appendChild(lastElement);
    },
})