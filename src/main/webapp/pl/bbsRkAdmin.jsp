<%@page import="rmsrept.rmsedps"%>
<%@page import="rmssumm.rmssumm"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmssumm.RmssummDAO"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="net.sf.jasperreports.engine.type.CalculationEnum"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.util.ArrayList" %>
<% request.setCharacterEncoding("utf-8"); %>



<!DOCTYPE html>
<html>
<head>
<!-- // 폰트어썸 이미지 사용하기 -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<link rel="stylesheet" href="../css/css/bootstrap.css">
<link rel="stylesheet" href="../css/index.css">
<title>RMS</title>
</head>


<body>
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		RmssummDAO sumDAO = new RmssummDAO(); //요약본 목록 (v2.-)
		
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
				//task_num을 받아옴.
				String task_num = code.get(i);
				// task_num을 통해 업무명을 가져옴.
				String manager = userDAO.getManager(task_num);
				works.add(manager+"\n"); //즉, work 리스트에 모두 담겨 저장됨
			}
			workSet = String.join("/",works);
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
		
		if(!au.equals("PL")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/BBS/user/bbs.jsp'");
			script.println("</script>");
		}
		
		 String rms_dl = request.getParameter("rms_dl");
		 if(rms_dl == null || rms_dl.isEmpty()) {
			 PrintWriter script = response.getWriter();
				script.println("<script>");
				script.println("alert('요약본 데이터를 찾을 수 없습니다.\n다시 확인하여 주시길 바랍니다.')");
				script.println("history.back();");
				script.println("</script>");
		 }
		
		//rms_dl로 검색하여 해당 데이터를 가져옴.
		//ERP
			//금주
		ArrayList<rmssumm> etlist = sumDAO.getSumDiv("ERP", rms_dl, "T");
			//차주
		ArrayList<rmssumm> enlist = sumDAO.getSumDiv("ERP", rms_dl, "N");
		
		//WEB
			//금주
		ArrayList<rmssumm> wtlist = sumDAO.getSumDiv("WEB", rms_dl, "T");
			//차주
		ArrayList<rmssumm> wnlist = sumDAO.getSumDiv("WEB", rms_dl, "N");
	
		//erp_data 가져오기
		ArrayList<rmsedps> erp = rms.geterp(rms_dl);

		//sign 받아오기 (list가 없을 경우를 대비!)
		String getSign = "";
		if(etlist.size() == 0) {
			// 1. erp 데이터가 없고,
			if(wtlist.size() == 0) {
				// 1-1. web 데이터도 없다면!
				getSign = "미승인";
			} else {
				// 1-2. web 데이터는 있다면!
				getSign = wtlist.get(0).getSum_sign();
			}
		} else {
			//1. erp가 있다면,
			getSign = etlist.get(0).getSum_sign();
		}

		
		String str = "미승인 - 관리자의 미승인 상태<br>";
		str += "승인 - 관리자가 확정한 상태<br>";
		str += "마감 - 기한이 지나 승인된 상태";
		
		int eSize = erp.size();
		%>

	 <!-- ************ 상단 네비게이션바 영역 ************* -->
	<nav class="navbar navbar-default"> 
		<div class="navbar-header"> 
			<!-- 네비게이션 상단 박스 영역 -->
			<button type="button" class="navbar-toggle collapsed"
				data-toggle="collapse" data-target="#bs-example-navbar-collapse-1"
				aria-expanded="false">
				<!-- 이 삼줄 버튼은 화면이 좁아지면 우측에 나타난다 -->
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="/BBS/user/bbs.jsp">Report Management System</a>
		</div>
		
		<!-- 게시판 제목 이름 옆에 나타나는 메뉴 영역 -->
		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
				<ul class="nav navbar-nav navbar-left">
					<li class="dropdown ">
						<a href="#" class="dropdown-toggle"
							data-toggle="dropdown" role="button" aria-haspopup="true"
							aria-expanded="false">주간보고<span class="caret"></span></a>
						<!-- 드랍다운 아이템 영역 -->	
						<ul class="dropdown-menu">
							<li ><a href="/BBS/user/bbs.jsp">조회</a></li>
							<li><a href="/BBS/user/bbsUpdate.jsp">작성</a></li>
							<li><a href="/BBS/user/bbsUpdateDelete.jsp">수정 및 제출</a></li>
							<!-- <li><a href="signOn.jsp">승인(제출)</a></li> -->
						</ul>
					</li>
						<%
							if(au.equals("PL")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false"><%= pl %><span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><h5 style="background-color: #e7e7e7; height:40px; margin-top:-20px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %></h5></li>
								<li><a href="/BBS/pl/bbsRk.jsp">조회 및 출력</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; <%= pl %> Summary</h5></li>
								<li><a href="/BBS/pl/summaryRk.jsp">조회</a></li>
								<li id="summary_nav"><a href="/BBS/pl/bbsRkwrite.jsp">작성</a></li>
								<li><a href="/BBS/pl/summaryUpdateDelete.jsp">수정 및 삭제</a></li>
								<li><h5 style="background-color: #e7e7e7; height:40px" class="dropdwon-header"><br>&nbsp;&nbsp; [ERP/WEB] Summary</h5></li>
								<li class="active" id="summary_nav"><a href="/BBS/pl/summaryRkSign.jsp">조회 및 출력</a></li>
							</ul>
							</li>
						<%
							}
						%>
						<%
							if(au.equals("관리자") || au.equals("PL")) {
						%>
							<li class="dropdown">
							<a href="#" class="dropdown-toggle"
								data-toggle="dropdown" role="button" aria-haspopup="true"
								aria-expanded="false">summary<span class="caret"></span></a>
							<!-- 드랍다운 아이템 영역 -->	
							<ul class="dropdown-menu">
								<li><a href="/BBS/admin/summaryadRk.jsp">조회 및 승인</a></li>
								<!-- <li><a href="/BBS/admin/summaryadAdmin.jsp">작성</a></li>
								<li><a href="/BBS/admin/summaryadUpdateDelete.jsp">수정 및 승인</a></li> -->
								<!-- <li data-toggle="tooltip" data-html="true" data-placement="right" title="승인처리를 통해 제출을 확정합니다."><a href="bbsRkAdmin_backup.jsp">승인</a></li> -->
							</ul>
							</li>
						<%
							}
						%>
				</ul>
			
		
			
			<!-- 헤더 우측에 나타나는 드랍다운 영역 -->
			<ul class="nav navbar-nav navbar-right">
				<li><a data-toggle="modal" href="#UserUpdateModal" style="color:#2E2E2E"><%= name %>(님)</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle"
						data-toggle="dropdown" role="button" aria-haspopup="true"
						aria-expanded="false">관리<span class="caret"></span></a>
					<!-- 드랍다운 아이템 영역 -->	
					<ul class="dropdown-menu">
					<%
					if(au.equals("관리자") || au.equals("PL")) {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a></li>
						<li><a href="/BBS/admin/work/workChange.jsp">담당업무 변경</a></li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					} else {
					%>
						<li><a data-toggle="modal" href="#UserUpdateModal">개인정보 수정</a>
						
						</li>
						<li><a href="../logoutAction.jsp">로그아웃</a></li>
					<%
					}
					%>
					</ul>
				</li>
			</ul>
		</div>
	</nav>
	<!-- 네비게이션 영역 끝 -->
		
	
	<!-- 모달 불러오기 -->
	<div id="modalCall">
		<textarea style="display:none" id="ui"><%= id %></textarea>
		<textarea style="display:none" id="pw"><%= password %></textarea>
		<textarea style="display:none" id="nm"><%= name %></textarea>
		<textarea style="display:none" id="rn"><%= rank %></textarea>
		<textarea style="display:none" id="em"><%= email[0] %></textarea>
		<textarea style="display:none" id="ws"><%= workSet %></textarea>
		<jsp:include page="../modal.html" flush="false" />
	</div>

		
	<br>
	<div class="container-fluid" style="width:1200px">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th colspan="5" style=" text-align: center; color:black " class="form-control" data-toggle="tooltip" data-placement="bottom" title="승인(제출) 및 마감 처리시, 수정/삭제가 불가합니다." > [ERP/WEB] 요약본 수정 </th>
				</tr>
			</thead>
		</table>
	</div>
	
	
	<!-- 목록 조회 table -->
	<div class="container" id="jb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="ecomplete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="eproceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="eincomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
		 </table>
	 </div>
	 <div class="container" id="wjb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="wcomplete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="wproceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="wincomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
		 </table>
	 </div>
	 
	<div class="container-fluid" style="width:1200px">
	<form method="post" action="/BBS/admin/action/bbsRkAdminUpdate.jsp" id="bbsRk">
		<div class="row">
			<div class="container-fluid">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>			
							<% 
							String etitle = "";
							String wtitle = "";
							String di =  "";
							if(etlist.size() != 0) {
								etitle = "ERP";
							}
							if(wtlist.size() != 0) {
								wtitle = "WEB";
								di = "/";
							}
							%>
							<td style="background-color:#f9f9f9;" colspan="1" style="align:left;" >요약본</td>
							<td style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title=""> [<%= etitle + di + wtitle %>] - summary (<%= rms_dl %>)<textarea id="rms_dl" name="rms_dl" style="display:none"><%= rms_dl %></textarea></td>
							<td colspan="2"  style="background-color:#f9f9f9;"></td>
							<td  style="background-color:#f9f9f9;" colspan="1" style="txet:center">상태</td>
							<td  style="height:100%; width:100%" colspan="1" class="form-control" data-html="true" data-toggle="tooltip" data-placement="bottom" title="<%= str %>" ><%= getSign %><textarea id="sign" name="sign" style="display:none"><%= getSign %></textarea></td>
						</tr>
						<tr>
							<th colspan="6" style="background-color:#D4D2FF; align:left; border:none" > &nbsp;금주 업무 실적</th>
						</tr>
					</thead>
					<tbody>
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="6%" style="text-align: center; border: 1px solid">구분</th>
							<th width="50%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="8%" style="text-align: center; border: 1px solid">완료일</th>
							<th width="10%" style="text-align: center; border: 1px solid">진행율</th>
							<th width="5%" style="text-align: center; border: 1px solid">상태</th>
							<th width="25%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						<%
						//erp의 금주
						if(etlist.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">ERP<textarea id="estate_value" name="estate_value" style="display:none"><%= etlist.get(0).getSum_sta() %></textarea><textarea id="echk" name="echk" style="display:none"><%= etlist.size() %></textarea></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < etlist.size(); i++) { %>
								<textarea required name="econtent<%= i %>" maxlength="500" id="econtent<%= i %>" wrap="hard" style="resize: none; width:100%;"><%= etlist.get(i).getSum_con() %></textarea>
							<% } %>	
							</td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < etlist.size(); i++) { %>
								<textarea required name="eend<%= i %>" maxlength="10" id="eend<%= i %>" style="resize: none; width:100%;"><%=etlist.get(i).getSum_enta() %></textarea>
							<% } %>
							</td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid">
								<select name="eprogress" id="eprogress" style="height:45px; width:95px; text-align-last:center;" onchange="eselectPro()">
									 <option <%= etlist.get(0).getSum_pro().equals("완료")?"selected":"" %>> 완료 </option>
									 <option <%= etlist.get(0).getSum_pro().equals("진행중")?"selected":"" %>> 진행중 </option>
									 <option <%= etlist.get(0).getSum_pro().equals("미완료")?"selected":"" %>> 미완료 </option>
								</select></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="estate"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="enote" maxlength="500" id="enote" wrap="hard" style="resize: none; width:100%; height:100px"><%= etlist.get(0).getSum_note() %></textarea><textarea id="rms_dl" name="rms_dl" style="display:none"><%= rms_dl %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">ERP</td>
							<td colspan=5 style=" border: 1px solid"><br>해당 제출일로 작성된 ERP 요약본이 없습니다. </td>
						</tr>
						<%
						}
						//web 금주
						if(wtlist.size()!=0) {
						%>
						<tr>
							
							<!-- 구분 -->
							<td style="border: 1px solid; text-align: center; "><textarea id="wstate_value" name="wstate_value" style="display:none"><%= wtlist.get(0).getSum_sta() %></textarea><textarea id="wchk" name="wchk" style="display:none"><%= wtlist.size() %></textarea>WEB</td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < wtlist.size(); i++) { %>
								<textarea required name="wcontent<%= i %>" id="wcontent<%= i %>" maxlength="500" wrap="hard" style="resize: none; width:100%;"><%= wtlist.get(i).getSum_con() %></textarea>
							<% } %>	
							</td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < wtlist.size(); i++) { %>
								<textarea required name="wend<%= i %>" id="wend<%= i %>" maxlength="10" style="resize: none; width:100%;"><%= wtlist.get(i).getSum_enta() %></textarea>
							<% } %>	
							</td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid">
								<select name="wprogress" id="wprogress" style="height:45px; width:95px; text-align-last:center;" onchange="wselectPro()">
									 <option <%= wtlist.get(0).getSum_pro().equals("완료")?"selected":"" %>> 완료 </option>
									 <option <%= wtlist.get(0).getSum_pro().equals("진행중")?"selected":"" %>> 진행중 </option>
									 <option <%= wtlist.get(0).getSum_pro().equals("미완료")?"selected":"" %>> 미완료 </option>
								</select></td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="wstate"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  name="wnote" maxlength="500" id="wnote" wrap="hard" style="resize: none; width:100%; height:100px"><%=  wtlist.get(0).getSum_note() %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">WEB</td>
							<td colspan=5 style=" border: 1px solid"><br>해당 제출일로 작성된 WEB 요약본이 없습니다. <br></td>
						</tr>
						<%
						}
						%>
						<tr>
							<td></td>
						</tr>
					</tbody>
				</table>
				
				<!-- 차주 업무 계획 테이블 -->
				<table  class="table" style="text-align: center;">
					<thead>
						<tr>
							<td></td>
						</tr>
						<tr>
							<th colspan="5" style="background-color:#FF9900; align:left; border:none" > &nbsp;차주 업무 계획</th>
						</tr>
					</thead>
					<tbody style="border: 1px solid">
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="6%" style="text-align: center; border: 1px solid">구분</th>
							<th width="50%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="8%" style="text-align: center; border: 1px solid">완료예정</th>
							<th width="50%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						<%
						//erp 차주
						if(enlist.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">ERP<textarea id="enchk" name="enchk" style="display:none"><%= enlist.size() %></textarea></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < enlist.size(); i++) { %>	
								<textarea required name="encontent<%= i %>" wrap="hard" maxlength="500" id="encontent<%= i %>" style="resize: none; width:100%;"><%= enlist.get(i).getSum_con() %></textarea>
							<% } %>
							</td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < enlist.size(); i++) { %>	
								<textarea required name="entarget<%= i %>" id="entarget<%= i %>" maxlength="10" style="resize: none; width:100%;"><%= enlist.get(i).getSum_enta() %></textarea>
							<% } %>	
							</td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="ennote" id="ennote" maxlength="500" wrap="hard" style="resize: none; width:100%; height:100px"><%= enlist.get(0).getSum_note() %></textarea></td>
						</tr>
						<%
						} else { 
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">ERP</td>
							<td colspan=3 style=" border: 1px solid"><br>해당 제출일로 작성된 ERP 요약본이 없습니다. </td>
						</tr>
						<% 
						}
						//web 차주
						if(wnlist.size() != 0) {
						%>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid">WEB<textarea id="wnchk" name="wnchk" style="display:none"><%= wnlist.size() %></textarea></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < wnlist.size(); i++) { %>
								<textarea required name="wncontent<%= i %>" id="wncontent<%= i %>" maxlength="500" wrap="hard" style="resize: none; width:100%;"><%= wnlist.get(i).getSum_con() %></textarea>
							<% } %>	
							</td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < wnlist.size(); i++) { %>
								<textarea required name="wntarget<%= i %>" id="wntarget<%= i %>" maxlength="10" style="resize: none; width:100%;"><%= wnlist.get(i).getSum_enta() %></textarea>
							<% } %>
							</td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea name="wnnote" id="wnnote" maxlength="500" wrap="hard" style="resize: none; width:100%; height:100px"><%= wnlist.get(0).getSum_note() %></textarea></td>
						</tr>
						<%
						} else {
						%>
						<tr>
							<td style="text-align: center; border: 1px solid">WEB</td>
							<td colspan=3 style=" border: 1px solid"><br>해당 제출일로 작성된 WEB 요약본이 없습니다. </td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
				
				<%
				if(erp.size() != 0) {
				%>
				<!-- '계정 관리가 있을 경우, 생성' -->
				<table class="table" id="accountTable" style="text-align: center; cellpadding:50px; display:none;" >
					<tbody id="tbody">
					<tr>
						<th colspan="6" style="background-color: #ccffcc; border:none" align="center" data-toggle="tooltip" title="해당 데이터는 수정이 불가합니다!">ERP 디버깅 권한 신청 처리 현황</th>
					</tr>
					<tr style="background-color: #FF9933; border: 1px solid">
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">Date</th>
						<th width="10%" style="text-align:center; border: 1px solid; font-size:10px">User</th>
						<th width="45%" style="text-align:center; border: 1px solid; font-size:10px">SText(변경값)</th>
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">ERP권한신청서번호</th>
						<th width="15%" style="text-align:center; border: 1px solid; font-size:10px">구분(일반/긴급)</th>
					</tr>
						<%
						for (int i=0; i < erp.size(); i++) {
						%>
					<tr>
						<td style="text-align:center; border: 1px solid;  background-color:white"> 
						  <textarea class="textarea" readonly style="display:none" name="erp_size"><%= erp.size() %></textarea>
						  <textarea class="textarea"  readonly id="erp_date<%= i %>" style=" width:100%; border:none; resize:none" readonly placeholder="YYYY-MM-DD" name="erp_date<%= i %>"><%= erp.get(i).getErp_date() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_user<%= i %>" style=" width:100%; border:none; resize:none" readonly  placeholder="사용자명" name="erp_user<%= i %>"><%= erp.get(i).getErp_user() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_stext<%= i %>" wrap="hard" style=" width:100%; border:none; resize:none" readonly  placeholder="변경값" name="erp_stext<%= i %>"><%= erp.get(i).getErp_text() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_authority<%= i %>" style=" width:100%; border:none; resize:none" readonly  placeholder="ERP권한신청서번호" name="erp_authority<%= i %>"><%= erp.get(i).getErp_anum() %></textarea></td>
					  	<td style="text-align:center; border: 1px solid; background-color:white">  
						  <textarea class="textarea"  readonly id="erp_division<%= i %>" style=" width:100%; border:none; resize:none " readonly  placeholder="구분(일반/긴급)" name="erp_division<%= i %>"><%= erp.get(i).getErp_div() %></textarea></td>
					</tr>
					<%
						}
					%>
					</tbody>
				</table>
				<%
				}
				%>
			</div>
		<% if(etlist.get(0).getSum_sign().equals("승인") || etlist.get(0).getSum_sign().equals("마감")) {  //승인이나 마감 상태시에만 pptx로 출력 가능!%>
				<button type="button" class="btn btn-primary pull-right" style="width:50px; text-align:center; align:center; margin-left:20px" onClick="location.href='/BBS/pl/summaryRkSign.jsp'">목록</button> 
			<% if(etlist.size() != 0 && wtlist.size() != 0) { %>
				<button type="button" class="btn btn-success pull-right" style="width:50px; text-align:center; align:center" onclick="print()">출력</button> 
			<% } %>
		<% } %> 

		</div>
	</form>
	</div>
	<br><br><br>	

	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	
	<script>
		// 자동 높이 확장 (textarea)
		$("textarea").on('input keyup keydown focusin focusout blur mousemove', function() {
			var offset = this.offsetHeight - this.clientHeight;
			var resizeTextarea = function(el) {
				$(el).css('height','auto').css('height',el.scrollHeight + offset);
			};
			$(this).on('keyup input keydown focusin focusout blur mousemove', Document ,function() {resizeTextarea(this); });
			
		});
	</script>	
	
	
	<script>
	// 상태 색상 지정
	$(document).ready(function() {
		var con = document.getElementById("eprogress").value; //완료, 진행중, 미완료(문제)
		var state = document.getElementById("estate");
		if(con == "완료") {
			state.style.backgroundColor = "#00ff00";
		} else if (con =="진행중") {
			state.style.backgroundColor = "#ffff00";
		} else {
			state.style.backgroundColor = "#ff0000";
		}
	
		var wcon = document.getElementById("wprogress").value; //완료, 진행중, 미완료(문제)
		var wstate = document.getElementById("wstate");
		if(wcon == "완료") {
			wstate.style.backgroundColor = "#00ff00";
		} else if (wcon =="진행중") {
			wstate.style.backgroundColor = "#ffff00";
		} else {
			wstate.style.backgroundColor = "#ff0000";
		}
	});
	</script>
	
	<!-- e상태 선택을 위한 script -->
	<script>
	$("#estate").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#estate");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});
	
	var con = document.getElementById("estate");
	$("#ecomplete").on('click', function() {
			con.style.backgroundColor = "#00ff00";
	});
	
	$("#eproceeding").on('click', function() {
		con.style.backgroundColor = "#ffff00";
	});

	$("#eincomplete").on('click', function() {
		con.style.backgroundColor = "#ff0000";
	});
	</script>
	
	<!-- w상태 선택을 위한 script -->
	<script>
	$("#wstate").on('click', function() {
		var con = document.getElementById("wjb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#wstate");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("wjb-text").style.display = 'none';
		}
	});
	
	var wcon = document.getElementById("wstate");
	$("#wcomplete").on('click', function() {
			wcon.style.backgroundColor = "#00ff00";
	});
	
	$("#wproceeding").on('click', function() {
		wcon.style.backgroundColor = "#ffff00";
	});

	$("#wincomplete").on('click', function() {
		wcon.style.backgroundColor = "#ff0000";
	});
	</script>
	
	<script>
	//'erp_bbs'에 데이터가 있다면,
	$(document).ready(function() {
		var eSize = <%= eSize %>;
		if(eSize >= 0) { // -1이 아니라면,
			// accountTable 보이도록 설정
			document.getElementById("accountTable").style.display="block";
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	//진행율(progess)선택을 통한 상태 변경
	function eselectPro() {
		var con = document.getElementById("estate");
		var select = document.getElementById("eprogress").value;
		if(select == "완료") {
			con.style.backgroundColor = "#00ff00";
		}else if(select == "진행중") {
			con.style.backgroundColor = "#ffff00";
		}else if(select == "미완료") {
			con.style.backgroundColor = "#ff0000";
		}else {
			con.style.backgroundColor = "#ffffff";
		}
	}
	</script>
	<script>
	//진행율(progess)선택을 통한 상태 변경
	function wselectPro() {
		var con = document.getElementById("wstate");
		var select = document.getElementById("wprogress").value;
		if(select == "완료") {
			con.style.backgroundColor = "#00ff00";
		}else if(select == "진행중") {
			con.style.backgroundColor = "#ffff00";
		}else if(select == "미완료") {
			con.style.backgroundColor = "#ff0000";
		}else {
			con.style.backgroundColor = "#ffffff";
		}
	}
	</script>
	
	<script>
	function update() {
		if(document.getElementById("econtent0") == null) { //ERP, WEB 내용이 없는 경우, 
			alert('불러올 ERP 요약본이 없습니다. 담당 파트리더에게 문의 바랍니다.');
		}
		if(document.getElementById("wcontent0") == null) { //ERP, WEB 내용이 없는 경우, 
			alert('불러올 WEB 요약본이 없습니다. 담당 파트리더에게 문의 바랍니다.');
		}
		if(document.getElementById("eprogress").value == '' || document.getElementById("eprogress").value == null) {
			alert("ERP - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		} else if (document.getElementById("wprogress").value == '' || document.getElementById("wprogress").value == null) { 
			alert("WEB - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		}else {
			$('#bbsRk').submit();
		}
	}
	</script>
	
	<script>
	var a = "<%=rms_dl%>";
	function signOn() {
		if(document.getElementById("eprogress").value == '' || document.getElementById("eprogress").value == null) {
			alert("ERP - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		} else if (document.getElementById("wprogress").value == '' || document.getElementById("wprogress").value == null) { 
			alert("WEB - 금주 업무 실적의 '진행율'이 작성되지 않았습니다.");
		}else {
			if(confirm("해당 요약본을 승인하시겠습니까? \n승인 처리시, 수정/삭제가 불가합니다.")) {
			$('#bbsRk').attr("action","/BBS/admin/action/summaryadsignOnAction.jsp?rms_dl="+a).submit();
			} else {
				
			}
		}
	}
	</script>
	
	<script>
	function print() {
			$('#bbsRk').attr("action","/BBS/admin/pptx/pptAdmin.jsp").submit();
		}
	</script>
	
</body>
</html>