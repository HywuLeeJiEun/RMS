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

		
		//줄 개수
		int trCnt = Integer.parseInt(request.getParameter("trCnt"));
		int trNCnt = Integer.parseInt(request.getParameter("trNCnt"));

		
		// 로그인을 한 사람만 글을 쓸 수 있도록 코드를 수정한다
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 되어 있지 않습니다. 로그인 후 사용해주시길 바랍니다.')");
			script.println("location.href='../../login.jsp'");
			script.println("</script>");
		} else {
		
		String rms_sign= request.getParameter("rms_sign");
		
		
		//필요한 데이터 추출
		String user_id = request.getParameter("user_id");
		String rms_dl = request.getParameter("bbsDeadline");	
		String rms_title = request.getParameter("bbsTitle");
		java.sql.Timestamp date = rms.getDateNow();
		
		// ********** 담당자를 가져오기 위한 메소드 *********** 
		String workSet;
		ArrayList<String> code = userDAO.getCode(user_id); //코드 리스트 출력(rmsmgrs에 접근하여, task_num을 가져옴.)
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
		
		int n = 0;
		int nn = 0;
		int an = 0;
		
		//데이터 sign을 보류로 변경 (기존데이터(rms_dl)를 살려둠)
		rms.updateSign(user_id, "보류", rms_dl);
		
		
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
			
			//bbsend - 진행율/완료일  ( - => / )
			String d = "bbsEnd";
			String bbsend = "";
			if(request.getParameter(a+i) != null) {
				if(request.getParameter(d+i).isEmpty() || request.getParameter(d+i) == null) {
					bbsend = "[보류]";
				} else {
					if(request.getParameter(d+i).indexOf("-") > -1) {
						bbsend = request.getParameter(d+i).trim().replaceAll("-", "/");	
					} else {
						bbsend = request.getParameter(d+i).trim();	
					}
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
				int numlist = rms.writeRms(rms_sign, user_id, rms_dl, rms_title, rms_job, recon, bbsstart, bbstarget, bbsend, "T", date);
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
					int numlist = rms.writeRms(rms_sign, user_id, rms_dl, rms_title, rms_job, recon, bbsstart, bbstarget, null, "N", date);
					if(numlist == -1) { //데이터 저장 오류가 발생하면, 데이터 삭제
						/* rms.RmsdeleteSign(user_id, rms_dl, rms_sign); //보류가 아닌, 새로 생성된 데이터를 삭제
						rms.updateSign(user_id, rms_sign, rms_dl); //보류 처리된 데이터를 다시 변경 (rms_sign으로)
						PrintWriter script = response.getWriter();
						script.println("<script>");
						script.println("alert('(차주)데이터 수정에 오류가 발생하였습니다. \\n관리자에게 문의 바랍니다.')");
						script.println("history.back();");
						script.println("</script>"); */
						nn = -1;
					} 
				} 
			}
			

			
			if(n == -1 || nn == -1 ) { //llist.size() != 0
				//위에서 생성된 데이터를 지움.
				rms.RmsdeleteSign(user_id, rms_dl, rms_sign); //보류가 아닌, 새로 생성된 데이터를 삭제
				rms.updateSign(user_id, rms_sign, rms_dl); //이전 데이터를 다시 복구시킴. (보류 -> rms_sign)
				PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('수정에 문제가 발생하였습니다.')");
				script.println("history.back();");
				script.println("</script>");
			} else {
					//보류로 저장된 이전 데이터를 제거해야함! (이때, 헷갈리지 않도록 user_user_id도 검색 조건에 넣음.)
					rms.RmsdeleteSign(user_id, rms_dl, "보류"); //보류로 생성된 이전의 데이터를 삭제
					
					//pptxrms에도 수정사항 입력,
						//pptxrms 기존 데이터 제거
					rms.pptxdelete(user_id, rms_dl);
					
					//2. rms 데이터 생성
					//데이터 불러오기 (this, next)
					//금주
					ArrayList<rmsrept> rms_this = rms.getRmsOne(rms_dl, user_id,"T");
					//차주
					ArrayList<rmsrept> rms_next = rms.getRmsOne(rms_dl, user_id,"N");
					//데이터 가공하기
					String bbsManager = workSet + userDAO.getName(user_id);
					String bbsContent = "";
					String bbsStart = "";
					String bbsTarget = "";
					String bbsEnd = "";
					String bbsNContent = "";
					String bbsNStart = "";
					String bbsNTarget = "";
					//금주 업무 (this)
					for(int j=0; j < rms_this.size(); j++) {
						//content, ncotent의 줄바꿈 개수만큼 추가함
						int num = rms_this.get(j).getRms_con().split(System.lineSeparator()).length-1;
							if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
								if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
									bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
								} else {
									bbsContent += "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
								}
							} else {
								if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
									bbsContent += "- "+rms_this.get(j).getRms_con() + System.lineSeparator();
								} else {
									bbsContent += "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con() + System.lineSeparator();
								}
							}
							//bbsContent += rms_this.get(j).getRms_con() + System.lineSeparator();
							 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
							 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
							 	bbsTarget += "[보류]" + System.lineSeparator();
							 } else {
								 if(rms_this.get(j).getRms_tar().length() > 5) {
								 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
								 }else {
									 bbsTarget += "[보류]" + System.lineSeparator();
								 }
							 }
							 bbsEnd += rms_this.get(j).getRms_end() + System.lineSeparator();
							
							 for(int k=0;k < num; k ++) {
								 bbsStart +=System.lineSeparator();
								 bbsTarget +=System.lineSeparator();
								 bbsEnd +=System.lineSeparator();
							 }
					}
					//차주 (next)
					for(int j=0; j < rms_next.size(); j++) {
						//content, ncotent의 줄바꿈 개수만큼 추가함
						int nnum = rms_next.get(j).getRms_con().split(System.lineSeparator()).length-1;
							if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
								if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
									bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
								} else {
									bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
								}
							} else { // - 가 없는 경우! 
								if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
									bbsNContent += "- "+rms_next.get(j).getRms_con() + System.lineSeparator();
								} else {
									bbsNContent += "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
								}
							} 
							//bbsNContent += rms_next.get(j).getRms_con() + System.lineSeparator();
							 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
							 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
								 bbsNTarget += "[보류]" + System.lineSeparator();
							 } else {
								 if(rms_next.get(j).getRms_tar().length() > 5) {
								 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
								 } else {
									 bbsNTarget += "[보류]" + System.lineSeparator();
								 }
							 }
							 for (int h=0; h < nnum; h++) {
								 bbsNStart += System.lineSeparator();
								 bbsNTarget += System.lineSeparator();
							 }
					}
			//3. 데이터 저장하기
			int rmsTSuc = rms.PptxRmsWrite(user_id, rms_dl, rms_title, bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", "승인");
			int rmsNSuc = rms.PptxRmsWrite(user_id, rms_dl, rms_title, bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", "승인");
			//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
			
				if(rmsTSuc == -1 || rmsNSuc == -1) {
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('최종 저장에 문제가 발생하였습니다. 관리자에게 문의 바랍니다.')");
					script.println("location.href='../login.jsp'");
					script.println("</script>");
				}
			
					
					
					PrintWriter script = response.getWriter();
					script.println("<script>");
					script.println("alert('수정이 완료되었습니다.')");
					script.println("location.href='/RMS/pl/bbsRk.jsp'");
					script.println("</script>");
				}
			} 


%>

</body>
</html>