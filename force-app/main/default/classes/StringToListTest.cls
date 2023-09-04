/**
 * Created by frans fourie on 2023/07/13.
 */

@IsTest
public with sharing class StringToListTest {

    @IsTest
    public static void testMethods() {
        List<String> stringList = new List<String>{
                'a', 'b', 'c', 'd'
        };

        List<StringToList.Request> reqList = new List<StringToList.Request>();
        StringToList.Request req = new StringToList.Request();

        List<StringToList.Request> reqList2 = new List<StringToList.Request>();
        StringToList.Request req2 = new StringToList.Request();

        req.delimiter = ';';
        req.stringToList = 'a;b;c;d';
        req.methodName = 'stringToList';
        reqList.add(req);

        req2.delimiter = ';';
        req2.methodName = 'listToString';
        req2.listToStrings = stringList;
        reqList2.add(req2);

        Assert.areEqual(StringToList.methods(reqList)[0].returnedStringList, stringList);
        Assert.areEqual(StringToList.methods(reqList2)[0].returnedDelimitedString, 'a;b;c;d');

        req.stringToList = null;

        Assert.isNotNull(StringToList.methods(reqList)[0].errorMessage);

        req2.listToStrings = null;

        Assert.isNotNull(StringToList.methods(reqList2)[0].errorMessage);

        req.methodName = 'invalidMethodName';

        Assert.isNotNull(StringToList.methods(reqList)[0].errorMessage);

        req.delimiter = ',';
        req.stringToList = 'a;b;c;d';
        req.methodName = 'stringToList';
        
        Assert.isNotNull(StringToList.methods(reqList)[0].errorMessage);

    }

}