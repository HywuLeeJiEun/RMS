<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsrept.RmsreptDAO"%>
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
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	
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
		
		String rms_dl = request.getParameter("rms_dl");
		if(rms_dl == null || rms_dl.isEmpty()){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		}
			
		//미승인된 rms를 찾아옴.		
		ArrayList<rmsrept> list = rms.getrmsSign(id, 1);
		
		//작성자 확인
		if(!id.equals(list.get(0).getUser_id())) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('삭제 권한이 없습니다. 사용자를 확인해주십시오.')");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		} else{
			// 글 삭제 로직을 수행한다
			// 데이터 삭제
			int tdel = rms.Rmsdelete(id, rms_dl,"T");
			int ndel = rms.Rmsdelete(id, rms_dl,"N");
			int ldel = rms.edelete(id, rms_dl);		
			
			//미승인된 rms를 찾아옴.		
			ArrayList<rmsrept> aflist = rms.getrmsSign(id, 1);
			
			if(tdel == -1 || ndel == -1 || ldel == -1) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('삭제가 정상적으로 이루어지지 않았습니다. 관리자에게 문의 바랍니다.')");
					script.println("location.href='/BBS/user/bbs.jsp'");
					script.println("</script>");
				}
				else {
					// 수정 및 제출 가능한 list가 없다면,
					if(aflist.size() == 0) {
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('정상적으로 보고가 제거 되었습니다.')");
						script.println("alert('수정 및 제출 가능한 주간보고가 없습니다. 조회페이지로 이동합니다.')");
						script.println("location.href='/BBS/user/bbs.jsp'");
						script.println("</script>");
					} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('정상적으로 보고가 제거 되었습니다.')");
					script.println("location.href='/BBS/user/bbsUpdateDelete.jsp'");
					script.println("</script>");
					}
				} 
			}
	%>
	<a><%= list.size() %></a>
	
</body>
</html>