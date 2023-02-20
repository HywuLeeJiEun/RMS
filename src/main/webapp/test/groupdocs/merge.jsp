<%@page import="java.io.OutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page import="com.groupdocs.merger.Merger"%>
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
Merger merger = new Merger("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\요약본_sample.pptx");
merger.join("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\erp_sample.pptx");
merger.join("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\web_sample.pptx");
merger.save("C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\merged.pptx");

//파일 저장하기
	//String fileName = "ex.pptx";
	String fileName = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\merged.pptx";
	
	
	
	//파일 저장하기
	File dFile = new File(fileName);
	FileInputStream in = new FileInputStream(fileName);
	int fSize = (int)dFile.length();
	
	fileName = new String(fileName.getBytes("utf-8"),"8859_1");
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition","attachment; filename=mergeed.pptx");
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