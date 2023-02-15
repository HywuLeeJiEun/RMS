<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
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
		script.println("location.href='login.jsp'");
		script.println("</script>");
	}
		
	// String 가져오기
	String pluser = request.getParameter("pl");
	String rms_dl = request.getParameter("rms_dl");
	String progress = request.getParameter("progress");
	int chk = Integer.parseInt(request.getParameter("chk"));
	int nchk = Integer.parseInt(request.getParameter("nchk"));
	String state = "";
	if(progress.equals("완료")) {
		state = "#00ff00";
	}else if(progress.equals("진행중")) {
		state = "#ffff00";
	} else {
		state = "#ff0000";
	} 
	String note = request.getParameter("note");
	String nnote = request.getParameter("nnote");
	String sign = request.getParameter("sign");
	if(sign == null || sign.equals("")) {
		sign = "미승인";
	}
	java.sql.Timestamp SummaryDate = rms.getDateNow();
	
	int num = -1;
	int nnum = -1;
		//금주 저장
	for(int i=0; i < chk; i++) {
		String bbsContent = request.getParameter("content"+i); 
		String bbsEnd = request.getParameter("end"+i); 
		num = sumDAO.SummaryWrite(pluser, rms_dl, bbsContent, bbsEnd, progress, state, note, "T", "보류", SummaryDate, id);
	}
	//차주 저장
	if(num != -1) {
		for(int i=0; i < nchk; i++) {
			String bbsNContent = request.getParameter("ncontent"+i); 
			String bbsNTarget = request.getParameter("ntarget"+i); 
			nnum = sumDAO.SummaryWrite(pluser, rms_dl, bbsNContent, bbsNTarget, null, null, nnote, "N", "보류", SummaryDate, id);
		}
	} else {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
		script.println("history.back();");
		script.println("</script>");
	}
	//(bbsDeadline, pluser, bbsContent, bbsEnd, progress, state, note, bbsNContent, bbsNTarget, nnote, sign, SummaryDate, SummaryUpdate);
	
	if(num == -1 || nnum == -1){
		sumDAO.deleteSumSign(rms_dl, pluser, "보류"); //수정 데이터 제거
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
		script.println("history.back();");
		script.println("</script>");
	} else {
		sumDAO.deleteSumSign(rms_dl, pluser, sign); //이전 데이터 제거
		sumDAO.signSum(sign, id, rms_dl); //수정 데이터 변경
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('정상적으로 요약본이 수정되었습니다.')");
		script.println("location.href='/BBS/pl/summaryUpdateDelete.jsp'");
		script.println("</script>");
	}  
	%>

	
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../../css/js/bootstrap.js"></script>
 	

</body>
</html>