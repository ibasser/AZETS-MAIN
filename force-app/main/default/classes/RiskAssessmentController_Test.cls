/**
 * Purpose: Test class for RiskAssessmentController
 * 
 * Author: PJ (Bluewave)
 * Created Date: 26th February 2021
 * Updates:
 * IB (Bluewave) - 1st March 2021 - added more test scenarios
 * */
@isTest
public inherited sharing class RiskAssessmentController_Test {
    @TestSetup
    static void makeData(){
        
        // riskCategories = A1, A2, B1, B2, C, D

        // risk Data is a trhee dimensional array:
        //  Firs index runs over the number of risk assesment records
        //  Second index runs over the number of risk record for the risk assesment, 
        //  and the last index runs over the following fields, in order:
        //      answer__c;
        //      Positive_Answer__c;
        //      riskCategory;
        //      riskRanking;
        //
        //  
        List<List<List<String>>> testRiskData = new List<List<List<String>>>{
            //Insert a new Block for every test (for every ), 
            new List<List<String>>{
                new List<String>{'same','same','Cash','D','Q'},
                new List<String>{'same','same','Cash','D','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','D','Q'},
                new List<String>{'same','Diff','Cash','A1','Q'},
                new List<String>{'same','same','Cash','B1','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','Diff','Cash','B1','Q'},
                new List<String>{'same','Diff','Sector','B1','Q'},
                new List<String>{'same','Diff','Accounts','B1','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','A1','Q'},
                new List<String>{'same','Diff','Sector','A2','Q'},
                new List<String>{'same','Diff','Accounts','C','Q'},
                new List<String>{'same','Diff','Accounts','B2','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','Diff','Cash','B1','Q'},
                new List<String>{'same','Diff','Sector','B1','Q'},
                new List<String>{'same','Diff','Accounts','C','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','D','Q'},
                new List<String>{'same','same','Sector','A1','Q'},
                new List<String>{'same','Diff','Accounts','C','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','B2','Q'},
                new List<String>{'same','same','Sector','A1','Q'},
                new List<String>{'same','same','Accounts','C','Q'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','A2','Q1'},
                new List<String>{'Answer 2','Diff','Sector','A2','Q2'},
                new List<String>{'same','Diff','Accounts','C','Q3'},
                new List<String>{'Answer 4','Diff','Accounts','A2','Q4'}
            },
            new List<List<String>>{
                new List<String>{'same','same','Cash','A2','Q1'},
                new List<String>{'Answer 2','Diff','Sector','A2','Q2'},
                new List<String>{'Answer 3','Diff','Accounts','A1','Q3'},
                new List<String>{'Answer 4','Diff','Accounts','A2','Q4'}
            }
        };

        // create a new Risk Assesment record for every test
        List<Risk_Assessment__c> assesementsToInsert = new List<Risk_Assessment__c>();
        // since Name is not writeable we will use the Negative_Answer__c field to identify the assesment for the test case
        for (integer i =0; i<testRiskData.size(); i++) {
            assesementsToInsert.add( new Risk_Assessment__c(Test_Record_Name__c='Test Assessment ' + i));
        }

        insert assesementsToInsert;

        List<Risk__c> riskToInsert = new List<Risk__c>();
        for (Integer i =0; i<testRiskData.size(); i++) {
            for (Integer j =0; j<testRiskData[i].size(); j++) {

                System.debug('Record name ' + assesementsToInsert[i].Test_Record_Name__c);
                System.debug ('testData ' +testRiskData[i][j][0]+testRiskData[i][j][3]);
                riskToInsert.add(new Risk__c(
                    Answer__c = testRiskData[i][j][0],
                    Positive_Answer__c = testRiskData[i][j][1],
                    risk_Assessment__c = assesementsToInsert[i].id,
                    risk_Category__c = testRiskData[i][j][2],
                    Risk_Ranking__c = testRiskData[i][j][3],
                    Question__c = testRiskData[i][j][4]
                ));

                upsert riskToInsert;
            }
        }
    }

    @isTest
    public static void test0_testDrating(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 0'];

        // Code to be removed *******
        System.debug('total risk ' + riskAssessment.Risks__r.size() );
        for (Risk__c r : riskAssessment.Risks__r){
            System.debug('assessment id ' + r.Risk_Assessment__c);
            System.debug('Ranking is ' + r.Risk_Ranking__c);
            System.debug('Ranking is positive ' + r.Is_Positive_Answer__c);
        }

        // ********* end code to be removed 
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 0'][0].Risk_Rating__c;

        System.assertEquals('D', rating);
    }
    
    @isTest
    public static void test1_testA1rating(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 1'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 1'][0].Risk_Rating__c;

        System.assertEquals('A1', rating);
    }
    
    @isTest
    public static void test2_testA1ratingBy3B1s(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 2'];

        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 2'][0].Risk_Rating__c;

        System.assertEquals('A1', rating);
    }
    
    @isTest
    public static void test3_testA2rating(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 3'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 3'][0].Risk_Rating__c;

        System.assertEquals('A2', rating);
    }
    
    @isTest
    public static void test4_testBrating(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 4'];

        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 4'][0].Risk_Rating__c;

        System.assertEquals('B', rating);
    }
    
    @isTest
    public static void test5_testCratingNegative(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 5'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 5'][0].Risk_Rating__c;

        System.assertEquals('C', rating);
    }
    
    @isTest
    public static void test6_testCratingAllPositive(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 6'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String rating = [SELECT id,Risk_Rating__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 6'][0].Risk_Rating__c;

        System.assertEquals('C', rating);
    }

    @isTest
    public static void test7_testSaveQuestions(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 7'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String questions = [SELECT id,Risk_Rating_Questions__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 7'][0].Risk_Rating_Questions__c;

        System.assertEquals('Q2 : Answer 2, Q4 : Answer 4,', questions);
    }


    @isTest
    public static void test8_testSaveQuestionsA1(){
        Risk_assessment__c riskAssessment = [SELECT id,(SELECT id, Risk_Ranking__c, Risk_Assessment__c, Is_Positive_Answer__c FROM Risks__r ) FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 8'];
        
        Test.startTest();
        RiskAssessmentController.calculateRisk(String.valueOf(riskAssessment.id));
        Test.stopTest();

        String questions = [SELECT id,Risk_Rating_Questions__c FROM Risk_assessment__c WHERE Test_Record_Name__c = 'Test Assessment 8'][0].Risk_Rating_Questions__c;

        System.assertEquals('Q3 : Answer 3,', questions);
    }
// " Sector "
// " Cash "
// " Structure "
// " Geographical "
// " Regulated "
// " Team "
// " Business "
// " Resource and Competence "
// " Specialist service "
// " Terms "
// " Accounts "
// " Client money "
// " Fee Value "
// " Client integrity "
// " Reputational "
// " [To prompt thought] "
// " Insolvency "
// " Financial Due Diligence "
// " Lead Advisory "

            
        
    
}