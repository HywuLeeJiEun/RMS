<%@page import="rmsrept.rmsrept"%>
<%@page import="java.util.ArrayList"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<%
//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록

	String rms_dl = "2023-03-27";
	String id = null;
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	
	String workSet = "";
	String name = userDAO.getName(id);
	
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
			int maxlen = 85;
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
					if(Character.isLowerCase(text[i].charAt(0)) || text[i].contains("I")) {
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
					curlen += 1.6;
					addlen = (float) 1.6;
				} else {
					if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'") || text[i].contains("\"") || text[i].contains("[") || text[i].contains("]") || text[i].contains("/") || text[i].contains("(") || text[i].contains(")") || text[i].contains("-")) {
						//공백
						curlen += 1;
						addlen = 1;
					} else {
						//기타 특수문자
						curlen += 2;
						addlen = 2;
					}
				}
				if(Math.floor(curlen) >  maxlen && Math.floor(curlen)-3 <= maxlen) { //글자가 튀어나가지 않도록 함! 
					contentBuilder.append(text[i]);
					//다음 문자가 특수문자(특정)나 공백인 경우, 또는 소문자인 경우
					if(i < content.length() -1) {
						if(text[i+1].contains(" ") || text[i+1].contains(",") || text[i+1].contains("'") || text[i+1].contains("\"") || text[i+1].contains("[") || text[i+1].contains("]") || text[i+1].contains("/") || text[i+1].contains("(") || text[i+1].contains(")") || text[i+1].contains("-") || (text[i+1].matches("^[a-zA-Z0-9]*$") && Character.isLowerCase(text[i+1].charAt(0)))) {	// 다음 글자가 소문자, 공백, 숫자가 아니라면! 
							contentBuilder.append(text[i+1]);
							i++;
						} else {
							contentBuilder.append(System.lineSeparator());
							contentBuilder.append("  ");
						}
					} 
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
			int maxlen = 85;
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
					if(Character.isLowerCase(text[i].charAt(0)) || text[i].contains("I")) {
						//소문자라면, 또는 대문자 I라면(크기가 작음)
						curlen += 1.5;
						addlen = (float) 1.5;
					} else {
						//대문자 라면 ...
						curlen += 2;
						addlen = 2;
					}
				}else if(text[i].matches("^[0-9]+$")){
					//숫자
					curlen += 1.6;
					addlen = (float) 1.6;
				} else {
					if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'") || text[i].contains("\"") || text[i].contains("[") || text[i].contains("]") || text[i].contains("/") || text[i].contains("(") || text[i].contains(")") || text[i].contains("-") ) {
						//공백
						curlen += 1;
						addlen = 1;
					}  else {
						//기타 특수문자
						curlen += 2;
						addlen = 2;
					}
				}
				if(Math.floor(curlen) > maxlen && Math.floor(curlen)-3 <= maxlen) { 
					//System.out.println(Math.floor(curlen)+text[i]);
					contentBuilder.append(text[i]);
					if(i < content.length() -1) {
						if(text[i+1].contains(" ") || text[i+1].contains(",") || text[i+1].contains("'") || text[i+1].contains("\"") || text[i+1].contains("[") || text[i+1].contains("]") || text[i+1].contains("/") || text[i+1].contains("(") || text[i+1].contains(")") || text[i+1].contains("-") || (text[i+1].matches("^[a-zA-Z0-9]*$") && Character.isLowerCase(text[i+1].charAt(0)))) {	// 다음 글자가 소문자, 공백, 숫자가 아니라면! 
							contentBuilder.append(text[i+1]);
							i++;
						} else {
							contentBuilder.append(System.lineSeparator());
							contentBuilder.append("  ");
						}
					} 						
					curlen = 0;
					curlen += 2; //공백 2개 넣기
					curlen += addlen; 
				} else {
					contentBuilder.append(text[i]);
				}
			}
			
			if(j < rms_next.size()-1) {
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
	
	//3. 데이터 저장하기
	if(rms_this.size() != 0) {
	//int rmsTSuc = rms.PptxRmsWrite(id, rms_dl, rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
	//int rmsNSuc = rms.PptxRmsWrite(id, rms_dl, rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
	}//(rms_this.get(0).getUserID(), rms_this.get(0).getBbsDeadline(), rms_this.get(0).getBbsTitle(), rms_this.get(0).getBbsDate(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, bbsNContent, bbsNStart, bbsNTarget, rms_next.get(0).getPluser());			


	
	//test text 
	
	String a = "- [E-Approval] CP 전자결재를 통한 Vendor Print 관리 체계 개선";
			//a += "(with 엠로프로젝트팀)";
	String[] text = a.split(""); 
	float textlen = 0;
	for(int i=0; i < a.length(); i++) {								
		if(text[i].matches(".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*")) {
			//한글
			textlen += 3;
		} else if(text[i].matches("^[a-zA-Z0-9]*$")) {
			if(Character.isLowerCase(text[i].charAt(0)) || text[i].contains("I")) {
				//소문자라면,
				textlen += 1.5;
			} else {
				//대문자 라면 ...
				textlen += 2;
			}
		}else if(text[i].matches("^[0-9]+$")){
			//숫자
			textlen += 1.6;
		} else {
			if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'") || text[i].contains("\"")|| text[i].contains("[") || text[i].contains("]") || text[i].contains("/") || text[i].contains("-")) { 
				//공백
				textlen += 1;
			}  else {
				//기타 특수문자
				textlen += 2;
			}
		}
	}
	

%>
<a><%= a %></a><br>
<textarea><%= textlen %></textarea> <br>
<br>
<textarea><%= a.length() %></textarea>

<br><br><br><br>
<textarea><%= bbsContent %></textarea>
<br><br>
<textarea><%= bbsNContent %></textarea>

88  []
</body>
</html>