/**
 * @description       : Test class for the ResponseData class
 * @author            : Bluewave | Tomasz Piechota
 * @group             :
 * @last modified on  : 11-13-2020
 * @last modified by  : Bluewave | Tomasz Piechota
 * Modifications Log
 * Ver   Date         Author                       Modification
 * 1.0   11-13-2020   Bluewave | Tomasz Piechota   Initial Version
**/
@isTest
public class ResponseData_TEST {
    @IsTest
    public static void ResponseData_01() {
        ResponseData rd = new ResponseData(true);
        System.AssertEquals(true, rd.status, 'False is not expected');
    }

    @IsTest
    public  static void ResponseData_02() {
        String message = 'Test message';
        ResponseData rd = new ResponseData(true, message);
        System.AssertEquals(true, rd.status, 'False is not expected');
        System.AssertEquals(message, rd.message, 'Empty string is not expected');
    }

    @IsTest
    public  static void ResponseData_03() {
        String jsonInput = '{"key": "value"}';
        Object obj = (Object) JSON.deserializeUntyped(jsonInput);

        ResponseData rd = new ResponseData(true, new Map<String, String>{'key' => 'value'});
        Map<String, Object> data = (Map<String, Object>)rd.returnData;

        System.AssertEquals(true, rd.status, 'False is not expected');
        System.AssertEquals(null, rd.message, 'Message is not expected');
        System.AssertEquals('value', data.get('key'), 'Empty string is not expected');
    }
}