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
		String pl = request.getParameter("pl");
		String rms_dl = request.getParameter("rms_dl");
		/* String bbsContent = request.getParameter("content");
		String bbsEnd = request.getParameter("end"); */
		String progress = request.getParameter("progress");
		String state = "";
		//금주,차주 개수
		int chk = Integer.parseInt(request.getParameter("chk"));
		int nchk = Integer.parseInt(request.getParameter("nchk"));
		
		if(progress.equals("완료")) {
			state = "#00ff00";
		}else if(progress.equals("진행중")) {
			state = "#ffff00";
		} else {
			state = "#ff0000";
		} 
		String note = request.getParameter("note");
		/* String bbsNContent = request.getParameter("ncontent");
		String bbsNTarget = request.getParameter("ntarget"); */
		String nnote = request.getParameter("nnote");
		//String sign = "미승인";
		java.sql.Timestamp summaryDate = rms.getDateNow();
	
		int num = -1;
		int nnum = -1;
 		//금주 저장
		for(int i=0; i < chk; i++) {
			String bbsContent = request.getParameter("content"+i); 
			String bbsEnd = request.getParameter("end"+i); 
			num = sumDAO.SummaryWrite(pl, rms_dl, bbsContent, bbsEnd, progress, state, note, "T", "미승인", summaryDate, id);
		}
		//차주 저장
		for(int i=0; i < nchk; i++) {
			String bbsNContent = request.getParameter("ncontent"+i); 
			String bbsNTarget = request.getParameter("ntarget"+i); 
			nnum = sumDAO.SummaryWrite(pl, rms_dl, bbsNContent, bbsNTarget, null, null, nnote, "N", "미승인", summaryDate, id);
		}
		//(id, rms_dl, pl, bbsContent, bbsEnd, progress, state, note, bbsNContent, bbsNTarget, nnote, summaryDate, name);
		
		if(num == -1 || nnum == -1){
			sumDAO.deleteSum(rms_dl, pl);
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정상적으로 요약본이 제출되었습니다.')");
			script.println("location.href='../summaryRk.jsp'");
			script.println("</script>");
		}   
	} 

	%>

</body>
</html>