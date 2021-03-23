/**
 * Purpose: Calculate the risk rating for a risk assessment record
 * Description:
 *  Loop through all risk records for a risk assessment. Check if the risk have positive or negative answers.
 *  Then set the risk rating on the risk assessment record as the highest value from the risk records.
 * 
 * Author: Ismail Basser (Bluewave)
 * Created Date: 1st March 2021
 * */
public with sharing class RiskAssessmentController {

    public static void calculateRisk(String riskAssessmentId)
    {
        String ratingQuestions = '';
        
        List<Risk__c> riskRecords = [SELECT Id, Name, Risk_Assessment__c, Risk_Category__c, 
                                            Risk_Ranking__c, Is_Positive_Answer__c, 
                                            Answer__c, Positive_Answer__c, Negative_Answer__c, Question__c 
                                    FROM Risk__c WHERE Risk_Assessment__c =:riskAssessmentId];

        List<String> riskRatingValues = new List<String>{'A1', 'A2', 'B', 'C', 'D'};

        Integer riskValue = riskRatingValues.indexOf('C');
        Integer b1Negative = 0;

        for(Risk__c risk : riskRecords)
        {
            Boolean riskRatingBlank = risk.Risk_Ranking__c == null || risk.Risk_Ranking__c == '';
            Boolean positiveAnswerBlank = risk.Positive_Answer__c == null || risk.Positive_Answer__c == '';
            Boolean negativeAnswerBlank = risk.Negative_Answer__c == null || risk.Negative_Answer__c == '';
            //skip if risk rating, positive answer or negative answer values are blank
            if(riskRatingBlank || (positiveAnswerBlank && negativeAnswerBlank))
            {
                System.debug('record to be skipped: ' + risk);
                continue;
            }

            String riskCategory = risk.Risk_Category__c;
            Integer currentRiskValue; 

            if(risk.Risk_Ranking__c =='B1' || risk.Risk_Ranking__c =='B2')
            {
                currentRiskValue = riskRatingValues.indexOf('B');
            }
            else 
            {
                currentRiskValue = riskRatingValues.indexOf(risk.Risk_Ranking__c);
            }
            System.debug('currentRiskValue: ' + currentRiskValue);

            //counts number of negative b1 answers
            if(!risk.Is_Positive_Answer__c && risk.Risk_Ranking__c =='B1')
            {
                b1Negative++;
            }

            // if answer is negative and the current risk rating in the for loop is higher than the last
            // this means that the index in riskRatingValues will be lower for high rating values
            if(!risk.Is_Positive_Answer__c && currentRiskValue < riskValue)
            {
                riskValue = currentRiskValue;
                ratingQuestions = '';
            }
            
            // if answer is positive and the current risk rating in the for loop is D and was previously C
            if(risk.Is_Positive_Answer__c && currentRiskValue == riskRatingValues.indexOf('D') && riskValue == riskRatingValues.indexOf('C'))
            {
                System.debug('D Value');
                riskValue = currentRiskValue;
                ratingQuestions = '';
            }

            //Add answer to list 
            System.debug('value ' + riskValue + ' current' + currentRiskValue);
            if (riskValue == currentRiskValue){
                System.debug('Add line ' +risk.Question__c + ' : ' + risk.Answer__c + ', ');
                ratingQuestions = ratingQuestions + risk.Question__c + ' : ' + risk.Answer__c + ', ';
                
            }
        }

        Risk_Assessment__c riskAssessment = [SELECT Id, Risk_Rating__c,Risk_Rating_Questions__c FROM Risk_Assessment__c WHERE Id =:riskAssessmentId];

        /*
        * if there are 3 or more negative b1 values then the risk rating is set to A1
        * otherwise the risk rating is set to the highest value
        */
        if(b1Negative >= 3)
        {
            riskAssessment.Risk_Rating__c = 'A1';
        }
        else 
        {
            riskAssessment.Risk_Rating__c = riskRatingValues[riskValue];
        }

        riskAssessment.Risk_Rating_Questions__c = ratingQuestions;

        update riskAssessment;
    }

}