<%@page import="rmsrept.RmsreptDAO"%>
<%@page import="rmsrept.rmsrept"%>
<%@page import="rmsuser.rmsuser"%>
<%@page import="rmsuser.RmsuserDAO"%>
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
<link rel="stylesheet" href="../css/index.css">
<meta charset="UTF-8">
<!-- 화면 최적화 -->
<!-- <meta name="viewport" content="width-device-width", initial-scale="1"> -->
<!-- 루트 폴더에 부트스트랩을 참조하는 링크 -->
<title>RMS</title>
</head>

<body>
	<%
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
		
		// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		String id = null;
		if((String) request.getSession().getServletContext().getContext("/RMS").getAttribute("id") != null) {
			id = (String) request.getSession().getServletContext().getContext("/RMS").getAttribute("id");
			session.setAttribute("id", id);
		} else if ((String) request.getSession().getServletContext().getContext("/RMS").getAttribute("id") == null){
			// 로그아웃을 한 상태
			id = null;
			session.invalidate();
		} else if(session.getAttribute("id") != null){
			id = (String)session.getAttribute("id");
		}
		
		int pageNumber = 1; //기본은 1 페이지를 할당
		// 만약 파라미터로 넘어온 오브젝트 타입 'pageNumber'가 존재한다면
		// 'int'타입으로 캐스팅을 해주고 그 값을 'pageNumber'변수에 저장한다
		if(request.getParameter("pageNumber") != null){
			pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
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
		
		//관리자의 권한을 가진 경우, admin으로 넘김
		if(au.equals("관리자")) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("location.href='/RMS/admin/bbsAdmin.jsp'");
			script.println("</script>");
		}
		
		//기존 데이터 불러오기 (가장 최근에 작성된 rms 조회)
		ArrayList<rmsrept> list = rms.getrms(id, pageNumber);
		
		//다음 페이지가 있는지 확인!
		ArrayList<rmsrept> aflist = rms.getrms(id, pageNumber+1);
		
		//유저가 작성한(승인/마감된) 주간보고의 rms_dl을 받아옴.
		ArrayList<rmsrept> rmslist = rms.getuserAllRms_dl(id);
		//String rmsfull = String.join("&",rmslist.toString());
		String rmsfull = "";
		if(rmslist.size() > 0) {
			for(int i=0; i < rmslist.size(); i++) {
				if(i < rmslist.size() - 1) {
					rmsfull += rmslist.get(i).getRms_dl() + "&"; 
				} else {
					rmsfull += rmslist.get(i).getRms_dl();
				}
			}
		}
	
	%>
	    
	<!-- nav바 불러오기 -->
    <jsp:include page="../Nav.jsp"></jsp:include>
	
	
	<!-- ***********검색바 추가 ************* -->
	<div class="container">
		<div class="row">
			<table class="pull-left" style="text-align: center; cellpadding:50px; width:60%" >
			<thead>
				<tr>
					<th style=" text-align: left" data-toggle="tooltip" data-html="true" data-placement="bottom" title=""> 
					<br><i class="glyphicon glyphicon-triangle-right" id="icon"  style="left:5px;"></i> 주간보고 목록 (개인)
				</th>
				</tr>
			</thead>
			</table>
			<form method="post" name="search" action="/RMS/user/searchbbs.jsp">
				<table class="pull-right">
					<tr>
						<td><select class="form-control" name="searchField" id="searchField" onchange="ChangeValue()">
								<option value="rms_dl">제출일</option>
								<option value="rms_title">제목</option>
						</select></td>
						<td><input type="text" class="form-control"
							placeholder="검색어 입력" name="searchText" maxlength="100"></td>
						<td><button type="submit" style="margin:5px" class="btn btn-success">검색</button></td>
					</tr>

				</table>
			</form>
		</div>
	</div>
	<br>
	
	
	<!-- 모달 영역! (날짜 선택 모달) - 출력시 활성화 -->
	<button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#RmsdlModal" id="rmsData" style="display:none"> get rms_dl </button>
	<div class="modal fade" id="RmsdlModal" role="dialog">
		   <div class="modal-dialog">
		    <div class="modal-content">
		     <div class="modal-header">
		      <!-- <button type="button" class="close" data-dismiss="modal">×</button> -->
		      <!-- <h3 class="modal-title" align="center">제출일 선택</h3> -->
		     </div>
		     <!-- 모달에 포함될 내용 -->
		     <form method="post" action="/RMS/pl/bbsRkwrite.jsp" id="rmsdlmodalform">
		     <div class="modal-body">
		     		<div class="row">
		     			<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" >취소</a>
		     				<a type="button" class="close" >취소</a>
		     			</div>
		     			<div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6 form-outline">
		     				<label class="col-form-label" data-toggle="tooltip" data-placement="top" title="pptx로 출력하고자 하는 제출일의 범위를 선택합니다.">제출일 선택</label>
		     				<i class="glyphicon glyphicon-info-sign"  style="left:5px;"></i>
		     				<select class="form-control" style="width:200px" id="rms_dl1" onchange="enable2()">
								<option value="rms_dl" selected="selected">[선택]</option>
							<% for(int i=0; i < rmslist.size(); i++) { %>
									<option><%= rmslist.get(i).getRms_dl() %></option>
							<% } %>
							</select>
							~
							<select class="form-control" style="width:200px" id="rms_dl2" disabled>
								<option value="rms_dl" selected="selected">[선택]</option>
							</select>
							<br>
		     				<h5 class="col-form-label">선택된 날짜를 기준으로 출력합니다.</h5>
		     				<h6 class="col-form-label"><strong>하단 범위를 선택하지 않고 넘기는 경우, <br>해당 제출일에 대한 pptx만 생성됩니다.</strong></h6>
		     				<input type="password" maxlength="20" required class="form-control" style="width:100%; display:none" id="rms_md" name="rms_md" value="-1">
		     			</div>
		     			<div class="col-md-3">
		     				<label class="col-form-label"> &nbsp; </label>
		     				<!-- <button type="submit" class="btn btn-primary pull-left form-control" >확인</button> -->
						</div>
						<div class="col-md-12" style="visibility:hidden">
		     				<a type="button" class="close" ></a>
		     				<a type="button" class="close" ></a>
		     			</div>
		     			</div>
		     			<div class="modal-footer">
					     <div class="col-md-3" style="visibility:hidden">
		     			</div>
		     			<div class="col-md-6">
					     	<button type="button" class="btn btn-success pull-right form-control" style="width:30%" onClick="userPptxAction()" >출력</button>
				     	</div>
				     	 <div class="col-md-3" style="visibility:hidden">
			   			</div>	
		    </div>
   			</div>
		    </form>
		   </div>
	  </div>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 시작 -->
	<div class="container">
		<div class="row">
			<table id="bbsTable" class="table table-striped" style="text-align: center; border: 1px solid #dddddd">
				<thead>
					<tr>
						<!-- <th style="background-color: #eeeeee; text-align: center;">번호</th> -->
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(0)">제출일<input type="text" readonly id="0" style="border:none; width:18px; background-color:transparent;" value="▽"></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(1)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;제목<input type="hidden" readonly id="1" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(2)">작성자<input type="hidden" readonly id="2" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(3)">작성일(수정일)<input type="hidden" readonly id="3" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(4)">담당<input type="hidden" readonly id="4" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
						<th style="background-color: #eeeeee; text-align: center;"onclick="sortTable(5)">상태<input type="hidden" readonly id="5" style="border:none; width:18px; background-color:transparent;" value=""></input></th>
					</tr>
				</thead>
				<tbody>
					<%
						for(int i = 0; i < list.size(); i++){
							
							// 현재 시간, 날짜를 구해 이전 데이터는 수정하지 못하도록 함!
							SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
							String dl = list.get(i).getRms_dl();
							Date time = new Date();
							String timenow = dateFormat.format(time);

							Date dldate = dateFormat.parse(dl);
							Date today = dateFormat.parse(timenow);
					%>

						<!-- 게시글 제목을 누르면 해당 글을 볼 수 있도록 링크를 걸어둔다 -->
					<tr>
						<td> <%= list.get(i).getRms_dl() %> </td>

						<%-- <td><%= list.get(i).getBbsDeadline() %></td> --%>
						<td style="text-align: left">
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						<a href="/RMS/user/update.jsp?rms_dl=<%= list.get(i).getRms_dl() %>">
							<%= list.get(i).getRms_title() %></a></td>
						<td><%= name %></td>
						<td><%= list.get(i).getRms_time().substring(0, 11) + list.get(i).getRms_time().substring(11, 13) + "시"
							+ list.get(i).getRms_time().substring(14, 16) + "분" %></td>
						<td><%= pl %></td>
						<!-- 승인/미승인/마감 표시 -->
						<td>
						<%
						String sign = null;
						if((dldate.after(today) || dldate.equals(today)) && list.get(i).getRms_sign().equals("승인")) { //현재 날짜가 마감일을 아직 넘지 않으면,
							//sign = list.get(i).getSign();
							sign="제출";
							//rms에 통합 저장 진행
							//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getPptxRms(list.get(i).getRms_dl(), id);
							if(rmsData == 0) { //작성된 기록이 없다!	
									//java
								rms.WritePptx(list.get(i).getRms_dl(), id);
							}
						} else if(dldate.after(today) && list.get(i).getRms_sign().equals("미승인")) {
							//sign = list.get(i).getSign();
							sign="미제출";
						}else { // 기간이 지난 경우,
							//미승인, 마감 상태일 경우엔 하단 진행.
							if(!list.get(i).getRms_sign().equals("마감")) {
								// 데이터베이스에 마감처리 진행
								int a = rms.updateSignAll("마감",list.get(i).getRms_dl());
							}
							sign="마감";
							//rms에 통합 저장 진행
							//1. rms(pptxrms)에 저장되어 있는지 확인! (승인 -> 마감이 되는 경우 유의)
							int rmsData = rms.getPptxRms(list.get(i).getRms_dl(), id);
							if(rmsData == 0) { //작성된 기록이 없다!
									//java
								rms.WritePptx(list.get(i).getRms_dl(), id);
							}
						}
						%>
						<%= sign %>
						</td>
					</tr>
					<%
						}
					%>
				</tbody>
			</table>
			
			<!-- 페이징 처리 영역 -->
			<!-- <div style="text-align:center"> -->
			<%
				if(pageNumber != 1){
			%>
				<%-- <a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left" style="display:inline-block">이전</a> --%>
					<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber - 1 %>"
					class="btn btn-success btn-arraw-left">이전</a>
			<%
				}if(aflist.size() != 0){
			%>
				<%-- <a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next" style="display:inline-block">다음</a> --%>
					<a href="/RMS/user/bbs.jsp?pageNumber=<%=pageNumber + 1 %>"
					class="btn btn-success btn-arraw-left" id="next">다음</a>
			<%
				}
			%>
			
			<!-- 글쓰기 버튼 생성 -->
			<a href="/RMS/user/bbsUpdate.jsp" class="btn btn-info pull-right" data-toggle="tooltip" data-html="true" data-placement="bottom" title="주간보고 작성">작성</a>
			<button class="btn btn-success pull-right" onclick="rmsModalAction()" style="margin-right:20px" data-toggle="tooltip" data-html="true" data-placement="bottom" title="승인 및 마감된 주간보고를 출력합니다.">출력</button>
			<!-- </div> -->
		</div>
	</div>
	
	
	
	<!-- 게시판 메인 페이지 영역 끝 -->
	
	<!-- 부트스트랩 참조 영역 -->
	<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
	<script src="../css/js/bootstrap.js"></script>
	<script src="../modalFunction.js"></script>
	
	<script>
	// rms modal 띄우기 (출력 버튼을 클릭시, modal이 나오도록 설정)
	function rmsModalAction() {
			$("#rmsData").hide();
			$("#rmsData").trigger('click');
		
		$('#RmsdlModal').on('hidden.bs.modal', function (){
			/*  */
		})
	};
	
	//상단 제출일 선택 후, 하단 제출일을 선택할 수 있도록 구성
	function enable2() {
		var selectA = document.getElementById("rms_dl1");
	    var selectB = document.getElementById("rms_dl2");
	    
	    if (selectA.value == "rms_dl") {
	      selectB.disabled = true;
	      
	    } else {
	      selectB.disabled = false;
	    	 
	      //첫번째 rms_dl([선택])을 제외하고 모두 날림!
	      $('#rms_dl2').children('option:not(:first)').remove();
	      
	   	  // 선택한 a 데이터를 기준으로, selectB의 옵션을 변경합니다.
	   	  //1) list 데이터 채우기
	   	  var rmsfull = '<%= rmsfull %>';
	   	  var rmslist = rmsfull.split('&'); 
	   	  var dateList = new Array();
	   	  for(var i=0; i < rmslist.length; i++) {
	   		  if(rmslist[i] > selectA.value) {
	   			  // 날짜가 더 크다면,
	   			  //selectB.add(rmslist[i]);
	   			  $('#rms_dl2').append('<option value="'+rmslist[i]+'">'+rmslist[i]+'</option>');
	   		  }
	   	  }
	    }
	}
	
	
	function userPptxAction() {
		var selectA = document.getElementById("rms_dl1");
	    var selectB = document.getElementById("rms_dl2");
	    
	    var result = 0;
	    
	    if(selectA.value == 'rms_dl') {
	    	//첫 제출일이 선택되지 않았을 때!
	    	alert("기준 제출일을 선택하여 주십시오.");
	    } else if (selectB.value == 'rms_dl'){
	    	//하위 제출일이 안된 경우, 
	    	if(confirm("범위 제출일을 선택하지 않으셨습니다. 이대로 진행하시겠습니까?")) {
	    		result = 1;
	    	}
	    } else {
	    	//기준 / 하위 제출일을 모두 선택하여 제출한 경우
	    	result = 1;
	    }
	    
	    if(result == 1) {
	    	location.href='/RMS/user/action/userPptxAction.jsp?rms_dl1='+selectA.value+'&rms_dl2='+selectB.value;
	    	
	    	$('#RmsdlModal').modal('hide');
	    }
	}
	
	</script>
	
	<script>
		function ChangeValue() {
			var value_str = document.getElementById('searchField');
			
		}
	</script>
	
    <!-- 보고 개수에 따라 버튼 노출 (list.size()) -->
	<script>
	var trCnt = $('#bbsTable tr').length; 
	
	if(trCnt < 11) {
		$('#next').hide();
	}
	</script>
	
</body>
</html>