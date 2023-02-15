<%@page import="rmssumm.rmssumm"%>
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
	} else {
		
		// String 가져오기
		String rms_dl = request.getParameter("rms_dl");
		String pl = request.getParameter("pluser");
		
		//해당 데이터로 요약본을 조회해 승인 상태 확인하기
		String sign = "";
		//금주데이터 조회하기 
		ArrayList<rmssumm> tlist = sumDAO.getSumDiv(pl, rms_dl, "T"); //sign을 확인하여 진행.
		
		if(tlist.get(0).getSum_sign().equals("승인") || tlist.get(0).getSum_sign().equals("마감")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('승인 및 마감 상태에서는 삭제가 불가합니다.')");
			script.println("history.back();'");
			script.println("</script>");
		} else {	
			int num = sumDAO.deleteSum(rms_dl, pl);
			
			if(num==-1){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
				script.println("history.back();");
				script.println("</script>");
			} else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('요약본이 삭제 되었습니다.')");
				script.println("location.href='/BBS/pl/summaryRk.jsp'");
				script.println("</script>");
			}  
		}
	}
	%>

	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../../css/js/bootstrap.js"></script>
 	

</body>
</html>