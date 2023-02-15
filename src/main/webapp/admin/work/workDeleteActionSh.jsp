<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>O"%>
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
		
		//user 정보를 가져옴.
		String user_id = request.getParameter("user_id");
		//돌아간 페이지에 정보를 남기기 위함.
		request.setAttribute("searchText", userDAO.getName(user_id));
		
		//userid를 통해 manager를 불러옴. 배열형태로 받아와짐.
		String workSet;
		ArrayList<String> code = userDAO.getCode(user_id); //코드 리스트 출력
		List<String> works = new ArrayList<String>();
		if(code == null) {
			workSet = "";
		} else {
			for(int i=0; i < code.size(); i++) {
				
				String number = code.get(i);
				works.add(number); //즉, work 리스트에 모두 담겨 저장됨
			}
		}
	
		
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
			script.println("location.href='workChangesearch.jsp'");
			script.println("</script>");
			pageContext.forward("workChangesearch.jsp");
		}  

	%>
	
	
</body>
</html>