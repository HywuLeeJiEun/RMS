<%@page import="javax.swing.RepaintManager"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>RMS</title>
</head>
<body>
	<%
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)
	
	// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	String id = null;
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	if(id == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인이 필요한 서비스입니다.')");
		script.println("location.href='../../login.jsp'");
		script.println("</script>");
	}
		
	// String 가져오기
	int echk = Integer.parseInt(request.getParameter("echk"));
	int wchk = Integer.parseInt(request.getParameter("wchk"));
	int enchk = Integer.parseInt(request.getParameter("enchk"));
	int wnchk = Integer.parseInt(request.getParameter("wnchk"));
	
	String rms_dl = request.getParameter("rms_dl");
	String sign = request.getParameter("sign");

	//ERP
	/* String econtent = request.getParameter("econtent");
	String eend = request.getParameter("eend"); */
	String eprogress = request.getParameter("eprogress");
	String estate = "";
	if(eprogress.equals("완료")) {
		estate = "#00ff00";
	}else if(eprogress.equals("진행중")) {
		estate = "#ffff00";
	} else {
		estate = "#ff0000";
	} 
	String enote = request.getParameter("enote");
	/* String encontent = request.getParameter("encontent");
	String entarget = request.getParameter("entarget"); */
	String ennote = request.getParameter("ennote");
	
	//WEB
	/* String wcontent = request.getParameter("wcontent");
	String wend = request.getParameter("wend"); */
	String wprogress = request.getParameter("wprogress");
	String wstate = "";
	if(wprogress.equals("완료")) {
		wstate = "#00ff00";
	}else if(wprogress.equals("진행중")) {
		wstate = "#ffff00";
	} else {
		wstate = "#ff0000";
	} 
	String wnote = request.getParameter("wnote");
	/* String wncontent = request.getParameter("wncontent");
	String wntarget = request.getParameter("wntarget"); */
	String wnnote = request.getParameter("wnnote");
	java.sql.Timestamp summaryDate = rms.getDateNow();
	
	int etupdate = -1;
	int enupdate = -1;
	int wtupdate = -1;
	int wnupdate = -1;
	//데이터 수정하기 (erp)
	//update가 아닌, insert로 변경!
		//금주
	for(int i=0; i < echk; i++) {
	 etupdate = sumDAO.SummaryWrite("ERP", rms_dl, request.getParameter("econtent"+i), request.getParameter("eend"+i), eprogress, estate, enote, "T", "보류", summaryDate, id);
	}
		//차주
	for(int i=0; i < enchk; i++) {
	 enupdate = sumDAO.SummaryWrite("ERP", rms_dl, request.getParameter("encontent"+i), request.getParameter("entarget"+i), eprogress, estate, enote, "N", "보류", summaryDate, id);
	}
	 //데이터 수정하기 (web)
		//금주
	for(int i=0; i < wchk; i++) {
	 wtupdate = sumDAO.SummaryWrite("WEB", rms_dl, request.getParameter("wcontent"+i), request.getParameter("wend"+i), wprogress, wstate, wnote, "T", "보류", summaryDate, id);
	}
		//차주
	for(int i=0; i < wnchk; i++) {
	 wnupdate = sumDAO.SummaryWrite("WEB", rms_dl, request.getParameter("wncontent"+i), request.getParameter("wntarget"+i), wprogress, wstate, wnote, "N", "보류", summaryDate, id);
	}
	//int erp = sumDAO.updateSum(bbsDeadline, "ERP", econtent, eend, eprogress, estate, enote, encontent, entarget, ennote, sign, summaryDate, id);
	//int web = sumDAO.updateSum(bbsDeadline, "WEB", wcontent, wend, wprogress, wstate, wnote, wncontent, wntarget, wnnote, sign, summaryDate, id);
	
	
	if(etupdate == -1 || enupdate == -1) { //erp 데이터 저장에 문제 발생!
		sumDAO.deleteSumSign(rms_dl, "ERP", "보류"); //보류 데이터 제거
		sumDAO.deleteSumSign(rms_dl, "WEB", "보류"); //보류 데이터 제거
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('ERP 데이터 저장에 문제가 발생하였습니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else if(wtupdate == -1 || wnupdate == -1) { //web 데이터 저장에 문제 발생!
		sumDAO.deleteSumSign(rms_dl, "ERP", "보류"); //보류 데이터 제거
		sumDAO.deleteSumSign(rms_dl, "WEB", "보류"); //보류 데이터 제거
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('WEB 데이터 저장에 문제가 발생하였습니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else {
		//정상적으로 모두 수정되었을 경우,
		sumDAO.deleteSumSign(rms_dl, "ERP", sign); //이전 데이터 제거
		sumDAO.deleteSumSign(rms_dl, "WEB", sign); //이전 데이터 제거
		sumDAO.signSum(sign, id, rms_dl); //수정 데이터 변경
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('요약본이 수정이 완료되었습니다.')");
		script.println("location.href='../summaryadRk.jsp'");
		script.println("</script>");
	}
	
	
	%>

 	

</body>
</html>