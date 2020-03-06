/**
 * Created by Nargiz Mamedova on 3/3/2020.
 */

@IsTest
public class Test_FlowCOILookupRemote {
    @IsTest
    public static void setCOILookup(){
        Resource__c newResource = new Resource__c(
                article_external_link__c = 'https://www.clinicalresearch.com/potential-participants/articles/HealthDayArticle?actid=739845',
                ArticleID__c = '739845',
                Content_Class__c = '3rd Party',
                Content_Type__c = 'Article',
                Title__c = 'Health Highlights: Nov. 20, 2018',
                Body__c = '<p>Here are some of the latest health and medical news developments, compiled by the editors of HealthDay:</p><p><span class="subhead"><b>Vaccine-Exempt Students Behind N.C. Chickenpox Outbreak</b></span></p><p>North Carolina\'s largest chickenpox outbreak in decades is centered in a primary school with a large number of vaccine-exempt students, according to health officials.</p><p>Thirty-six students at Asheville Waldorf School were diagnosed with the disease last Friday, <i>BBC News</i> reported.</p><p>The school has one of the state\'s highest rates of religious-based vaccine exemptions for students.</p><p>Of the school\'s 152 students, 110 have not received the vaccine against the virus that causes chickenpox, according to <i>BBC News</i>.</p><p>In 2017/18, nearly 68 percent of the school\'s kindergarten students had religious immunization exemptions on file.</p><p>"This is the biggest chickenpox outbreak state health officials are aware of since the vaccine became available," a state health department spokesman told <i>BBC News</i>.</p><p>The school is co-operating with local health officials and is compliant with all state laws, a school spokesperson said.</p><p>-----</p><p><span class="subhead"><b>CDC Creates   Task Force to Track Polio-Like Disease</b></span></p><p>A task force to investigate a rising number of cases of a rare polio-like disease among children in the United States has been created by the U.S. Centers for Disease Control and Prevention.</p><p>The task force on acute flaccid myelitis (AFM) will include scientific, medical and public health experts who will attempt to identify the cause of the disease and improve patient treatment and outcomes.</p><p>AFM affects the spinal cord, causing weakness in one or more limbs. The United States has seen an increased number of AFM cases since 2014, mostly in children. There have been 106 confirmed cases of AFM in 29 states in 2018. All but five have been in children aged 18 or younger, according to the CDC.</p><p>"This task force will ensure that the full capacity of the scientific community is engaged and working together to provide important answers and solutions to actively detect, more effectively treat, and ultimately prevent AFM and its consequences," CDC Director Dr. Robert Redfield said in an agency news release.</p><p>The task force will make key recommendations  on how to respond to the rising number of AFM cases.</p><p>The task force plans to submit its first report at a Dec. 6 public meeting in Atlanta, the CDC said.</p><p>-----</p><p><span class="subhead"><b>Cap\'n Crunch Cereal Recalled Due to Salmonella Scare</b></span></p><p>A small number of boxes of Cap\'n Crunch\'s Peanut Butter Crunch are being recalled due to potential salmonella contamination, Quaker Oats says.</p><p>The recall is for 21 boxes bought after Nov. 5 at Super Target Stores in Omaha and Lincoln. Neb., and in Wichita, Kansas, and at P-Fresh stores in St. Louis and Blue Springs, Missouri.</p><p>The 17.1 ounce boxes have the UPC code 0 30000 6211 1 and Best Before Dates of JUL 30 19 or JUL 31 19.</p><p>No illnesses related to the products have been reported, according to the company.</p><p>The recalled cereal should be thrown away or returned to the store for a refund. For more information, consumers can call 1-800-234-6281.</p><p>Salmonella can cause serious and sometimes fatal infections in young children, frail or elderly people, and others with weakened immune systems. In healthy people, salmonella typically causes fever, diarrhea (which may be bloody), nausea, vomiting and abdominal pain.</p>'
        );
        insert newResource;

        Therapeutic_Area__c newTA = new Therapeutic_Area__c(Name = 'Cancer');
        insert newTA;

        List<Therapeutic_Area__c> therapeuticAreas = [SELECT Id FROM Therapeutic_Area__c];
        List<Therapeutic_Area__c> newCOIs = new List<Therapeutic_Area__c>();
        newCOIs.add(new Therapeutic_Area__c(Name = 'Metastatic Cancer', Therapeutic_Area__c = therapeuticAreas[0].Id));
        newCOIs.add(new Therapeutic_Area__c(Name = 'Regular Cancer', Therapeutic_Area__c = therapeuticAreas[0].Id));
        insert newCOIs;

        List<Resource__c> resources = [SELECT Id FROM Resource__c WHERE ArticleID__c = '739845'];
        List<Therapeutic_Area__c> COIs = [SELECT Id FROM Therapeutic_Area__c WHERE Therapeutic_Area__c != NULL ORDER BY Name];
        Therapeutic_Area_Assignment__c newTAA = new Therapeutic_Area_Assignment__c(
                Resource__c = resources[0].Id,
                Therapeutic_Area__c = COIs[0].Id
        );
        insert newTAA;

        Test.startTest();
        FlowCOILookupRemote.setCOILookup(resources[0].Id, COIs[1].Id);
        Test.stopTest();

        List<Therapeutic_Area_Assignment__c> therapeuticAreaAssignments = [SELECT Id, Therapeutic_Area__r.Name FROM Therapeutic_Area_Assignment__c];
        System.assertEquals('Regular Cancer', therapeuticAreaAssignments[0].Therapeutic_Area__r.Name);
    }
}