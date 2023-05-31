<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
		
		//현재날짜 구하기
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
		LocalDate nowdate = LocalDate.now();
		String now = nowdate.format(formatter);
		
	%>

	<c:set var="works" value="<%= works %>" />
	<input type="hidden" id="work" value="<c:out value='${works}'/>">
	
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
				<form method="post" action="/RMS/user/action/mainAction.jsp" id="main" name="main" onsubmit="return false">
					<table class="table" id="bbsTable" style="text-align: center; border: 1px solid #dddddd; cellpadding:50px;" >
						<thead>
							<tr>
								<th colspan="6" style="background-color: #eeeeee; text-align: center;">주간보고 작성</th>
							</tr>
						</thead>
						<tbody id="tbody">
							<tr class="ui-state-default ui-state-disabled">
									<td colspan="2"> 
									주간보고 명세서 <input type="text" required class="form-control" placeholder="주간보고 명세서" name="bbsTitle" maxlength="50"></td>
									<td colspan="1"></td>
									<td colspan="3">  주간보고 제출일 <input type="date" max="9999-12-31" style="width:80%; margin-left:20px" required class="form-control" placeholder="주간보고 날짜(월 일)" name="bbsDeadline" id="bbsDeadline" value=""></td>
							</tr>
									<tr class="ui-state-default ui-state-disabled">
										<th colspan="6" style="background-color: #D4D2FF;">금주 업무 실적
										<button type="button" style="width:55px; height:30px; display:none" id="post" class="btn btn-success pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="금주 내용을<br>차주 내용에 추가합니다.">추가</button>
										<button type="button" style="width:50px; height:30px; background-color:transparent" id="post_start" class="btn pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="금주 내용을<br>차주 내용에 추가합니다." value="false"><span class="glyphicon glyphicon-triangle-bottom"></span></button></th>
									</tr>
									<tr style="background-color: #FFC57B;" class="ui-state-default ui-state-disabled">
										<!-- <th width="6%">|  담당자</th> -->
										<th style="text-align:center" width="50%">&nbsp; 업무내용</th>
										<th style="text-align:center" width="10%">&nbsp; 접수일</th>
										<th style="text-align:center" width="10%">&nbsp; 완료목표일</th>
										<th style="text-align:center" width="10%">&nbsp;&nbsp; 진행율/<br>&nbsp;&nbsp;&nbsp;완료일</th>
										<th></th>
										<th></th>
									</tr>
									
									<tr align="center">
										<td style="display:none"><textarea class="textarea" id="bbsManager" name="bbsManager" style="height:auto; width:100%; border:none; overflow:auto" placeholder="구분/담당자"   readonly><%= workSet %><%= name %></textarea></td> 
									</tr>
									<tr>
										 <td>
										 	<div style="float:left">
											 <select name="jobs0" id="jobs0" style="height:45px; width:120px; text-align-last:center;">
													 <option> [시스템] </option>
													 <%
													 for(int count=0; count < works.size(); count++) {
														 String wo = works.get(count).replaceAll("/", "");
													 %>
													 	<option> <%= wo.trim()  %> </option>
													 <%
													 }
													 %>
													 <option> 기타 </option>
												 </select>
											 </div>
											 <div style="float:left">
											 <textarea class="textarea con" wrap="hard" id="bbsContent0" required style="height:45px;width:290px; border:none; resize:none " placeholder="업무내용" name="bbsContent0"></textarea>
											 </div>
										 </td>
										 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsStart0" class="form-control" placeholder="접수일" name="bbsStart0" value="<%= now %>" ></td>
										 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget0" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsTarget0" ></td>		
										 <td><textarea class="textarea end" id="bbsEnd0" style="height:45px; width:70px; border:none; resize:none; text-align:center"  placeholder="MM/dd" maxlength="5" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsEnd0" ></textarea></td>
										 <td><button type="button" style="margin-bottom:5px; margin-top:5px; visibility:hidden" id="delRow" name="delRow" class="btn btn-danger"> 삭제 </button></td>
										 <td><button type="button" id="paste0" class="btn btn-default paste" style="margin-bottom:5px; margin-top:5px;" onclick="paste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button>
										 	<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="chkpos" value="0"></td>
									</tr>
									</tbody>
								</table>
									<div id="wrapper" style="width:100%; text-align: center;">
										<button type="button" id="add" style="margin-bottom:15px; margin-right:30px" onclick="addRow()" class="btn btn-primary"> + </button>
									</div>	 			


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
								<th></th>
								<th></th>
							</tr>
							<tr>
								 <td>
								 	<div style="float:left">
									 <select name="njobs0" id="njobs0" style="height:45px; width:120px; text-align-last:center;">
											 <option> [시스템] </option>
											 <%
											 for(int count=0; count < works.size(); count++) {
												 String nwo = works.get(count).replaceAll("/", "");
											 %>
											 	<option> <%= nwo %> </option>
											 <%
											 }
											 %>
											 <option> 기타 </option>
										 </select>
									 </div>
									 <div style="float:left">
									 <textarea class="textarea ncon" wrap="hard" id="bbsNContent0" required style="height:45px;width:290px; border:none; resize:none" placeholder="업무내용" name="bbsNContent0"></textarea>
									 </div>
								 </td>
								 <td><input type="date" max="9999-12-31" required style="height:45px; width:auto;" id="bbsNStart0" class="form-control" placeholder="접수일" name="bbsNStart0" value="<%= now %>" ></td>
								 <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget0" class="form-control" placeholder="완료목표일" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." name="bbsNTarget0"></td>		
								 <td><button type="button" style="margin-bottom:5px; margin-top:5px; visibility:hidden" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button></td>
								 <td><button type="button" id="npaste0" class="btn btn-default npaste" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)" data-html="true" data-toggle="tooltip" data-placement="bottom" title="업무선택/접수일/완료목표일<br>복사하여 붙여넣습니다."><span class="glyphicon glyphicon-arrow-down"></span></button>
								 	<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="nchkpos" value="0>"></td>
							</tr>
							</tbody>
						</table>
						<div id="wrapper" style="width:100%; text-align: center;">
								<button type="button" id="nadd" style="margin-bottom:5px; margin-top:5px; margin-right:35px; margin-bottom:50px;" onclick="addNRow()" class="btn btn-primary"> + </button>
						</div>
						
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
								<th width="15%" style="text-align:center; border: 1px solid; font-size:10px"></th>
							</tr>
							
							</tbody>
						</table>
						<div id="wrapper_account" style="width:100%; text-align: center; display:none">
							<button type="button" style="margin-bottom:15px; margin-right:33px" onclick="addRowAccount()" class="btn btn-primary " data-toggle="tooltip" data-placement="bottom" title="ERP 디버깅 권한 신청 처리 작성"> + </button>
						</div>
						<!-- 계정 관리 끝 -->
						<div id="wrapper" style="width:100%; text-align: center;">
							<!-- 저장 버튼 생성 -->
							<button type="button" id="save" style="margin-bottom:50px" class="btn btn-primary pull-right" onclick="saveData()"> 저장 </button>									
							<button type="Submit" id="save_sub" style="margin-bottom:50px; display:none" class="btn btn-primary pull-right"> 저장 </button>
						</div>					
				</form>
			</div>
		</div>

	<!-- 현재 날짜에 대한 데이터 -->
	<textarea class="textarea" id="now" style="display:none " name="now"><%= now %></textarea>
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="https://code.jquery.com/ui/1.12.0/jquery-ui.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	<script src="/RMS/user/action/sortableAction.js"></script>
	<script src="https://rawgit.com/jackmoore/autosize/master/dist/autosize.min.js"></script>
	
	<script>
	var con = 0;
	var trCnt = 1;
	
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
				if(trCnt < 15) {
				
				var now = document.getElementById("now").value;

				//앞에 생성된 데이터의 숫자 가져오기
				var	conName = document.getElementsByClassName('con');
					con = conName[conName.length-1].getAttribute('name');
					con = Number(con.replace('bbsContent',''));
					con += 1;
		
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
	            innerHtml += ' <textarea wrap="hard" class="textarea con" id="bbsContent'+c+'" required style="height:45px;width:290px; border:none; resize:none" placeholder="업무내용" name="bbsContent'+c+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsStart'+c+'" class="form-control" placeholder="접수일" name="bbsStart'+c+'"  value="'+now+'"></td>';
	            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsTarget'+c+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsTarget'+c+'" ></td>';
	            innerHtml += '  <td><textarea class="textarea end" id="bbsEnd'+c+'" style="height:45px; resize:none; width:70px; border:none; text-align:center"  data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." maxlength="5" placeholder="MM/dd" name="bbsEnd'+c+'" ></textarea></td>'; 
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
					alert("업무 예정은 최대 15개를 넘을 수 없습니다.");
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
	var ncon = 0;
	var trNCnt = 1;
		function addNRow() {
			var strworks ="";
				
			for(var count=0; count < work.length; count++) {
				if(work[count]!="") {
					strworks += "<option>"+work[count]+ "</option>"
				}
			} 
				//var trNCnt = parseInt(document.getElementById("nlen").value) + parseInt($('#bbsNTable tr').length) + 1 - parseInt($('#bbsNTable tr').length);
				
				if(trNCnt < 15) {
				//console.log(trNCnt); // 버튼을 처음 눌렀을 때, 7 / 기본 6 -> + 누를 시, 1씩 증가
				var now = document.getElementById("now").value;
				//앞에 생성된 데이터의 숫자 가져오기
					var nconName = document.getElementsByClassName('ncon');
					ncon = nconName[nconName.length-1].getAttribute('name');
					ncon = Number(ncon.replace('bbsNContent',''));
					ncon += 1;
				
				var n = "";
				if(document.getElementsByClassName('ncon').length != 0) {
					n = ncon;
				}else {
					n = trNCnt;
				}
	            var innerHtml = "";
	            innerHtml += '<tr>';
	            innerHtml += '    <td>';
            	innerHtml += '<div style="float:left">';
	            innerHtml += '     <select name="njobs'+n+'" id="njobs'+n+'" style="height:45px; width:120px; text-align-last:center;">';
	            innerHtml += '			<option> [시스템] </option>';
	            innerHtml += strworks; 
	            innerHtml += '  <option> 기타 </option>';
	            innerHtml += ' </select>';
	            innerHtml += ' </div>';
	            innerHtml += ' <div style="float:left">';
	            innerHtml += ' <textarea wrap="hard" class="textarea ncon" id="bbsNContent'+n+'" required style="height:45px;width:290px; resize:none; border:none; " placeholder="업무내용" name="bbsNContent'+n+'"></textarea>';
	            innerHtml += '  </div> </td>';
	            innerHtml += '  <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNStart'+n+'" class="form-control" placeholder="접수일" name="bbsNStart'+n+'" value="'+now+'"></td>';
	            innerHtml += ' <td><input type="date" max="9999-12-31" style="height:45px; width:auto;" id="bbsNTarget'+n+'" data-toggle="tooltip" data-placement="bottom" title="미입력시 [보류]로 표시됩니다." class="form-control" placeholder="완료목표일" name="bbsNTarget'+n+'" ></td>';
	            innerHtml += '<td><button type="button" style="margin-bottom:5px; margin-top:5px;" id="delRow" name="delNRow" class="btn btn-danger"> 삭제 </button>';
	            innerHtml += '    </td>';
	            innerHtml += '<td><button type="button" id="npaste'+n+'" class="btn btn-default npaste" style="margin-bottom:5px; margin-top:5px;" onclick="npaste(this.id)"><span class="glyphicon glyphicon-arrow-down"></span></button>';
	            innerHtml += '<input type="checkbox" style="display:none; height:18px; width:18px; margin-top:15px" name="nchkpos" value="'+n+'">';
	            innerHtml += '    </td>';
	            innerHtml += '</tr>'; 
	            trNCnt += 1;
	            $('#bbsNTable > tbody:last').append(innerHtml);
				} else {
					alert("업무 예정은 최대 15개를 넘을 수 없습니다.");
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
		if(workSet.indexOf("계정관리") > -1) {
			// accountTable 보이도록 설정
			document.getElementById("wrapper_account").style.display="block";
		}
	});
	</script>
	
	<script>
	//줄개수(count)
	var acon = 0;
	var trACnt = 0;
	//'계정관리' 업무를 추가함.
	function addRowAccount() {
		//처음 작업시, erp 디버깅 권한 신청 처리 현황을 보이게 함.
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
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">';
		//innerHtml += '<textarea class="textarea acon" required maxlength="10" id="erp_date'+a+'"  style=" width:180px; border:none; resize:none" placeholder="YYYY-MM-DD" name="erp_date'+a+'"></textarea></td>';
		innerHtml += '<input type="date" class="acon" max="9999-12-31" required name="erp_date'+a+'" value="'+now+'"></td>'; 
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px"> ';
		innerHtml += '<textarea class="textarea" required maxlength="10" id="erp_user'+a+'"  style=" width:130px; border:none; resize:none" placeholder="사용자명" name="erp_user'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="150" id="erp_stext'+a+'"  style=" width:300px; border:none; resize:none" placeholder="변경값" name="erp_stext'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid; font-size:10px">  ';
		innerHtml += '<textarea class="textarea" required maxlength="20" id="erp_authority'+a+'"  style=" width:130px; border:none; resize:none" placeholder="ERP권한신청서번호" name="erp_authority'+a+'"></textarea></td>';
		innerHtml += '<td style="text-align:center; border: 1px solid;">  ';
		//innerHtml += '<textarea class="textarea" maxlength="2" required id="erp_division'+a+'"  style=" width:130px; border:none; resize:none" placeholder="구분(일반/긴급)" name="erp_division'+a+'"></textarea></td>';
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
	//날짜 요일 구하기
	const week = ["일","월","화","수","목","금","토"];
	
	function saveData() {
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
        	form.action = "/RMS/user/action/mainAction.jsp";
            form.mathod = "post";
            form.submit(); 
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
	// 주간보고 제출일 - 월요알이 아닌 경우, 데이터 선택이 불가하도록 변경
	const rms_dl = document.getElementById("bbsDeadline");
	
	rms_dl.addEventListener("change", function(){
		const selDate = new Date(this.value);
		const selDay = selDate.getDay(); // 선택된 날짜의 요일을 구한다. (0: 일요일, 1: 월요일 ..)
		
		if(selDay !== 1) {
			// 월요일이 아닌 경우,
			this.value = ""; //선택한 날짜를 초기화하여 선택을 제한한다.
			alert("제출일은 매주 월요일입니다. \n날짜를 확인하시어 올바른 날짜로 선택하여 주시길 바랍니다."); // 선택 제한 안내 메세지
		}
	});
	
	</script>
</body>