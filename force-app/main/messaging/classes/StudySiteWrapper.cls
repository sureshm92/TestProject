/**
 * Created by Olga Skrynnikova on 2/3/2020.
 */

public with sharing class StudySiteWrapper {

        public String studyName {get; set;}

        public StudySiteWrapper(String studyName){
            this.studyName = studyName;
        }
}