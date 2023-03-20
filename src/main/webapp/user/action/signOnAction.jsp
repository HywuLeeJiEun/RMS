<%@page import="java.util.List"%>
<%@page import="rmsrept.rmsrept"%>
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
		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		} else {
			String rms_dl = request.getParameter("rms_dl");
			String name = userDAO.getName(id);
			
			// ********** 담당자를 가져오기 위한 메소드 *********** 
			String workSet;
			ArrayList<String> code = userDAO.getCode(id); //코드 리스트 출력(rmsmgrs에 접근하여, task_num을 가져옴.)
			List<String> works = new ArrayList<String>();
			
			if(code.size() == 0) {
				//1. 담당 업무가 없는 경우,
				workSet = "";
			} else {
				//2. 담당 업무가 있는 경우
				for(int i=0; i < code.size(); i++) {
					if(i < code.size()-1) {
						//task_num을 받아옴.
						String task_num = code.get(i);
						// task_num을 통해 업무명을 가져옴.
						String manager = userDAO.getManager(task_num);
						works.add(manager+"/"); //즉, work 리스트에 모두 담겨 저장됨
					} else {
						//task_num을 받아옴.
						String task_num = code.get(i);
						// task_num을 통해 업무명을 가져옴.
						String manager = userDAO.getManager(task_num);
						works.add(manager); //즉, work 리스트에 모두 담겨 저장됨
					}
				}
				workSet = String.join("\n",works) + "\n";
			}
			
			//데이터를 승인으로 변경함! 
			int num = rms.updateSign(id, "승인", rms_dl);
			
			//미승인된 rms를 찾아옴.		
			ArrayList<rmsrept> list = rms.getrmsSign(id, 1);
			
			if(num == -1) { //오류
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('데이터베이스 오류입니다. 관리자에게 문의 바랍니다.')");
				script.println("location.href='../bbs.jsp'");
				script.println("</script>");
			} else {
				if(list.size() == 0) {
					//rms에 통합 저장 진행
					//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
					int rmsData = rms.getPptxRms(rms_dl, id);
					if(rmsData == 0) { //작성된 기록이 없다!
						rms.WritePptx(rms_dl, id);
					}
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('제출이 완료되었습니다.')");
					//script.println("alert('주간보고가 모두 제출되었습니다. \\n조회 페이지로 이동합니다.')");
					//script.println("location.href='../bbs.jsp'");
					script.println("location.href='../update.jsp?rms_dl="+rms_dl+"'");
					script.println("</script>");
				} else {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('제출이 완료되었습니다.')");
					//script.println("location.href='../bbsUpdateDelete.jsp'");
					script.println("location.href='../update.jsp?rms_dl="+rms_dl+"'");
					script.println("</script>");
				}
				 
			}
		}
%>



</body>
</html>