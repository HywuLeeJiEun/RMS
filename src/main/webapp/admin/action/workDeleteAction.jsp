<%@page import="rmsuser.RmsuserDAO"%>
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
		
		// 현재 세션 상태를 체크한다
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		} else {
		
			//user 정보를 불러옴.
			String user_id = request.getParameter("user_id");
		
			
			// 제거할 work가 있는지 확인. 또한 이에 대한 keycode를 파악.
			String work = request.getParameter("work");
			String workcode = userDAO. getTaskNum(work);
			
		    //RMSMGRS 목록에서 해당 업무를 제거함.
			int num = userDAO.delMgrs(user_id, workcode);
			
			if(num == -1) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다.')");
				script.println("history.back()");
				script.println("</script>");
			} else {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('정삭적으로 제거 되었습니다.')");
				script.println("location.href='/BBS/admin/work/workChange.jsp'");
				script.println("</script>");
			}  
		} 
	%>

</body>
</html>