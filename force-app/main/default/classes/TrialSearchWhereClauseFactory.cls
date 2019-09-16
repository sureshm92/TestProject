/**
 * Created by Admin on 9/13/2019.
 */

public with sharing class TrialSearchWhereClauseFactory {

    //Site Type
    public static final String QCARE_TYPE = 'QCare';

    //ORS status
    public static final String ACTIVELY_ENROLLING = 'Actively Enrolling';
    public static final String ON_HOLD = 'On Hold';

    //CTMS status
    public static final String ENROLLING = 'Enrolling';
    public static final String OPEN_TO_ENROLLMENT = 'Open to Enrollment';
    public static final String PLANNING = 'Planning';
    public static final String IN_DEVELOPMENT = 'In Development';

    public static final List<String> ORS_STATUS_ENROLLING = new List<String>{
            ACTIVELY_ENROLLING,
            ON_HOLD
    };

    public static final List<String> CTMS_RECRUITMENT = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT,
            PLANNING,
            IN_DEVELOPMENT
    };

    public static final List<String> CTMS_RECRUITMENT_ENROLLING = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT
    };

    public static final List<String> CTMS_ON_HOLD = new List<String>{
            PLANNING,
            IN_DEVELOPMENT
    };


    public WhereClause getWhereClause(List<Id> taIds, Boolean isEnrolling, Boolean isNotYetEnrolling, Boolean isQCare) {
        WhereClause idFilteredClause = new IdFilteredWhereClause(taIds);
        WhereClause enrolledIdFilteredClause = this.getEnrollingExtendedWhereClause(idFilteredClause, isEnrolling, isNotYetEnrolling);
        if (isQCare) {
            WhereClause qCareEnrolledidFilteredClause = new QCareWhereClauseDecorator(enrolledIdFilteredClause);
            return qCareEnrolledidFilteredClause;
        } else {
            return enrolledIdFilteredClause;
        }
    }

    private WhereClause getEnrollingExtendedWhereClause(WhereClause clause, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        if (isEnrolling && isNotYetEnrolling) {
            return new EnrollingNotEnrollingWhereClauseDecorator(clause);
        } else if (isEnrolling) {
            return new EnrollingWhereClauseDecorator(clause);
        } else if (isNotYetEnrolling) {
            return new NotEnrollingWhereClauseDecorator(clause);
        }
        return new WhereClauseDecorator(clause);
    }


    public interface WhereClause {
        String getWhereClause();
    }

    public virtual class WhereClauseDecorator implements WhereClause {
        private WhereClause clause;

        public WhereClauseDecorator(WhereClause clause) {
            this.clause = clause;
        }

        public virtual String getWhereClause() {
            return clause.getWhereClause();
        }
    }

    public class IdFilteredWhereClause implements WhereClause {

        List<Id> taIds;

        public IdFilteredWhereClause(List<Id> taIds) {
            this.taIds = taIds;
        }

        public String getWhereClause() {
            return 'WHERE Therapeutic_Area__c IN ' + '(\'' + String.join(taIds, '\',\'') + '\') ';
        }

    }

    public class QCareWhereClauseDecorator extends WhereClauseDecorator {

        public QCareWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return clause.getWhereClause() + 'Id IN (SELECT Clinical_Trial_Profile__c FROM Participant_Enrollment__c WHERE Study_Site__r.Site__r.Type = \''+ QCARE_TYPE +'\'';
        }
    }

    public class EnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public EnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return clause.getWhereClause() + ' AND (Override_Recruitment_Status__c = ' + '\'' + ACTIVELY_ENROLLING + '\' ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_RECRUITMENT_ENROLLING, '\',\'') + '\')) ';
        }
    }

    public class NotEnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public NotEnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return clause.getWhereClause() + ' AND (Override_Recruitment_Status__c = ' + '\'' + ON_HOLD + '\' ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_ON_HOLD, '\',\'') + '\')) ';
        }
    }

    public class EnrollingNotEnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public EnrollingNotEnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return clause.getWhereClause() + ' AND (Override_Recruitment_Status__c IN ' + '(\'' + String.join(ORS_STATUS_ENROLLING, '\',\'') + '\') ' +
                    'OR Override_Recruitment_Status__c IN ' + '(\'' + String.join(CTMS_RECRUITMENT, '\',\'') + '\')) ';
        }
    }

}