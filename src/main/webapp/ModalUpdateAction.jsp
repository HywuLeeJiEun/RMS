<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="org.apache.catalina.UserDatabase"%>
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
		/* ********* 세션(session)을 통한 클라이언트 정보 관리 ********* */
		// 현재 세션 상태를 체크
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
	
		
		//데이터 불러오기 (Udate될 데이터들)   => 수정 가능한 Data들
		//String uid = request.getParameter("updateid");
		String upwd = request.getParameter("password"); //비밀번호
		String uname = request.getParameter("name"); //이름
		String uemail = request.getParameter("email") + "@s-oil.com"; //이메일
		
		
		// ************** 변경 ***************
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		
		int num = userDAO.UpdateUser(upwd, uname, uemail, id); 
		
		if(num == -1) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('수정이 완료되었습니다.')");
			script.println("history.back();");
			script.println("</script>");
		}
		
	
	%>
	
	<a><%= upwd %></a>
	<a><%= uname %></a>
	<a><%= uemail %></a>
	
</body>
</html>