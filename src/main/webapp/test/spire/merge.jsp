<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="com.spire.presentation.FileFormat"%>
<%@page import="com.spire.presentation.Presentation"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
        //Create a Presentation instance
        Presentation ppt1= new Presentation();
        //Load the first presentation
        ppt1.loadFromFile("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\erp_sample.pptx");
 
        //Create a Presentation instance
        Presentation ppt2 = new Presentation();
        //Load the second presentation
        ppt2.loadFromFile("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\web_sample.pptx");
 
        //Loop through the slides of the first presentation
        for(int i = 0; i < ppt1.getSlides().getCount(); i++) {
            //Append the slides of the first presentation to the end of the second presentation
            ppt2.getSlides().append(ppt1.getSlides().get(i));
 
            //Insert the slides of the first presentation into the specified position of the second presentation
            //ppt2.getSlides().insert(0, ppt1.getSlides().get(i));
        }
 
        //Save the result presentation to another file
        ppt2.saveToFile("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\MergePresentations.pptx", FileFormat.PPTX_2013);
        
      //파일 저장하기
      //String fileName = "ex.pptx";
	String fileName = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\MergePresentations.pptx";
	
    	File dFile = new File(fileName);
    	FileInputStream in = new FileInputStream(fileName);
    	int fSize = (int)dFile.length();
    	
    	fileName = new String(fileName.getBytes("utf-8"),"8859_1");
    	response.setContentType("application/octet-stream");
    	response.setHeader("Content-Disposition","attachment; filename=MergePresentations.pptx.pptx");
    	out.clear();
    	out = pageContext.pushBody();
    	
    	OutputStream os = response.getOutputStream();
    	
    	int length;
    	byte[] b = new byte[(int)fileName.length()];
    	
    	while ((length = in.read(b)) > 0) {
    		os.write(b,0,length);
    	}
    	
    	os.flush();
    	os.close();
    	in.close(); 
%>
</body>
</html>