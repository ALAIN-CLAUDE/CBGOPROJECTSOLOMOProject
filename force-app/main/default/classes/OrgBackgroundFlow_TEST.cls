@isTEST
public class OrgBackgroundFlow_TEST {
	private static List<string> listTestStrings;
    private static void scenario1(){
        listTestStrings=new List<string>();
        listTestStrings.add('<p>test String</p>');    
    }
    
    private static testmethod void testmethod1(){
        Test.startTest();
        scenario1();
        OrgBackgroundFlow.convertRichTextToPlainText(listTestStrings);
        Test.stopTest();
    }
        

}