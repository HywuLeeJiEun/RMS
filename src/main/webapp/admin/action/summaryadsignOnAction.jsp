<%@page import="rmssumm.rmssumm"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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

		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		
		String rms_dl = "";
		if(request.getParameter("rms_dl") != null) {
			rms_dl = request.getParameter("rms_dl");
		}
		
		if(rms_dl == null || rms_dl.isEmpty()) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('요약본 데이터를 찾을 수 없습니다. 확인 바랍니다.')");
			script.println("history.back();");
			script.println("</script>");
		} else {
			//elist와 tlist가 존재하는지 확인
			ArrayList<rmssumm> elist = sumDAO.getSumDiv("ERP", rms_dl, "T");
			ArrayList<rmssumm> wlist = sumDAO.getSumDiv("WEB", rms_dl, "T");
			if(elist.size() != 0 && wlist.size() != 0) {
				//sign을 승인으로 변경!
				int num = sumDAO.signSum("승인",id,rms_dl);
				
				if(num == -1) {
					//정상적으로 이루어지지 않음!
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('데이터베이스 오류입니다.(summaryadsignOnAction.jsp)\\n관리자에게 문의 바랍니다.')");
					script.println("history.back();");
					script.println("</script>");
				} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('승인이 완료되었습니다.')");
					script.println("location.href='/BBS/admin/summaryadRk.jsp'");
					script.println("</script>");
				}
			} else if(elist.size() == 0){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('작성되지 않은 요약본이 있습니다. (ERP)\\n요약본이 모두 작성되어야 승인이 가능합니다.')");
				script.println("history.back();");
				script.println("</script>");
			} else if(wlist.size() == 0){
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('작성되지 않은 요약본이 있습니다. (WEB)\\n요약본이 모두 작성되어야 승인이 가능합니다.')");
				script.println("history.back();");
				script.println("</script>");
			}
	}
%>



</body>
</html>