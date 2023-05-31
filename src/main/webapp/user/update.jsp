<%@page import="java.util.Calendar"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.GregorianCalendar"%>
<%@page import="rmsrept.rmsedps"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="java.time.LocalDate"%>
<%@page import="java.util.stream.Collectors"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.tomcat.util.buf.StringUtils"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("utf-8"); %>   

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<title>RMS</title>
<link href="../css/index.css" rel="stylesheet" type="text/css">
</head>



<body>
	<!--  ********* 세션(session)을 통한 클라이언트 정보 관리 *********  -->
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		if(id == null){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('로그인이 필요한 서비스입니다.')");
			script.println("location.href='../login.jsp'");
			script.println("</script>");
		}
		
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
		
		// 사용자 정보 담기
		ArrayList<rmsuser> ulist = userDAO.getUser(id);
		String password = ulist.get(0).getUser_pwd();
		String name = ulist.get(0).getUser_name();
		String rank = ulist.get(0).getUser_rk();
		//이메일  로직 처리
		String Staticemail = ulist.get(0).getUser_em();
		String[] email;
		email = Staticemail.split("@");
		String pl = ulist.get(0).getUser_fd();
		String rk = ulist.get(0).getUser_rk();
		//사용자의 AU(Authority) 권한 가져오기 (일반/PL/관리자)
		String au = ulist.get(0).getUser_au();
		
		//기존 데이터 불러오기 (파라미터로 bbsDeadline 받기)
		String rms_dl = request.getParameter("rms_dl");
		//만약 user_id가 있다면!
		String user_id = request.getParameter("user_id");
		if(user_id == null || user_id.isEmpty()) {
			user_id = id;
		}
		// 만약 넘어온 데이터가 없다면
		if(rms_dl == null || rms_dl.isEmpty()){
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('유효하지 않은 글입니다')");
			script.println("location.href='/RMS/user/bbs.jsp'");
			script.println("</script");
		}

		
		//RMEREPT 내용 조회 (금주, 차주 나눠서 조회!)
		//금주
		ArrayList<rmsrept> tlist = rms.getRmsOne(rms_dl, user_id,"T");
		//차주
		ArrayList<rmsrept> nlist = rms.getRmsOne(rms_dl, user_id,"N");
		
		//erp 계정관리 권한이 있는 사용자인지 조회하기 (RMSTASK)
		String task_num = userDAO.getTask("계정관리");
		//user가 해당 권한을 부여받고 있는지 확인하기 (RMSMGRS)
		String rmsmgrs = userDAO.getMgrs(task_num);
		
		//erp_data 가져오기
		ArrayList<rmsedps> erp = null;
		if(rmsmgrs.equals(user_id)) {
		erp = rms.geterp(rms_dl);
		}
		int eSize = 0;
		if(erp != null) {
			eSize = erp.size();
		}
		
		// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		
		//월요일 하루 이전으로 날짜 선정
		Date SetDate = dateFormat.parse(rms_dl);
		Calendar cal = new GregorianCalendar(Locale.KOREA);
		cal.setTime(SetDate);
		//하루 전으로 설정
		cal.add(Calendar.DATE, -1);
		
		if(rms_dl.isEmpty()) { //삭제 되어 비어있다면,
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('게시글이 제거되거나 수정되었을 수 있습니다. 확인하여 주십시오.')");
			script.println("history.back()");
			script.println("</script>");
		}
		Date time = new Date();
		String timenow = dateFormat.format(time);

		Date dldate = dateFormat.parse(rms_dl);
		Date signdate = cal.getTime();
		Date today = dateFormat.parse(timenow);
		
		//현재날짜 구하기
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		LocalDate nowdate = LocalDate.now();
		String now = nowdate.format(formatter);
		
	%>
	<c:set var="works" value="<%= works %>" />
	<input type="hidden" id="work" value="<c:out value='${works}'/>">
	<input type="hidden" id="eSize" value="<%= eSize %>"/>
	<input type="hidden" id="au" value="<%= au %>"/>
       
    <!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>

	<!-- ********** 게시판 글쓰기 양식 영역 ********* -->
		<div class="container">
			<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
				<thead>
					<tr>
						<th colspan="5" style=" text-align: center; color:blue "></th>
					</tr>
				</thead>
			</table>
		</div>
		
		<div class="container">
			<div class="row">
				<form method="post"  action="/RMS/user/action/updateAction.jsp" id="main" name="main" onsubmit="return false">
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="100%" style="background-color: #eeeeee; text-align: center;">주간보고 수정</th>
							</tr>
						</thead>
						<tbody id="tbody">
							<tr class="ui-state-default ui-state-disabled">
									<td colspan="2"> 
									주간보고 명세서 <input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50" value="<%= tlist.get(0).getRms_title() %>"></td>
									<td colspan="1"></td>
									<% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
									<td colspan="3">  주간보고 제출일 <input type="date" max="9999-12-31" style="width:80%; margin-left:20px" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" id="rms_dl" value="<%= tlist.get(0).getRms_dl() %>"><textarea name="before_dl" style="display:none"><%= tlist.get(0).getRms_dl() %></textarea></td>
									<% }else { %>
									<td colspan="2">  주간보고 제출일 <input type="date" max="9999-12-31" required class="form-control" placeholder="주간보고 날짜(월 일)" name="rms_dl" value="<%= tlist.get(0).getRms_dl() %>" readonly><textarea name="rms_sign" style="display:none"><%= tlist.get(0).getRms_sign() %></textarea></td>
									<% } %>
							</tr>
									<tr class="ui-state-default ui-state-disabled">
										<th colspan="6" style="background-color: #D4D2FF;">금주 업무 실적
										<button type="button" style="width:55px; height:30px; display:none" id="post" class="btn btn-success pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="금주 내용을<br>차주 내용에 추가합니다.">추가</button>
										<button type="button" style="width:50px; height:30px; background-color:transparent" id="post_start" class="btn pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="금주 내용을<br>차주 내용에 추가합니다." value="false"><span class="glyphicon glyphicon-triangle-bottom"></span></button></th>
										
									</tr>
									<tr style="background-color: #FFC57B;" class="ui-state-default ui-state-disabled">
										<!-- <th width="6%">|  담당자</th> -->
										<th style="text-align:center" width="50%"> &nbsp; 업무내용</th>
										<th style="text-align:center" width="10%"> &nbsp; 접수일</th>
										<th style="text-align:center" width="10%"> &nbsp; 완료목표일</th>
										<th style="text-align:center" width="10%"> &nbsp;&nbsp; 진행율/<br>&nbsp;&nbsp;&nbsp;완료일</th>
										<% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
										<th></th>
										<th></th>
										<% } %>
									</tr>
									
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= name %></textarea></td> 
									</tr>
									<%
									if(tlist.size() != 0){
										for(int i=0; i<tlist.size(); i++) {
									%>
									<tr>
										 <td>
										 	<div style="float:left">
											 <select name="jobs<%= i %>" id="jobs<%= i %>" style="height:45px; width:120px; text-align-last:center;">
													 <option <%= tlist.get(i).getRms_job().equals("[시스템]")?"selected":"" %>> [시스템] </option>
													 <%
													 for(int count=0; count < works.size(); count++) {
														 String wo = works.get(count).replaceAll("/", "");
													 %>
													 	<option <%= tlist.get(i).getRms_job().equals(wo.trim())?"selected":"" %>> <%= wo.trim() %> </option>
													 <%
													 }
													 %>
													 <option <%= tlist.get(i).getRms_job().equals("기타")?"selected":"" %>> 기타 </option>
												 </select>
											 </div>
											 <div style="float:left">
											 <textarea class="textarea con" wrap="hard" id="bbsContent<%= i %>" maxlength="500" required style="height:45px;width:290px; border:none; resize:none " placeholder="업무내용" name="bbsContent<%= i %>"><%= tlist.get(i).getRms_con() %></textarea>
											 </div>
										 </td>
										 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsStart<%= i %>" class="form-control" placeholder="접수일" name="bbsStart<%= i %>" value="<%= tlist.get(i).getRms_str() %>" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget<%= i %>" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget<%= i %>" value="<%= tlist.get(i).getRms_tar() %>"></td>		
										 <td><textarea class="textarea end" id="bbsEnd<%= i %>" style="height:45px; width:70px; border:none; resize:none; text-align:center"  placeholder="MM/dd" maxlength="5" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd<%= i %>" ><%= tlist.get(i).getRms_end() %></textarea></td>
										 <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
										 <td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button></td>
										 <td><button type="button" id="paste<%= i %>" class="btn btn-default paste" style="margin-bottom:5px; margin-top:5px;" onclick="paste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button>
										 	<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="chkpos" value="<%= i %>"></td>
										<% } %>
									</tr>
									<%
										}
									}
									%>
									</tbody>
								</table>
								 <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
									<div id="wrapper" style="width:100%; text-align: center;">
										<button type="button" id="add" style="margin-bottom:15px; margin-right:30px" onclick="addRow()" class="btn btn-primary"> + </button>
									</div>	 
								<% } %>			


				<!-- 차주 업무 계획  -->
				<table class="table" id="bbsNTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
				<thead>
				</thead>
				<tbody id="tbody">
							<tr class="ui-state-default ui-state-disabled">
								<th colspan="5" style="background-color: #D4D2FF;" align="center">차주 업무 계획
								<button type="button" style="width:55px; height:30px; display:none" id="npost" class="btn btn-success pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="차주 내용을<br>금주 내용에 추가합니다.">추가</button>
								<button type="button" style="width:50px; height:30px; background-color:transparent" id="npost_start" class="btn pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="차주 내용을<br>금주 내용에 추가합니다." value="false"> <span class="glyphicon glyphicon-triangle-top"></span> </button></th>
							</tr>
							<tr style="background-color: #FFC57B;" class="ui-state-default ui-state-disabled">
								<th style="text-align:center" width="50%"> &nbsp; 업무내용</th>
								<th style="text-align:center" width="10%"> &nbsp; 접수일</th>
								<th style="text-align:center" width="10%"> &nbsp; 완료목표일</th>
								<% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
									<th></th>
									<th></th>
								<% } %>
							</tr>
							<%
							if(nlist.size() != 0){
								for(int i=0; i<nlist.size(); i++) {
							%>
							<tr>
								 <td>
								 	<div style="float:left">
									 <select name="njobs<%= i %>" id="njobs<%= i %>" style="height:45px; width:120px; text-align-last:center;">
											 <option <%= nlist.get(i).getRms_job().equals("[시스템]")?"selected":"" %>> [시스템] </option>
											 <%
											 for(int count=0; count < works.size(); count++) {
												 String nwo = works.get(count).replaceAll("/", "");
											 %>
											 	<option <%= nlist.get(i).getRms_job().equals(nwo.trim())?"selected":"" %>> <%= nwo.trim() %> </option>
											 <%
											 }
											 %>
											 <option <%= nlist.get(i).getRms_job().equals("기타")?"selected":"" %>> 기타 </option>
										 </select>
									 </div>
									 <div style="float:left">
									 <textarea class="textarea ncon" wrap="hard" id="bbsNContent<%= i %>" maxlength="500" required style="height:45px;width:290px; border:none; resize:none " placeholder="업무내용" name="bbsNContent<%= i %>"><%= nlist.get(i).getRms_con() %></textarea>
									 </div>
								 </td>
								 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsNStart<%= i %>" class="form-control" placeholder="접수일" name="bbsNStart<%= i %>" value="<%= nlist.get(i).getRms_str() %>" ></td>
								 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget<%= i %>" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget<%= i %>" value="<%= nlist.get(i).getRms_tar() %>"></td>		
								 <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
							 	<td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delNRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>
							 	<td><button type="button" id="npaste<%= i %>" class="btn btn-default npaste" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button>
							 	<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="nchkpos" value="<%= i %>"></td>
								<% } %>
							</tr>
							<%
								}
							}
							%>
							</tbody>
						</table>
						 <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
						<div id="wrapper" style="width:100%; text-align: center;">
								<button type="button" id="nadd" style="margin-bottom:5px; margin-top:5px; margin-right:35px; margin-bottom:50px;" onclick="addNRow()" class="btn btn-primary"> + </button>
						</div>
						<% } %>
						<!-- '계정 관리가 있을 경우, 생성' -->
						<table class="table" id="accountTable" style="text-align: center; cellpadding:50px; display:none;" >
							<tbody id="tbody">
							<tr>
								<th colspan="6" style="background-color: #ccffcc;" align="center">ERP 디버깅 권한 신청 처리 현황</th>
							</tr>
							<tr style="background-color: #FF9933; border: 1px solid">
								<th width="20%" style="text-align:center; border: 1px solid; font-size:10px">Date</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
								<th width="35%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
								<% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px"></th>
								<% } %>
							</tr>
							<%
							if(erp != null && erp.size() != 0){
								for(int i=0; i<erp.size(); i++) {
							%>
							<tr>
								<td style="text-align:center; border: 1px solid;  background-color:white">
								 <input type="date" class="acon" max="9999-12-31" required id="erp_date<%= i %>" name="erp_date<%= i %>" value="<%= erp.get(i).getErp_date() %>"></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea" id="erp_user<%= i %>" maxlength="10" style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user<%=i%>"><%= erp.get(i).getErp_user() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea"  id="erp_stext<%= i %>" maxlength="150" style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext<%=i%>"><%= erp.get(i).getErp_text() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; font-size:10px; background-color:white">  
								  <textarea class="textarea" id="erp_authority<%= i %>" maxlength="20" style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority<%=i%>"><%= erp.get(i).getErp_anum() %></textarea></td>
							  	<td style="text-align:center; border: 1px solid; background-color:white">  
								 <select name="erp_division<%= i %>" id="erp_division<%= i %>">
								 <option <%= erp.get(i).getErp_div().equals("일반")?"selected":"" %>>일반</option>
								 <option <%= erp.get(i).getErp_div().equals("긴급")?"selected":"" %>>긴급</option>
								 </select></td>
								  <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
								  	<td style="border: 1px solid;"><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delARow" name="delARow" class="btn btn-danger"> 삭제 </button></td>
								  <% } %>
							</tr>
							<%
								}
							}
							%>
							</tbody>
						</table>
						 <% if(nlist.get(0).getRms_sign().equals("미승인")) { %>
						<div id="wrapper_account" style="width:100%; text-align: center; display:none">
							<button type="button" style="margin-bottom:15px; margin-right:33px" onclick="addRowAccount()" class="btn btn-primary " data-toggle="tooltip" data-placement="bottom" title="ERP 디버깅 권한 신청 처리 작성"> + </button>
						</div>
						<%} %>
						<!-- 계정 관리 끝 -->
						<div id="wrapper" style="width:100%; text-align: center;">
						<!-- 목록 -->
						<a href="/RMS/user/bbs.jsp" class="btn btn-primary pull-right" style="margin-bottom:100px; margin-left:20px">목록</a>
				<%
					if(id.equals(tlist.get(0).getUser_id())) {
						if(dldate.after(today) || dldate.equals(today)){
							if(nlist.get(0).getRms_sign().equals("미승인")) {
				%>
						<!-- 승인 -->
						<a class="btn btn-success pull-right" href="/RMS/user/action/signOnAction.jsp?rms_dl=<%= tlist.get(0).getRms_dl() %>" onclick="return confirm('제출하시겠습니까?\n제출시, 수정/삭제가 불가합니다.');"> 제출 </a>
						<!-- 삭제 -->
						<a onclick="return confirm('해당 게시글을 삭제하시겠습니까?')"
									href="/RMS/user/action/deleteAction.jsp?rms_dl=<%= rms_dl %>" class="btn btn-danger pull-right" style="margin-bottom:100px; margin-right:20px">삭제</a>
						<!-- 수정 버튼 생성 -->
						<button type="button" id="save" style="margin-bottom:50px; margin-right:20px" class="btn btn-info pull-right" onclick="saveData()"> 수정 </button>									
						<button type="Submit" id="save_sub" style="margin-bottom:50px; display:none" class="btn btn-primary pull-right"> 저장 </button>	
				<%
							} else if (nlist.get(0).getRms_sign().equals("승인") && signdate.after(today)) {
								%>
								<!-- 승인 취소 -->
								<button type="button" id="revert" style="margin-bottom:50px;" class="btn btn-danger pull-right" onclick="revertSign()" data-toggle="tooltip" data-html="true" data-placement="bottom" title="미제출로 변경합니다."> 변경 </button>	
								<% 
							}
						} 
					}				
				%>
					</div>					
				</form>
			</div>
		</div>

	<!-- 현재 날짜에 대한 데이터 -->
	<textarea class="textarea" id="now" style="display:none " name="now"><%= now %></textarea>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="https://code.jquery.com/ui/1.12.0/jquery-ui.min.js"></script>
	<!-- auto size를 위한 라이브러리 -->
	<script src="https://rawgit.com/jackmoore/autosize/master/dist/autosize.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	<script src="/RMS/user/action/sortableAction.js"></script>
	
	<script>
	var con = document.getElementsByClassName('con').length;
	var trCnt = <%= tlist.size() %>;
	
	var work = "";
	work = document.getElementById("work").value;
	work = work.replaceAll("[","");
	work = work.replaceAll("]","");
	work = work.replaceAll(/\n/g,"");
	work = work.replaceAll("/","");
	work = work.split(',');
		function addRow() {
			var strworks ="";
		
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			 	//console.log(work[count]);
			} 
				//var trCnt = $('#bbsTable tr').length;
				//var trCnt = parseInt(document.getElementById("len").value) + parseInt($('#bbsTable tr').length) + 1 - parseInt($('#bbsTable tr').length);
				
				//console.log(trCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				var count = 15;
				if(trCnt > 15) {
					count = 30;
				} 
				
				if(trCnt < count) {
				
				var now = document.getElementById("now").value;

				//앞에 생성된 데이터의 숫자 가져오기
				if(document.getElementsByClassName('con').length != 0) {
				var	conName = document.getElementsByClassName('con');
					con = conName[conName.length-1].getAttribute('name');
					con = Number(con.replace('bbsContent',''));
					con += 1;
				}
				var c = "";
				if(document.getElementsByClassName('con').length != 0) {
					c = con;
				}else {
					c = trCnt;
				}
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="jobs'+c+'" id="jobs'+c+'" style="height:45px; width:120px; text-align-last:center;">';
	            innerHtml += '			<option> [시스템] </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += ' <div style="float:left">';
	            innerHtml += ' <textarea wrap="hard" class="textarea con" id="bbsContent'+c+'" maxlength="500" required style="height:45px;width:290px; border:none; resize:none" placeholder="업무내용" name="bbsContent'+c+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsStart'+c+'" class="form-control" placeholder="접수일" required name="bbsStart'+c+'"  value="'+now+'"></td>';
	            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget'+c+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsTarget'+c+'" ></td>';
	            innerHtml += '  <td><textarea class="textarea end" id="bbsEnd'+c+'" style="height:45px; resize:none; width:70px; border:none;"  data-toggle="tooltip" maxlength="5" data-placement="bottom" title="미입력시 [보류]로 표시됩니다."  placeholder="MM/dd" name="bbsEnd'+c+'" ></textarea></td>'; 
	            innerHtml += '    <td>';
	            innerHtml += '<button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '    <td>';
	            innerHtml += '<button type="button" id="paste'+c+'" class="btn btn-default paste" style="margin-bottom:5px; margin-top:5px;" onclick="paste(this.id)"><span class="glyphicon glyphicon-arrow-down"></span></button>';
	            innerHtml += '<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="chkpos" value="'+c+'">';
	            innerHtml += '    </td>';
	            innerHtml += '</tr>'; 
	            trCnt += 1;
	            $('#bbsTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 "+count+"개를 넘을 수 없습니다.");
				}
		};
	</script>
	
	<script>
	$(document).on("click","button[name=delRow]", function() {
		var trHtml = $(this).parent().parent();
		trHtml.remove();
		trCnt --;
	});
	</script>
	
	
	<script>
	var ncon = document.getElementsByClassName('ncon').length;
	var trNCnt = <%= nlist.size() %>;
		function addNRow() {
			var strworks ="";
			
			var ncount = 15;
			//if, 저장된 개수가 15개보다 많다면, 
			if(trNCnt > 15) {
				ncount = 30;
			} 
			
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			} 
				//var trNCnt = parseInt(document.getElementById("nlen").value) + parseInt($('#bbsNTable tr').length) + 1 - parseInt($('#bbsNTable tr').length);
				
				if(trNCnt < ncount) {
				//console.log(trNCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				if(document.getElementsByClassName('ncon').length != 0) {
				var now = document.getElementById("now").value;
				//앞에 생성된 데이터의 숫자 가져오기
					var nconName = document.getElementsByClassName('ncon');
					ncon = nconName[nconName.length-1].getAttribute('name');
					ncon = Number(ncon.replace('bbsNContent',''));
					ncon += 1;
				}
				var n = "";
				if(document.getElementsByClassName('ncon').length != 0) {
					n = ncon;
				}else {
					n = trNCnt;
				}
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '<td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="njobs'+n+'" id="njobs'+n+'" style="height:45px; width:120px; text-align-last:center;">';
	            innerHtml += '			<option> [시스템] </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += ' <div style="float:left">';
	            innerHtml += ' <textarea wrap="hard" class="textarea ncon" id="bbsNContent'+n+'" maxlength="500" required style="height:45px;width:290px; resize:none; border:none; " placeholder="업무내용" name="bbsNContent'+n+'"></textarea>';
	            innerHtml += '</div> </td>';
	            innerHtml += '<td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNStart'+n+'" class="form-control" placeholder="접수일" required name="bbsNStart'+n+'" value="'+now+'"></td>';
	            innerHtml += '<td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget'+n+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsNTarget'+n+'" ></td>';
	            innerHtml += '<td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>';
	            innerHtml += '<td><button type="button" id="npaste'+n+'" class="btn btn-default npaste" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)"><span class="glyphicon glyphicon-arrow-down"></span></button>';
	            innerHtml += '<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="nchkpos" value="'+n+'"></td>';
	            innerHtml += '</tr>'; 
	            trNCnt += 1;
	            $('#bbsNTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 "+ncount+"개를 넘을 수 없습니다.");
				}

		};
	</script>
	
	<script>
		$(document).on("click","button[name=delNRow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trNCnt --;
		});
		</script>
	
	
	<textarea class="textarea" id="workSet" name="workSet" style="display:none;" readonly><%= workSet %></textarea>
	<script>
	//'계정관리' 업무를 담당하고 있다면, 
	$(document).ready(function() {
		var workSet = document.getElementById("workSet").value;
		var au = document.getElementById("au").value;
		if(trACnt > 0) {
			if(workSet.indexOf("계정관리") > -1 || au.indexOf("관리자") > -1) {
				// accountTable 보이도록 설정
				//처음 작업시, erp 디버깅 권한 신청 처리 현황을 보이게 함.
			document.getElementById("accountTable").style.display="block";
			document.getElementById("wrapper_account").style.display="block";
			}
		}
	});
	</script>
	
	<textarea class="textarea" id="workSet" name="workSet" style="display:none;" readonly><%= workSet %></textarea>
	<script>
	//'계정관리' 업무를 담당하고 있다면, 
	$(document).ready(function() {
		var workSet = document.getElementById("workSet").value;
		if(workSet.indexOf("계정관리") > -1) {
			// accountTable 보이도록 설정
			
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	//줄개수(count)
	var acon = document.getElementsByClassName('acon').length;
	var trACnt = Number(document.getElementById("eSize").value);
	//'계정관리' 업무를 추가함.
	function addRowAccount() {
		document.getElementById("accountTable").style.display="block";
		if(trACnt < 2) {//최대 5개까지 증진
			if(document.getElementsByClassName('acon').length != 0) {
				var aconName = document.getElementsByClassName('acon');
				acon = aconName[aconName.length-1].getAttribute('name');
				acon = Number(acon.replace('erp_date',''));
				acon += 1;
			}
			var a = "";
			if(document.getElementsByClassName('acon').length != 0) {
				a = acon;
			}else {
				a = trACnt;
			}
		var innerHtml = "";
		var now = document.getElementById("now").value;
		innerHtml += '<tr>';
		innerHtml += '<td style="text-align:center; border: 1px solid;">';
		//innerHtml += '<textarea class="textarea acon" required maxlength="10" id="erp_date'+a+'"  style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date'+a+'"></textarea></td>';
		innerHtml += '<input type="date" class="acon" max="9999-12-31" required name="erp_date'+a+'" value="'+now+'"></td>'; 
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px"> ';
		innerHtml += '<textarea class="textarea" required maxlength="10" id="erp_user'+a+'"  style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="150" id="erp_stext'+a+'"  style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="20" id="erp_authority'+a+'"  style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid;">  ';
		//innerHtml += '<textarea class="textarea" required maxlength="2" id="erp_division'+a+'"  style=" width:130px; border:none; resize:none" placeholder="구분(일반/긴급)" name="erp_division'+a+'"></textarea></td>';
		innerHtml += '<select name="erp_division'+a+'"><option>일반</option><option>긴급</option></select></td>';
		innerHtml += '<td style="border: 1px solid;"><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delARow" name="delARow" class="btn btn-danger"> 삭제 </button>';
        innerHtml += '    </td>';
		innerHtml +='</tr>';
		trACnt += 1;
		$('#accountTable > tbody:last').append(innerHtml);
		} else {
			alert("계정관리 업무는 최대 2개까지 작성 가능합니다.");
			}
	};
	</script>
	
	<script>
		$(document).on("click","button[name=delARow]", function() {
			var trHtml = $(this).parent().parent();
			trHtml.remove();
			trACnt --;
		});
		</script>
	
	<script>
	/* document.main.addEventListener("keydown", evt => {
		if((evt.keyCode || evt.which) === 13) {
			evt.preventDefault();
		}
	}); */
	// 데이터 보내기 (몇줄을 사용하는지!) <trCnt, trNCnt>
   // $(document).on('click', "#id" ,function(){
	//$("#save").on('click',function(){
	function saveData() {
		if(confirm('수정하시겠습니까?\n기존 데이터를 덮어씌웁니다.')) {
			if(trCnt == 0) {
				alert("금주 업무 실적에 내용이 없습니다.\n하나 이상의 내용이 보고되어야 합니다.");
			} else if (trNCnt == 0) {
				alert("차주 업무 계획에 내용이 없습니다.\n하나 이상의 내용이 보고되어야 합니다.");
			} else {
	
			var innerHtml = "";
			innerHtml += '<tr style="display:none">';
			innerHtml += '<td><textarea class="textarea" id="trCnt" name="trCnt" readonly>'+trCnt+'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="trNCnt" name="trNCnt" readonly>'+trNCnt+'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="trACnt" name="trACnt" readonly>'+trACnt+'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="con" name="con" readonly>'+con+'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="ncon" name="ncon" readonly>'+ncon+'</textarea></td>';
			innerHtml += '<td><textarea class="textarea" id="acon" name="acon" readonly>'+acon+'</textarea></td>';
			innerHtml += '</tr>';
	        $('#bbsNTable > tbody> tr:last').append(innerHtml);
	        
	 		$("#save_sub").trigger("click");
	        
	        var form = document.getElementById("main");
	        	if(form.checkValidity()) {
		        	form.action = "/RMS/user/action/updateAction.jsp";
		            form.mathod = "post";
		            form.submit(); 
	       	 }
			}
		} 
    }
	</script>
	
	
	<script>
	function paste(id) {
		//alert(id); //pasteX
		const regex = /[^0-9]/g;
		var num = id.replace(regex,"");
		//선택된 업무 내용 읽기
		var a = document.getElementById("jobs"+num);
		var jobs = a.options[a.selectedIndex].value;
		//작성된 접수일 내용
		var start = document.getElementById("bbsStart"+num).value;
		//작성된 완료목표일 내용
		var target = document.getElementById("bbsTarget"+num).value;
		
		//데이터를 계승함! 
		var tr = $("#bbsContent"+num).parent().parent().parent();
		var nexttr = tr.next();
		if(nexttr.length != 0){ //다음 데이터가 있다면, (다음 주간보고 작성이 있다는 것!)
			var b = nexttr.get(0).querySelector(".con").id;
			var unum = b.replace(regex,"");
				//1. 데이터 삽입
					//업무 내용 넣기
				$("#jobs"+(Number(unum))).val(jobs).prop("selected", true);
					//작성된 접수일 넣기
				$("#bbsStart"+(Number(unum))).val(start);
					//작성된 완료목표일 넣기
				$("#bbsTarget"+(Number(unum))).val(target);
				
		} else {
			if(trCnt < 15) {
			 	document.getElementById("add").click();
			 	paste(id);
			} else { // 15거나 이상인 경우, 
				//document.getElementById(id).style.visibility="hidden";
				alert("주간 업무 개수는 최대 15개를 넘을 수 없습니다.");
			}
		}
	}
	
	function npaste(id) {
		//alert(id); //pasteX
		const regex = /[^0-9]/g;
		var num = id.replace(regex,"");
		//선택된 업무 내용 읽기
		var a = document.getElementById("njobs"+num);
		var jobs = a.options[a.selectedIndex].value;
		//작성된 접수일 내용
		var start = document.getElementById("bbsNStart"+num).value;
		//작성된 완료목표일 내용
		var target = document.getElementById("bbsNTarget"+num).value;
		
		//데이터를 계승함! 
		var tr = $("#bbsNContent"+num).parent().parent().parent();
		var nexttr = tr.next();
		if(nexttr.length != 0){ //다음 데이터가 있다면, (다음 주간보고 작성이 있다는 것!)
			var b = nexttr.get(0).querySelector(".ncon").id;
			var unum = b.replace(regex,"");
				//1. 데이터 삽입
					//업무 내용 넣기
				$("#njobs"+(Number(unum))).val(jobs).prop("selected", true);
					//작성된 접수일 넣기
				$("#bbsNStart"+(Number(unum))).val(start);
					//작성된 완료목표일 넣기
				$("#bbsNTarget"+(Number(unum))).val(target);
				
		} else {
			if(trNCnt < 15) {
			 document.getElementById("nadd").click();
			 npaste(id);
			} else {
				alert("주간 업무 개수는 최대 15개를 넘을 수 없습니다.");
			}
		}
	}
	</script>
	
	<script>
	// revertSign() - 승인상태 되돌리기
	function revertSign() {
		if(confirm("승인 상태가 [미제출](수정 가능)로 변경됩니다.\n변경 하시겠습니까?")) {
			//확인시, 미제출로 변경
			var form = document.getElementById("main");
	        	form.action = "/RMS/user/action/DissignOnAction.jsp";
	            form.mathod = "post";
	            form.submit(); 
		}
	}
	</script>
	
	<script>
	// 주간보고 제출일 - 월요알이 아닌 경우, 데이터 선택이 불가하도록 변경
	const rms_dl = document.getElementById("rms_dl");
	
	rms_dl.addEventListener("change", function(){
		const selDate = new Date(this.value);
		const selDay = selDate.getDay(); // 선택된 날짜의 요일을 구한다. (0: 일요일, 1: 월요일 ..)
		
		if(selDay !== 1) {
			// 월요일이 아닌 경우,
			this.value = '<%= tlist.get(0).getRms_dl() %>'; //선택한 날짜를 초기화하여 선택을 제한한다.
			alert("제출일은 매주 월요일입니다. \n날짜를 확인하시어 올바른 날짜로 선택하여 주시길 바랍니다."); // 선택 제한 안내 메세지
		}
	});
	
	</script>
</body>
