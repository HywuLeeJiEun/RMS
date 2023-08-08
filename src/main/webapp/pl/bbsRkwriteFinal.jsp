<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
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


	// 선택된 데이터 정보
	/* String content = request.getParameter("content");
	String end = request.getParameter("end");
	String ncontent = request.getParameter("ncontent");
	String ntarget = request.getParameter("ntarget");
	String rms_dl = request.getParameter("rms_dl"); */
	String rms_dl = request.getParameter("rms_dl");

	String chk_arr = request.getParameter("chk_arr");
	String nchk_arr = request.getParameter("nchk_arr");

	String[] chk;
	String[] nchk;
	//chk_arr 변경 
	chk = chk_arr.split(",");
	nchk = nchk_arr.split(",");
	
%>

	<!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>
	
	<!-- 메인 게시글 영역 -->
	<br>
	<div class="container">
		<table class="table table-striped" style="text-align: center; cellpadding:50px;" >
			<thead>
				<tr>
				</tr>
				<tr>
					<th id="summary" colspan="5" style=" text-align: center; color:black " data-toggle="tooltip" data-placement="bottom" title="제출일 : <%= rms_dl %>"> 요약본 작성 </th>
				</tr>
			</thead>
		</table>
	</div>
	<br>
	
	<!-- 목록 조회 table -->
	<div class="container" id="jb-text" style="height:10%; width:10%; display:inline-flex; float:left; margin-left: 50%; display:none; position:absolute">
		<table class="table" style="text-align: center; border:1px solid #444444 ; background-color:white" >
			 <tr>
			 	<td id="complete" style="text-align: center; align:center;"><div style="border:1px solid #00ff00; background-color:#00ff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 완료</span></td>
			 </tr>
			 <tr>
			 	<td id="proceeding" style="text-align: center; align:center;"><div style="border:1px solid #ffff00; background-color:#ffff00; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 진행중</span></td>
			 </tr> 
			 <tr>
			 	<td id="incomplete" style="text-align: center; align:center;"><div style="border:1px solid #ff0000; background-color:#ff0000; width:10px; height:10px; float:left; margin-left: 35%; margin-top: 3%"></div><span style="float:left">&nbsp; : 미완료(문제)</span></td>
			 </tr> 
			 <tr>
			 </tr> 
		 </table>
	 </div>
	 
	<div class="container-fluid" style="width:1200px">
	<form method="post" action="/RMS/pl/action/bbsRkAction.jsp" id="bbsRk">
		<div class="row">
			<div class="container-fluid">
				<!-- 금주 업무 실적 테이블 -->
				<table id="Table" class="table" style="text-align: center;">
					<thead>
						<tr>
							<td><textarea id="rms_dl" name="rms_dl" style="display:none"><%= rms_dl %></textarea><textarea id="chk" name="chk" style="display:none"><%= chk.length %></textarea> </td>
							<td><textarea id="pl" name="pl" style="display:none"><%= pl %></textarea><textarea id="nchk" name="nchk" style="display:none"><%= nchk.length %></textarea> </td>
						</tr>
						<tr>
							<th colspan="100%" style="background-color:#D4D2FF; align:left; border:none" > &nbsp;금주 업무 실적</th>
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
						
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid"><%= pl %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < chk.length; i++) { %>
								<textarea required name="content<%= i %>" wrap="hard" maxlength="500" id="content<%= i %>" style="resize: none; width:100%;"><%= request.getParameter("content"+chk[i]).replaceAll(System.getProperty("line.separator"), "") %></textarea>
							<% } %>
							</td>
							<!-- 완료일 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < chk.length; i++) { %>
							<textarea required name="end<%= i %>" maxlength="10" id="end<%= i %>" style="resize: none; width:100%;"><%= request.getParameter("end"+chk[i]) %></textarea>
							<% } %>
							</td>
							<!-- 진행율 -->
							<td style="text-align: center; border: 1px solid">
								<select name="progress" id="progress" style="height:45px; width:95px; text-align-last:center;" onchange="selectPro()">
														<option> [선택] </option>
														 <option> 완료 </option>
														 <option> 진행중 </option>
														 <option> 미완료 </option>
													 </select>
								<!-- <textarea required name="progress" id="progress" style="resize: none; width:100%; height:100px"></textarea> -->
							</td>
							<!-- 상태 -->
							<td style="text-align: center; border: 1px solid;" id="state"></td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea  maxlength="500" name="note" wrap="hard" id="note" style="resize: none; width:100%; height:100px"></textarea></td>
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
							<th colspan="100%" style="background-color:#FF9900; align:left; border:none" > &nbsp;차주 업무 계획</th>
						</tr>
					</thead>
					<tbody style="border: 1px solid">
						<tr style="background-color:#FFC57B; text-align: center; align:center; ">
							<th width="6%" style="text-align: center; border: 1px solid">구분</th>
							<th width="50%" style="text-align: center; border: 1px solid">업무 내용</th>
							<th width="8%" style="text-align: center; border: 1px solid">완료예정</th>
							<th width="50%" style="text-align: center; border: 1px solid">비고</th>
						</tr>
						<tr>
							<!-- 구분 -->
							<td style="text-align: center; border: 1px solid"><%= pl %></td>
							<!-- 업무 내용 -->
							<td style=" border: 1px solid">
							<% for(int i=0; i < nchk.length; i++) { %>
								<textarea required name="ncontent<%= i %>" wrap="hard" maxlength="500" id="ncontent<%= i %>" style="resize: none; width:100%;"><%= request.getParameter("ncontent"+nchk[i]).replaceAll(System.getProperty("line.separator"), "") %></textarea>
							<% } %>
							</td>
							<!-- 완료예정 -->
							<td style="text-align: center; border: 1px solid">
							<% for(int i=0; i < nchk.length; i++) { %>
								<textarea required name="ntarget<%= i %>" maxlength="10" id="ntarget<%= i %>" style="resize: none; width:100%;"><%= request.getParameter("ntarget"+nchk[i]) %></textarea>
							<% } %>
							</td>
							<!-- 비고 -->
							<td style=" border: 1px solid"><textarea maxlength="500" wrap="hard" name="nnote" id="nnote" style="resize: none; width:100%; height:100px"></textarea></td>
						</tr>
					</tbody>
				</table>
			</div>
		</div>
	</form>
	<button type="button" class="btn btn-primary pull-right" style="width:50px; text-align:center; align:center" onclick="save()">제출</button>
	</div>
	 

<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<!-- auto size를 위한 라이브러리 -->
	<script src="https://rawgit.com/jackmoore/autosize/master/dist/autosize.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchField');
			
		}
		
	
	</script>
	
	<script>
		// 자동 높이 확장 (textarea)
		$(document).ready(function() {
			autosize($("textarea"));
			//2. 자동 높이 확장 (textarea)
			$(document).on('change input keyup kedown focusout blur mousemove', function() {
				autosize($("textarea"));
			});
		});
	</script>	


	<!-- 상태 선택을 위한 script -->
	<script>
	$("#state").on('click', function() {
		var con = document.getElementById("jb-text");
		if(con.style.display=="none"){
			con.style.display = 'block';
		} else {
			con.style.display = 'none';
		}
	});
	$(document).on('click',function(e) {
		var container = $("#state");
		if(!container.is(event.target) && !container.has(event.target).length) {
			document.getElementById("jb-text").style.display = 'none';
		}
	});
	
	var con = document.getElementById("state");
	$("#complete").on('click', function() {
			con.style.backgroundColor = "#00ff00";
	});
	
	$("#proceeding").on('click', function() {
		con.style.backgroundColor = "#ffff00";
	});

	$("#incomplete").on('click', function() {
		con.style.backgroundColor = "#ff0000";
	});
	</script>
	
	
	<script>
	//진행율(progess)선택을 통한 상태 변경
	function selectPro() {
		var con = document.getElementById("state");
		var select = document.getElementById("progress").value;
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
	var status = false;
	function save() {
		if(status == true) {
			// 재제출 금지
		} else {
			if(document.getElementById("content0").value == '' || document.getElementById("content0").value == null) {
				alert("금주 업무 실적의 '업무 내용'이 작성되지 않았습니다.");
			} else {
				if(document.getElementById("end0").value == '' || document.getElementById("end0").value == null) {
					alert("금주 업무 실적의 '완료일'이 작성되지 않았습니다.");
				} else {
					if(document.getElementById("progress").value.indexOf("선택") > -1) {
						alert("금주 업무 실적의 '진행율'이 선택되지 않았습니다.");
					} else {
						if(con.style.backgroundColor == '' || con.style.backgroundColor == null) {
							alert("금주 업무 실적의 '상태'가 선택되지 않았습니다.");
						} else {
							//차주
							if(document.getElementById("ncontent0").value == '' || document.getElementById("ncontent0").value == null) {
								alert("차주 업무 계획의 '업무 내용'이 작성되지 않았습니다.");
							} else {
								if(document.getElementById("ntarget0").value == '' || document.getElementById("ntarget0").value == null) {
									alert("차주 업무 계획의 '완료예정'이 작성되지 않았습니다.");
								} else {
									var innerHtml = '<td><textarea class="textarea" id="color" name="color" style="display:none">'+con.style.backgroundColor+'</textarea></td>';
									var innerHtml = '<td><textarea class="textarea" id="chk" name="chk" style="display:none">'+document.getElementById("chk").value+'</textarea></td>';
									var innerHtml = '<td><textarea class="textarea" id="nchk" name="nchk" style="display:none">'+document.getElementById("nchk").value+'</textarea></td>';
									$('#Table > tbody > tr:last').append(innerHtml);
									$('#bbsRk').submit();
								}
							}
						}
					}
				}
			}
		}
	}
	</script>
	
</body>
</html>