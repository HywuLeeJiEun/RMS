<%@page import="org.apache.commons.collections.bag.SynchronizedSortedBag"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFAutoShape"%>
<%@page import="java.awt.Rectangle"%>
<%@page import="java.awt.geom.Rectangle2D"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFVMLDrawing"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFDrawing"%>
<%@page import="org.jfree.text.TextBox"%>
<%@page import="java.awt.Color"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextBox"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="rmsvation.rmsvation"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFSlide"%>
<%@page import="org.apache.poi.xslf.usermodel.XMLSlideShow"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTextRun"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFTable"%>
<%@page import="org.apache.poi.xslf.usermodel.XSLFShape"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="rmsvation.rmsvationDAO"%>
<%@page import="java.io.File"%>
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
	rmsvationDAO vacaDAO = new rmsvationDAO(); //휴가 정보
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보

	String rms_dl =(String) request.getAttribute("rms_dl");
	String[] dl = rms_dl.split("-");
	String vaca_ym = dl[0]+"-"+dl[1];
	int result = -1;
	
	//vaca_ym 정보 가져오기!
	ArrayList<rmsvation> vaca = vacaDAO.getVation(vaca_ym);
	
	// 파일이 있는지 확인
		//수정 후 파일은 name 앞에 10. 포함!
	String filePath = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\10.calendar"+dl[1]+".pptx";
	File f = new File(filePath);
	if(f.exists()) { //파일이 존재한다면,
		if(!f.isDirectory()) { // 디렉토리가 아니라면,
			//파일이 이미 존재
		}
	} else {
	
	//public에 있는 vacation pptx를 가지고옴 (토대가 됨)
	String vfile =  "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\public\\10.vacation.pptx";

	//휴가 계획을 담당하는 ppt Action (년도-월/ 에 위치. 달에 1번 필요함!)
	String file = "C:\\Users\\S-OIL\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\calendar"+dl[1]+".pptx";
	
	//슬라이드 마스터 가지고 오기
	XMLSlideShow xppt = new XMLSlideShow(new FileInputStream(file));
	XSLFSlide slide = xppt.getSlides().get(0); 
	
	XMLSlideShow vppt = new XMLSlideShow(new FileInputStream(vfile));
	XSLFSlide vslide = vppt.getSlides().get(0);
	
	
	for(int v=0; v < vaca.size(); v++) {
	//2번째 슬라이드 수정
			//검색할 날짜 구하기
			//System.out.print(vaca.get(v).getVaca_day()+"  ");
			//System.out.println(vaca.get(v).getUser_id());
			String d = vaca.get(v).getVaca_day();
			String first = d.substring(0,1).trim();
			String sec = "";
			if(d.length() == 2) {
				sec = d.substring(1,2).trim();
			}
			//유저 이름
			String name = userDAO.getName(vaca.get(v).getUser_id());
			//부가정보에 다른 모션 표시
			String info = vaca.get(v).getVaca_info();
			if(info.contains("오후")) {
				info = "◑";
			} else if (info.contains("오전")) {
				info = "◐";
			} else {
				info = "●";
			}
			
		for(XSLFShape shape : slide.getShapes()) {		
			if(shape instanceof XSLFTable) {
				XSLFTable t = (XSLFTable) shape;
				// 각, 셀마다 접근하여 확인하여야 함.
				int col = t.getNumberOfColumns();
				int row = t.getNumberOfRows();
		
				for(int i=0; i < row; i++) {
					for(int j=0; j < col; j++) {
						//모든 text를 한번씩 순회
						String text = t.getCell(i, j).getText();
						//System.out.println(text);
						//정확한 숫자 비교를 위한 2글자 추출
						String one ="";
						String two = "";
						//append 작업을 위한 숫자
						int n = -1;
						if(text.length() > 1) { //숫자가 큰 경우,
							one = text.substring(0,1).trim();
							two = text.substring(1,2).trim();
							if(one.contains(first) && two.matches("-?\\d+(\\.\\d+)?") && two.equals(sec)){
								//System.out.println(text);
								n = 1;
							} else if(one.contains(first) && !two.matches("-?\\d+(\\.\\d+)?") && !sec.matches("-?\\d+(\\.\\d+)?")){
								//System.out.println(text);
								n = 1;
							}
						} else { //숫자가 작은 경우, (1~9)
							one = text.substring(0); 
							if(one.contains(first) &&!sec.matches("-?\\d+(\\.\\d+)?")){
								//System.out.println(text);
								n = 1;
							}
						}
						
						if(n == 1) {
							//조건에 맞는 열이라면,
							XSLFTextRun run = t.getCell(i,j).appendText("\n "+info+" "+name, false);
							run.setFontSize(9.0);
							run.setFontFamily("맑은 고딕");
							break;
						}
					}
				}
			}
		}
	}
		
	FileOutputStream pout = new FileOutputStream(filePath);
	xppt.write(pout);
	pout.close();
	xppt.close(); 

	}
	
	result = 1;
	request.setAttribute("rms_dl", rms_dl);
	request.setAttribute("result", result);
	RequestDispatcher dispatcher = request.getRequestDispatcher("AllAction.jsp");
	dispatcher.forward(request, response);
%>
<a>vacationAction 페이지 입니다</a>
</body>
</html>