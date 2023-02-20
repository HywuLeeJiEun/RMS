<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="com.aspose.slides.SaveFormat"%>
<%@page import="com.aspose.slides.ISlide"%>
<%@page import="com.aspose.slides.Presentation"%>
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
//Load first PPT File
Presentation prest1 = new Presentation("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx");

//Load second PPT File
Presentation prest2 = new Presentation("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\web_sample.pptx");

Presentation prest3 = new Presentation("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\1.pptx");


//Merge
for (ISlide slide : prest2.getSlides()) {
	// Merge from source to target
	prest1.getSlides().addClone(slide);
}

for (ISlide slide : prest3.getSlides()) {
	// Merge from source to target
	prest1.getSlides().addClone(slide);
}


//Save the File
prest1.save("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\merged-presentation.pptx", SaveFormat.Pptx);  



//파일 저장하기
	//String fileName = "ex.pptx";
	String fileName = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\merged-presentation.pptx";
	
	
	
	//파일 저장하기
	File dFile = new File(fileName);
	FileInputStream in = new FileInputStream(fileName);
	int fSize = (int)dFile.length();
	
	fileName = new String(fileName.getBytes("utf-8"),"8859_1");
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition","attachment; filename=mergeed-presentation.pptx");
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