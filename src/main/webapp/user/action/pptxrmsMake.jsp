<%@page import="org.w3.x2000.x09.xmldsig.impl.X509IssuerSerialTypeImpl"%>
<%@page import="java.awt.FontMetrics"%>
<%@page import="javax.swing.SwingUtilities"%>
<%@page import="java.util.Arrays"%>
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
		
		//목록의 모든 user_id 불러오기
		ArrayList<String> userlist = userDAO.getidfull();
		//중복값 제거, '미정'값 제거
		for(int i=0; i < userlist.size(); i++) {
			if(userlist.get(i) == null || userlist.get(i).equals("미정")) {
				userlist.remove(i);
			}
		}

		
		//목록의 모든 rms_dl 불러오기
		 ArrayList<rmsrept> dllist = rms.getAllRms_dl();

		
		//모든 유저별로 데이터를 생성함! (있는 경우 제외)
		for(int u=0; u < userlist.size(); u ++) {
			String id = userlist.get(u);
			//rms에 통합 저장 진행
			//rms_dl 가져오기
			
			//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
			for(int d=0; d < dllist.size(); d++) {
				String rms_dl = dllist.get(d).getRms_dl();
				int rmsData = rms.getPptxRms(rms_dl, id);
				if(rmsData == 0) { //작성된 기록이 없다!
					
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

				
							//2. rms 데이터 생성
								//데이터 불러오기 (this, next)
								//금주
								ArrayList<rmsrept> rms_this = rms.getRmsOne(rms_dl, id,"T");
								//차주
								ArrayList<rmsrept> rms_next = rms.getRmsOne(rms_dl, id,"N");
								
								//데이터 가공하기
								String bbsManager = workSet + name;
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
									int anum = 0; //rms_this.get(j).getRms_con().split(System.lineSeparator()).length-1;
									String content = "";
										if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
											if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
												content = rms_this.get(j).getRms_con() + System.lineSeparator();
											} else {
												content = "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
											}
										} else {
											if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
												content = "- "+rms_this.get(j).getRms_con() + System.lineSeparator();
											} else {
												content = "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con() + System.lineSeparator();
											}
										}
										//content 가공하기
										content = content.replaceAll(System.lineSeparator(),""); //줄바꿈 제거
										//바이트로 자르기 (70 - 3과 1) (130 - 4와 2)
										int maxlen = 86;
										float curlen = 0;
										float addlen = 0;
										StringBuilder contentBuilder = new StringBuilder();
										String[] text = content.split(""); 
										for(int i=0; i < content.length(); i++) {								
											if(text[i].matches(".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*")) {
												//한글
												curlen += 3;
												addlen = 3;
											} else if(text[i].matches("^[a-zA-Z0-9]*$")) {
												if(Character.isLowerCase(text[i].charAt(0))) {
													//소문자라면,
													curlen += 1.5;
													addlen = (float) 1.5;
												} else {
													//대문자 라면 ...
													curlen += 2;
													addlen = 2;
												}
											}else if(text[i].matches("^[0-9]+$")){
												//숫자
												curlen += 1.5;
												addlen = (float) 1.5;
											} else {
												if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'")) { 
													//공백
													curlen += 1;
													addlen = 1;
												} else if (text[i].contains("-") || text[i].contains("[") || text[i].contains("]")) {										//특수문자
													//특정 특수문자
													curlen += 1.2;
													addlen = (float) 1.2;
												} else {
													//기타 특수문자
													curlen += 2;
													addlen = 2;
												}
											}
											if(curlen > maxlen ) { 
												if(i < content.length() -1) {
													contentBuilder.append(System.lineSeparator());
													contentBuilder.append("  ");
												} 
												contentBuilder.append(text[i]);
												curlen = 0;
												curlen += 2; //공백 2개 넣기
												curlen += addlen; 
											} else {
												contentBuilder.append(text[i]);
											}
										}
										
										if(j < rms_this.size()-1) {
										 	bbsContent += contentBuilder.toString() + System.lineSeparator();
										} else {
											bbsContent += contentBuilder.toString();
										}
										 anum = contentBuilder.toString().split(System.lineSeparator()).length-1;
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
										
										 for(int k=0;k < anum; k ++) {
											 bbsStart +=System.lineSeparator();
											 bbsTarget +=System.lineSeparator();
											 bbsEnd +=System.lineSeparator();
										 }
								}
								//차주 (next)
								for(int j=0; j < rms_next.size(); j++) {
									//content, ncotent의 줄바꿈 개수만큼 추가함
									String content = "";
										if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
											if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
												content = rms_next.get(j).getRms_con() + System.lineSeparator();
											} else {
												content = "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
											}
										} else {
											if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
												content = "- "+rms_next.get(j).getRms_con() + System.lineSeparator();
											} else {
												content = "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
											}
										}  
										//content 가공하기
										content = content.replaceAll(System.lineSeparator(),""); //줄바꿈 제거
										//바이트로 자르기 (70 - 3과 1) (130 - 4와 2)
										int maxlen = 86;
										float curlen = 0;
										float addlen = 0;
										StringBuilder contentBuilder = new StringBuilder();
										String[] text = content.split(""); 
										for(int i=0; i < content.length(); i++) {								
											if(text[i].matches(".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*")) {
												//한글
												curlen += 3;
												addlen = 3;
											} else if(text[i].matches("^[a-zA-Z0-9]*$")) {
												if(Character.isLowerCase(text[i].charAt(0))) {
													//소문자라면,
													curlen += 1.5;
													addlen = (float) 1.5;
												} else {
													//대문자 라면 ...
													curlen += 2;
													addlen = 2;
												}
											}else if(text[i].matches("^[0-9]+$")){
												//숫자
												curlen += 1.5;
												addlen = (float) 1.5;
											} else {
												if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'")) { 
													//공백
													curlen += 1;
													addlen = 1;
												} else if (text[i].contains("-") || text[i].contains("[") || text[i].contains("]")) {										//특수문자
													//특정 특수문자
													curlen += 1.2;
													addlen = (float) 1.2;
												} else {
													//기타 특수문자
													curlen += 2;
													addlen = 2;
												}
											}
											if(curlen > maxlen ) { 
												if(i < content.length() -1) {
													contentBuilder.append(System.lineSeparator());
													contentBuilder.append("  ");
												} 
												contentBuilder.append(text[i]);
												curlen = 0;
												curlen += 2; //공백 2개 넣기
												curlen += addlen; 
											} else {
												contentBuilder.append(text[i]);
											}
										}
										
										if(j < rms_this.size()-1) {
										 	bbsNContent += contentBuilder.toString() + System.lineSeparator();
										} else {
											bbsNContent += contentBuilder.toString();
										}
										 int nnum = contentBuilder.toString().split(System.lineSeparator()).length-1;
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

								int rmsTSuc = -1; int rmsNSuc = -1;
							//3. 데이터 저장하기
							if(rms_this.size() != 0) {
								rmsTSuc = rms.PptxRmsWrite(id, rms_dl, rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
								rmsNSuc = rms.PptxRmsWrite(id, rms_dl, rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
							}//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			
							
							
							if(rmsTSuc == -1 || rmsNSuc == -1) {
								PrintWriter script = response.getWriter();
								script.println("<script>");
								script.println("alert('최종 저장에 문제가 발생하였습니다. 관리자에게 문의 바랍니다.')");
								script.println("history.back;");
								script.println("</script>");
							} else {
								PrintWriter script = response.getWriter();
								script.println("<script>");
								script.println("history.back;");
								script.println("</script>");
							}
				
				}
			}

		} 
		


%>


<br>

</body>
</html>