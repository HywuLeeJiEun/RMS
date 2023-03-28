<%@page import="rmsrept.rmsrept"%>
<%@page import="java.util.ArrayList"%>
<%@page import="rmssumm.RmssummDAO"%>
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

	RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
	RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)

	String rms_dl = "2023-02-06";
	String pl = "web";

	//pl 리스트 확인 (order by - user name (이름으로 정렬))
	ArrayList<String> plist = userDAO.getpluser(pl); //pl 관련 유저의 아이디만 출력
	//pl에 해당하는 user_id 도출(pllist)
	String[] pllist = plist.toArray(new String[plist.size()]); //해당 pllist를 바꿔야함! (제출한 사람만)
	//해당 user_id를 통해 제출된 rms를 조회하기
	ArrayList<rmsrept> flist = rms.getRmsRkfull(rms_dl, pllist);

	
	//금주
	ArrayList<rmsrept> tlist = rms.getRmsRkAll(rms_dl, pllist, "T");
	//차주
	ArrayList<rmsrept> nlist = rms.getRmsRkAll(rms_dl, pllist, "N");
%>


<%= String.join(" & ",plist) %>
<%= plist.get(0) %>

<br><br>
<textarea><%= tlist.get(0).getRms_con() %></textarea>
<textarea><%= tlist.get(1).getRms_con() %></textarea>

<br><br>
<textarea><%= nlist.get(0).getRms_con() %></textarea>
<textarea><%= nlist.get(1).getRms_con() %></textarea>
</body>
</html>