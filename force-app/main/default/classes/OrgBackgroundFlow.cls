public class OrgBackgroundFlow {
    @InvocableMethod(Label='convertRichTextToPlainText')
    
    public static List<string> convertRichTextToPlainText(List<string> listRichText){
        List<string> listPlainText=new List<string>();
        if(listRichText!=null && !listRichText.isEmpty()){
            for(string richText : listRichText){
                listPlainText.add(richText.stripHtmlTags());
            }           
        }
        return listPlainText;     
    }
}