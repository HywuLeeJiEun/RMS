<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="rmsrept.rmsrept"%>
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
	
		// 현재 세션 상태를 체크한다
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		//생성된 마지막 content의 수
		int con = Integer.parseInt(request.getParameter("con"));
		int ncon = Integer.parseInt(request.getParameter("ncon"));
		int acon = Integer.parseInt(request.getParameter("acon"));
		
		//줄 개수
		int trCnt = Integer.parseInt(request.getParameter("trCnt"));
		int trNCnt = Integer.parseInt(request.getParameter("trNCnt"));
		int trACnt = 0;
		if(request.getParameter("trACnt") != null || request.getParameter("trACnt").isEmpty()) {
			trACnt = Integer.parseInt(request.getParameter("trACnt"));
		}
		
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		} else {
			
		//erp 계정관리 권한이 있는 사용자인지 조회하기 (RMSTASK)
		String task_num = userDAO.getTask("계정관리");
		//user가 해당 권한을 부여받고 있는지 확인하기 (RMSMGRS)
		String rmsmgrs = userDAO.getMgrs(task_num); //user_id와 같은지 확인
			
		String name = userDAO.getName(id);
		
		String rms_sign="미승인";
		if(request.getParameter("rms_sign") != null) {
			rms_sign=request.getParameter("rms_sign");			
		}
		
		
		//필요한 데이터 추출
		String rms_dl = request.getParameter("bbsDeadline");		
		String rms_title = request.getParameter("bbsTitle");
		String before_dl = request.getParameter("before_dl");
		java.sql.Timestamp date = rms.getDateNow();
		
		int n = 0;
		int nn = 0;
		int an = 0;
		
		//데이터 sign을 보류로 변경 (기존데이터(before_dl)를 살려둠)
		rms.updateSign(id, "보류", before_dl);
		if(rmsmgrs.equals(id)) {
		//test -> userid 부분을 변경해 일종의 rms_sign처럼 활용
		rms.updateERPtest("test", before_dl);
		}
		
		//업데이트하는 rms_dl의 날짜 확인
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		String dl = rms_dl;
		Date time = new Date();
		String timenow = dateFormat.format(time);

		Date dldate = dateFormat.parse(dl);
		Date today = dateFormat.parse(timenow);
		
		if(!dldate.after(today) && !dldate.equals(today)) { //날짜가 이미 지났다면,
			rms_sign="마감";
		}
		
		// << 금주 데이터 저장 >> - rms_this
		for(int i=0; i < trCnt+con; i++) {
			String a = "bbsContent";
			String jobs = "jobs";
			//줄바꿈 세기
			int num = 0;
			
			//bbscontent
			String rms_job="";
			String bbscontent = "";
			if(request.getParameter(a+i) != null) {
				bbscontent = request.getParameter(a+i);
				rms_job=request.getParameter(jobs+i);
			}
			
			//bbsstart - 접수일 (not null)
			String b = "bbsStart";
			String bbsstart ="";
			if(request.getParameter(a+i) != null) {
				bbsstart = request.getParameter(b+i);
			}
			
			
			//bbstarget - 완료목표일 
			String c = "bbsTarget";
			String bbstarget = "";
			if(request.getParameter(a+i) != null) {
				if(request.getParameter(c+i).isEmpty() || request.getParameter(c+i) == null) {
					bbstarget = "";
				} else {
					bbstarget = request.getParameter(c+i);
				}
			}
			
			//bbsend - 진행율/완료일
			String d = "bbsEnd";
			String bbsend = "";
			if(request.getParameter(a+i) != null) {
				if(request.getParameter(d+i).isEmpty() || request.getParameter(d+i) == null) {
					bbsend = "[보류]";
					
				} else {
					bbsend = request.getParameter(d+i);	
				}
				
				//줄바꿈 제거(임의 변경을 최소화 하기 위함)
				bbsend = bbsend.replaceAll(System.lineSeparator(), "");

			}
			
			//content의 줄바꿈을 최소화함
			String recon = bbscontent.replaceAll(System.lineSeparator(), "§");
			for(int k=0; k < recon.split("§").length+1; k++) {
				if(recon.length() > 0 && recon.substring(recon.length()-1).equals("§")) { //맨 마지막이 줄바꿈으로 끝난다면,
					recon = recon.replaceFirst(".$", "");
				} else {
					break;
				}
			}
			recon = recon.replaceAll("§",System.lineSeparator());
			
			//update 작업 진행 (rms_this)
			if(request.getParameter(a+i) != null) { //해당 데이터가 비어있지 않고 모두 들어있다면!
				// write_rms_this
				int numlist = rms.writeRms(rms_sign, id, rms_dl, rms_title, rms_job, recon, bbsstart, bbstarget, bbsend, "T", date);
				if(numlist == -1) { //데이터 저장 오류
					/* PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('(금주)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
					script.println("history.back();");
					script.println("</script>"); */
					n = -1;
				} 
			}
		} 
			
			// << 차주 데이터 저장 >> - rms_last
			for(int i=0; i < trNCnt+ncon; i++) {
				String a = "bbsNContent";
				String jobs = "njobs";
				//줄바꿈 세기
				int num = 0;
				
				//bbscontent
				String rms_job="";
				String bbscontent = "";
				if(request.getParameter(a+i) != null) {
					bbscontent = request.getParameter(a+i);
					rms_job=request.getParameter(jobs+i);
				}
				
				//bbsstart - 접수일 
				String b = "bbsNStart";
				String bbsstart ="";
				if(request.getParameter(a+i) != null) {
					bbsstart = request.getParameter(b+i);

				}
				
				//bbstarget - 완료목표일 (null 이라면 [보류])
				String c = "bbsNTarget";
				String bbstarget = "";
				if(request.getParameter(a+i) != null) {
					if(request.getParameter(c+i).isEmpty() || request.getParameter(c+i) == null) {
						bbstarget = "";
					} else {
						bbstarget = request.getParameter(c+i);	
					}

				}
				
				//content의 줄바꿈을 최소화함
				String recon = bbscontent.replaceAll(System.lineSeparator(), "§");
				for(int k=0; k < recon.split("§").length+1; k++) {
					if(recon.length() > 0 && recon.substring(recon.length()-1).equals("§")) { //맨 마지막이 줄바꿈으로 끝난다면,
						recon = recon.replaceFirst(".$", "");
					} else {
						break;
					}
				}
				recon = recon.replaceAll("§",System.lineSeparator());
				
				// 저장에 오류가 없는지 확인!
				if(request.getParameter(a+i) != null) { //해당 데이터가 비어있지 않고 모두 들어있다면!
					// write_rms_last
					int numlist = rms.writeRms(rms_sign, id, rms_dl, rms_title, rms_job, recon, bbsstart, bbstarget, null, "N", date);
					if(numlist == -1) { //데이터 저장 오류가 발생하면, 데이터 삭제
						/* rms.RmsdeleteSign(id, rms_dl, rms_sign); //보류가 아닌, 새로 생성된 데이터를 삭제
						rms.updateSign(id, rms_sign, before_dl); //보류 처리된 데이터를 다시 변경 (rms_sign으로)
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('(차주)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
						script.println("history.back();");
						script.println("</script>"); */
						nn = -1;
					} 
				} 
			}
			
			//<< erp data 처리 >>
			String a="erp_date";
			String b="erp_user";
			String c="erp_stext";
			String d="erp_authority";
			String e="erp_division";
			//ERP 데이터가 있다면,
			//데이터를 삭제하고 다시 생성하는 방식으로 진행 -.
		
			if(rmsmgrs.equals(id)) {
				for(int i=0; i< trACnt+acon; i++){
					//edate 처리
					if(request.getParameter(a+i) != null) {	//데이터가 존재한다면, 모두 포함되어 있음!
						String edate=request.getParameter(a+i);
						String euser=request.getParameter(b+i);
						String etext=request.getParameter(c+i);
						String eau=request.getParameter(d+i);
						String ediv=request.getParameter(e+i);
						//erp 테이블에 저장
						int numelist = rms.write_erp(id, rms_dl, edate, euser, etext, eau, ediv);
						if(numelist == -1) { //데이터 저장 오류가 발생하면, 데이터 삭제
							an = -1;
						} 
					} 
				}
			}
			
			
			//미승인된 rms를 찾아옴.		
			ArrayList<rmsrept> list = rms.getrmsSign(id, 1);
			
			if(n == -1 || nn == -1 || an == -1) { //llist.size() != 0
				//위에서 생성된 데이터를 지움.
				rms.RmsdeleteSign(id, rms_dl, rms_sign); //보류가 아닌, 새로 생성된 데이터를 삭제
				rms.updateSign(id, rms_sign, before_dl); //이전 데이터를 다시 복구시킴. (보류 -> rms_sign)
				if(rmsmgrs.equals(id)) {
					rms.updateERPtest(id, before_dl);	//user_id를 다시 복구 시킴.
				}
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('수정에 문제가 발생하였습니다.')");
				script.println("history.back();");
				script.println("</script>");
			} else {
				if(list.size() != 0) {
					//보류로 저장된 이전 데이터를 제거해야함! (이때, 헷갈리지 않도록 user_id도 검색 조건에 넣음.)
					rms.RmsdeleteSign(id, before_dl, "보류"); //보류로 생성된 이전의 데이터를 삭제
					//erp user_id가 test인 데이터를 제거함.
					if(rmsmgrs.equals(id)) {
						rms.edelete("test", before_dl);
					}
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('수정이 완료되었습니다.')");
					script.println("location.href='../bbsUpdateDelete.jsp'");
					script.println("</script>");
				}else {
					//보류로 저장된 이전 데이터를 제거해야함! (이때, 헷갈리지 않도록 user_id도 검색 조건에 넣음.)
					rms.RmsdeleteSign(id, before_dl, "보류"); //보류로 생성된 이전의 데이터를 삭제
					//erp user_id가 test인 데이터를 제거함.
					if(rmsmgrs.equals(id)) {
						rms.edelete("test", before_dl);
					}
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('수정이 완료되었습니다.')");
					script.println("alert('주간보고가 모두 제출되었습니다. \\n조회 페이지로 이동합니다.')");
					script.println("location.href='../bbs.jsp'");
					script.println("</script>");
				}
			} 
		}

%>

</body>
</html>