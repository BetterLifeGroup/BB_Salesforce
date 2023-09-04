/**
 * Created by frans fourie on 2023/07/13.
 */

public with sharing class StringToList {

    @InvocableMethod
    public static List<Response> methods(List<Request> reqList) {

        Response resp = new Response();
        List<Response> respList = new List<Response>{resp};

        Request req = reqList[0];

        if (req.methodName.toLowerCase() == 'stringtolist') {
            if (req.stringToList == null || (!req.stringToList.contains(req.delimiter))) {
                resp.errorMessage = 'The stringToList variable should be populated when method is specified as StringToList or a delimiter was supplied that\'s not present in the stringToList variable';
                return respList;
            }
            try {
                resp.returnedStringList = req.stringToList.split(req.delimiter);
            } catch (Exception e) {
                resp.errorMessage = e.getMessage();
            }
            return respList;
        } else if (req.methodName.toLowerCase() == 'listtostring') {
            if (req.listToStrings == null) {
                resp.errorMessage = 'The listToStrings variable should be populated when method is specified as ListToString';
                return respList;
            }
            try {
                resp.returnedDelimitedString = String.join(req.listToStrings, req.delimiter);
            } catch (Exception e) {
                resp.errorMessage = e.getMessage();
            }
            return respList;
        } else {
            resp.errorMessage = 'Invalid method name supplied. Valid values are StringToList OR ListToString';
        }

        return respList;
    }

    public class Request {
        @InvocableVariable(Label='Method' Description='Apex method to apply. Accepted values are StringToList OR ListToString' Required=true) public String methodName;
        @InvocableVariable(Label='String To List' Description='String that should be returned as a list' Required=false) public String stringToList;
        @InvocableVariable(Label='Delimiter' Description='Delimiter supplied or expected' Required=true) public String delimiter;
        @InvocableVariable(Label='List of strings' Description='List of strings to be returned as delimited list' Required=false) public List<String> listToStrings;
    }

    public class Response {
        @InvocableVariable(Label='Delimited String Returned' Description='Delimited String returned') public String returnedDelimitedString;
        @InvocableVariable(Label='String List Returned' Description='List of strings returned') public List<String> returnedStringList;
        @InvocableVariable(Label='Error' Description='Error Message returned if error occurred') public String errorMessage;

    }

}