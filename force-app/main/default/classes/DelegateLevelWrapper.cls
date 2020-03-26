/**
 * Created by Leonid Bartenev
 */

global class DelegateLevelWrapper implements Comparable {
    
    global String level {get; set;}
    global String studyName {get; set;}

    public DelegateLevelWrapper() {}

    public DelegateLevelWrapper(String level, String studyName) {
        this.level = level;
        this.studyName = studyName;
    }

    global Integer compareTo(Object compareTo) {
        if (studyName > ((DelegateLevelWrapper) compareTo).studyName) {
            return 1;
        } else if (studyName < ((DelegateLevelWrapper) compareTo).studyName) {
            return -1;
        }
        return 0; 
    }
}