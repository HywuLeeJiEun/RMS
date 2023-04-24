<%@page import="org.apache.poi.xslf.usermodel.SlideLayout"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideLayout"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlideMaster"%>
<%@page import="java.util.List"%>
<%@page import="java.awt.Color"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextRun"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextBox"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFShape"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlide"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XMLSlideShow"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.SimpleDateFormat"%>
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
	//title은 주차마다 변경되기 때문에 C:\Users\gkdla\git\RMS\src\main\webapp\WEB-INF\Files\년도-월\일\ 폴더 내부에 저장
	String rms_dl = (String) request.getAttribute("rms_dl");
	String[] dl = rms_dl.split("-");

	/* ******** 몆주차인지 구하는 메소드 ******** (mon - 월 / getWeek - 주차) */
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.KOREA);	
	//int thisWeek = getWeekOfYear(sdf.format(new Date()));
	String Date = rms_dl;
	
    Calendar calendar = Calendar.getInstance();
    String[] dates = Date.split("-");
    int year = Integer.parseInt(dates[0]);
    int month = Integer.parseInt(dates[1]);
    int day = Integer.parseInt(dates[2]);
    calendar.set(year, month - 1, day);
    int getWeek = calendar.get(Calendar.WEEK_OF_YEAR);
	//월주차로 만들기
	int mon = Integer.parseInt(dates[1]);
		//달이 1개월보다 크다면, (이후부터 4주차를 계속 제거)
	if(mon > 1) { 
		getWeek = getWeek - (mon-1) * 4 ;
	}
		
	
	/* *****8 월요일, 금요일 날짜 구하기 ***** (tuesday / monday - 월요일, 금요일) */
	String tuesday = "";
	String monday ="";
	// 월요일(rms_dl)을 기준으로 화요일을 구하고, 6일을 뒤로하여 화요일을 구합니다.
	calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
	monday = sdf.format(calendar.getTime()).replaceAll("-", ".");
	calendar.add(Calendar.DATE,-6);
	calendar.set(Calendar.DAY_OF_WEEK, Calendar.TUESDAY);
	tuesday = sdf.format(calendar.getTime()).replaceAll("-", ".");
	
	
	
	
	
	//1.title.pptx 수정하여 저장하기
	String file = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\1.title.pptx";
	
	//슬라이드 마스터 가지고 오기
	XMLSlideShow xppt = new XMLSlideShow(new FileInputStream(file));
	List<XSLFSlideMaster> slideM = xppt.getSlideMasters();
		//첫번째 슬라이드 마스터
	XSLFSlideMaster slideMaster = slideM.get(0);
	XSLFSlideLayout contentlayout = slideMaster.getLayout(SlideLayout.TITLE_AND_CONTENT); 
	
	
	//ppt 1.pptx -> 첫번째 슬라이드 수정
	//XSLFTextShape[] shapes = xppt.getSlides().get(0).getPlaceholders();
	XSLFSlide slide = xppt.getSlides().get(0);
	for(XSLFShape shape : slide.getShapes()) {
		shape.getAnchor();
		
		if(shape instanceof XSLFTextBox) {
			XSLFTextBox t = (XSLFTextBox) shape;
			if(t.getShapeName().contains("Text") && t.getShapeName().contains("10")){
				XSLFTextRun run = t.setText(month+"월 "+getWeek+"주차");
				run.setFontSize(19.6);
				run.setBold(true);
				run.setFontColor(Color.black);
				run.setFontFamily("맑은 고딕");
			}else if(t.getShapeName().contains("Rect") && t.getShapeName().contains("3")){
				XSLFTextRun run = t.setText("["+tuesday+" ~ "+monday+"]");
				run.setFontSize(19.6);
				run.setBold(true);
				run.setFontFamily("맑은 고딕");		
			}
		}
	}
	
	// 저장할 경로
	String Name = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[2]+"\\title"+rms_dl+".pptx";
	
	
	FileOutputStream pout = new FileOutputStream(Name);
	xppt.write(pout);
	pout.close();
	xppt.close(); 
	
	request.setAttribute("rms_dl", rms_dl);
	RequestDispatcher dispatcher = request.getRequestDispatcher("excel.jsp");
	dispatcher.forward(request, response);

%>

<%= tuesday %>
<%= monday %>
<%= mon %>
</body>
</html>