/**
 * Created by Kryvolap on 03.04.2019.
 */
({
    doUpdateStudyTitle: function (component) {
        if(component.isValid()) {
            var studyTitle = document.getElementsByClassName("study-title").item(0);
            if(studyTitle != null ){
                if(window.innerWidth < 768){
                    $clamp(studyTitle,{clamp: 3});
                }
                else{
                    $clamp(studyTitle,{clamp: 1});
                }
            }
        }
    }
})