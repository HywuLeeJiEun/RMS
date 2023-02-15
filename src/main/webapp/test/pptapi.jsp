<%@page import="java.io.OutputStream"%>
<%@page import="java.util.List"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.*"%>
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
	//원본파일 경로
	String file = "C:\\Users\\gkdla\\git\\BBS\\src\\main\\webapp\\WEB-INF\\Files\\test.pptx";
	
	//원본파일을 읽어들인다.
	XMLSlideShow ppt = new XMLSlideShow(new FileInputStream(file));
	ppt.createSlide();
	
	//슬라이드 마스터
	XSLFSlideMaster defaultMaster = ppt.getSlideMasters().get(0);
	
	// 레이아웃을 검색해 새슬라이드를 만들 수 있다.
	XSLFSlideLayout layout 
	  = defaultMaster.getLayout(SlideLayout.TITLE_AND_CONTENT);
	
	//슬라이드를 가져옴.
	//XSLFSlide slide = ppt.createSlide(layout);
	List<XSLFSlide> slide = ppt.getSlides();
	//구성요소들을 가져옴.
	List<XSLFShape> shape = slide.get(0).getShapes();
                                                                                                           
	//구성요소에 대한 로직 (제거하고자 하는 요소를 제거함)
	for (int i=0; i < shape.size(); i++) {
	    if (shape.get(i) instanceof XSLFAutoShape) {
	        // this is a template placeholder
	        slide.get(0).removeShape(shape.get(i));
	        
	    }
	}
	
	//파일 저장하기
	String fileName = "ex.pptx";
	FileInputStream in = new FileInputStream(file);
	
	fileName = new String(fileName.getBytes("utf-8"), "8859_1");
	
	response.setContentType("application/octet-stream");
	response.setHeader("Content-Disposition", "attachment; filename=" + fileName);
	
	out.clear();
	out = pageContext.pushBody();
	
	OutputStream os = response.getOutputStream();
	
	int length;
	byte[] b = new byte[(int)file.length()];
	
	while ((length = in.read(b)) >0) {
		os.write(b,0,length);
	}
	
	os.flush();  
	
	FileOutputStream ppt_out = new FileOutputStream("powerpoint.pptx");
	ppt.write(ppt_out);
	ppt_out.close();
	ppt.close();
%>
</body>
</html>