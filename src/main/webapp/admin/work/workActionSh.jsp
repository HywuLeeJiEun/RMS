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
		}
		
		//user 정보를 불러옴. (이름)
		String user_id = request.getParameter("user_id");
		//돌아간 페이지에 정보를 남기기 위함.
		request.setAttribute("searchText", userDAO.getName(user_id));
		
		
		// 업무 이름을 가져옴(TASK_WK)
		String work = request.getParameter("workValue");
		String task_num = userDAO.getTaskNum(work);
		
		//업무가 이미 저장되어 있는지 확인!
		int olp = userDAO.getMgrs(user_id, task_num);
		
		if(olp == 0) { //값이 나온다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('현재 담당하고 있는 업무입니다.')");
			script.println("history.back()");
			script.println("</script>");
		} else {
			//업무를 저장함 RMSMGRS에 insert
			int num = userDAO.inMgrs(user_id, task_num);
			
			//업무 총 개수 세기
			int count = userDAO.getCountMgrs(user_id);
			
			if(num == -1) {
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다.')");
				script.println("history.back()");
				script.println("</script>");
			} else {
				if(count != -1) {
					if(count >= 10) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('담당 업무는 최대 10개를 초과할 수 없습니다.')");
					script.println("history.back()");
					script.println("</script>");
					} else {
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('정삭적으로 추가 되었습니다.')");
						script.println("location.href='workChangesearch.jsp'");
						script.println("</script>");
						pageContext.forward("workChangesearch.jsp");
					}
				}
			}
		}		
		
		
			
			
		
		
		
		/* if(result == -1) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류입니다.')");
			script.println("history.back()");
			script.println("</script>");
		} else {
			if(code != null) { 
				if(code.size() == 10) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('담당 업무는 최대 10개를 초과할 수 없습니다.')");
					script.println("history.back()");
					script.println("</script>");	
				} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('정삭적으로 추가 되었습니다.')");
					script.println("location.href='workChangesearch.jsp'");
					script.println("</script>");
				}
			}
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('정삭적으로 추가 되었습니다.')");
			script.println("location.href='workChangesearch.jsp'");
			script.println("</script>");
			pageContext.forward("workChangesearch.jsp");
		}    */

	%>

</body>
</html>