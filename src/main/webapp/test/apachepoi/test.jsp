<%@page import="org.apache.poi.xslf.usermodel.XSLFTextRun"%>
<%@page import="org.apache.poi.sl.usermodel.TextBox"%>
<%@page import="com.google.api.services.slides.v1.model.TextRun"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextBox"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTable"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFShape"%>
<%@page import="org.apache.poi.xslf.usermodel.SlideLayout"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextShape"%>
<%@page import="java.awt.Dimension"%>
<%@page import="org.apache.poi.sl.usermodel.SlideShowFactory"%>
<%@page import="org.apache.poi.sl.usermodel.SlideShow"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideLayout"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideMaster"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlide"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XMLSlideShow"%>
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
	String file = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\1.pptx";
	
	//ppt 사이즈 새로 정하기
	int width = 820;
	int height = 595;
	
	//ppt 사이즈 구하기
	/* String[] putFiles = {file, ofile};
	for(String f : putFiles) {
		SlideShow<?,?> pptx = SlideShowFactory.create(new File(f));
		System.out.println(pptx.getPageSize());
	}  */
	
	//슬라이드 마스터 가지고 오기
	XMLSlideShow xppt = new XMLSlideShow(new FileInputStream(file));
	/* List<XSLFSlideMaster> slideM = xppt.getSlideMasters();
		//첫번째 슬라이드 마스터
	XSLFSlideMaster slideMaster = slideM.get(0);
	XSLFSlideLayout contentlayout = slideMaster.getLayout(SlideLayout.TITLE_AND_CONTENT); */
	
	
	//ppt 1.pptx -> 첫번째 슬라이드 수정
	//XSLFTextShape[] shapes = xppt.getSlides().get(0).getPlaceholders();
	XSLFSlide slide = xppt.getSlides().get(0);
	for(XSLFShape shape : slide.getShapes()) {
		shape.getAnchor();
		
		if(shape instanceof XSLFTextBox) {
			XSLFTextBox t = (XSLFTextBox) shape;
			if(t.getShapeName().contains("Rect") && t.getShapeName().contains("2")){
				//t.getCell(1,1).clearText();
				//t.getCell(1,1).addNewTextParagraph().addNewTextRun().setText("가나다라");
				XSLFTextRun run = t.setText("m월 w주차");
				run.setFontSize(19.6);
				run.setBold(true);
				run.setFontFamily("맑은 고딕");
	
			}else if(t.getShapeName().contains("Rect") && t.getShapeName().contains("3")){
				//t.getCell(1,1).clearText();
				//t.getCell(1,1).addNewTextParagraph().addNewTextRun().setText("가나다라");
				XSLFTextRun run = t.setText("[년도/월/일 ~ 년도/월/일]");
				run.setFontSize(19.6);
				run.setBold(true);
				run.setFontFamily("맑은 고딕");		
			}
		}
	}
	String Name = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\1.pptx";
	
	
	FileOutputStream pout = new FileOutputStream(Name);
	xppt.write(pout);
	pout.close();
	xppt.close();
	



%>

</body>
</html>