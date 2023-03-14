/**
 * 
 */
 
 
	//1. 진행율/완료일 '-' 작성 금지!
	$(document).on('input keyup',".end", function(event){
		var num = event.target.id;
		num = num[num.length - 1];
		
		var val = document.getElementById("bbsEnd"+num).value;
		
		var reg = /[-!@#$^&*()_+|<>?:{}\r\n]/g;
		//if(val.indexOf("-") > -1) {
		if(reg.test(val)) {
			alert("날짜 양식은 '/','%'만 사용 가능합니다.");
			document.getElementById("bbsEnd"+num).value = val.replaceAll(reg,"/");
		}
	});



	
	

	
	
	
	//3. drag and drop - rows를 실행하기 위한 스크립트
	$(document).ready(function() {
			autosize($("textarea"));
		//2. 자동 높이 확장 (textarea)
		$(document).on('change input keyup kedown focusout blur mousemove', function() {
			autosize($("textarea"));
		});
		
		//use jquery-ui for drag&drop
		$("#bbsTable tbody").sortable({
			items: "tr:not(.ui-state-disabled)",
			update: function(event, ui) {			
				//활성화 하기
				$("#bbsTable tbody").sortable("option","disabled",false);
				$(this).children().each(function(index) {

					//기존 데이터가 몇번인지 확인
					var a = $(this).find('td').first().find('select').attr('id');
					//a = a.replace("jobs",""); //숫자만 남도록 변환 
					var index_num = index-4;
					//$(this).find('td').first().find('textarea').html(a);
					//$(this).find('td').eq(3).find('textarea').html(index_num);					
					if(index_num > -1) {
						$(this).find('td').first().find('select').attr('id',"jobs"+index_num);
						$(this).find('td').first().find('select').attr('name',"jobs"+index_num);
						$(this).find('td').first().find('textarea').attr('id',"bbsContent"+index_num);
						$(this).find('td').first().find('textarea').attr('name',"bbsContent"+index_num);
						
						//2번째 td - input(bbsStart)
						$(this).find('td').eq(1).find('input').attr('id',"bbsStart"+index_num);
						$(this).find('td').eq(1).find('input').attr('name',"bbsStart"+index_num);
						
						//3번째 td - input(bbsTarget) 
						$(this).find('td').eq(2).find('input').attr('id',"bbsTarget"+index_num);
						$(this).find('td').eq(2).find('input').attr('name',"bbsTarget"+index_num);
					
						//4번째 td - textarea(bbsEnd)
						$(this).find('td').eq(3).find('textarea').attr('id',"bbsEnd"+index_num);
						$(this).find('td').eq(3).find('textarea').attr('name',"bbsEnd"+index_num);
						
						//5번째 td - button(paste)
						$(this).find('td').eq(5).find('button').attr('id',"paste"+index_num);
						$(this).find('td').eq(5).find('input[name="chkpos"]').attr('value',index_num);
					}
				});

			}
		});
		
		
		$("#bbsNTable tbody").sortable({
			items: "tr:not(.ui-state-disabled)",
			update: function(event, ui) {			
				//활성화 하기
				$("#bbsNTable tbody").sortable("option","disabled",false);
				$(this).children().each(function(index) {

					//기존 데이터가 몇번인지 확인
					var a = $(this).find('td').first().find('select').attr('id');
					//a = a.replace("jobs",""); //숫자만 남도록 변환 
					var index_num = index-2;
					//console.log(index_num);
					//$(this).find('td').first().find('textarea').html(index_num);				

					$(this).find('td').first().find('select').attr('id',"njobs"+index_num);
					$(this).find('td').first().find('select').attr('name',"njobs"+index_num);
					$(this).find('td').first().find('textarea').attr('id',"bbsNContent"+index_num);
					$(this).find('td').first().find('textarea').attr('name',"bbsNContent"+index_num);
					
					//2번째 td - input(bbsStart)
					$(this).find('td').eq(1).find('input').attr('id',"bbsNStart"+index_num);
					$(this).find('td').eq(1).find('input').attr('name',"bbsNStart"+index_num);
					
					//3번째 td - input(bbsTarget)
					$(this).find('td').eq(2).find('input').attr('id',"bbsNTarget"+index_num);
					$(this).find('td').eq(2).find('input').attr('name',"bbsNTarget"+index_num);
					
					//4번째 td - button(paste)
					$(this).find('td').eq(4).find('button').attr('id',"npaste"+index_num);
					$(this).find('td').eq(4).find('input[name="nchkpos"]').attr('value',index_num);
					
				});

			}
		});
	});	
	
	
	
	//금주 차주 업무 붙이기 ▼ ▲
		// 금주 -> 차주
	$(document).on("click","#post_start", function() {
		//재클릭시, 선택창 닫음!
		var val = $(this).attr('value');
		if(val == "false") {
			//처음 선택됨!
			$(this).attr('value','true');
			//var pas = document.getElementsByName("paste");
			var pas = document.getElementsByClassName("paste");
			var chk = document.getElementsByName("chkpos");
			document.getElementById("post").style.display="block";
			for(var i=0; i<pas.length; i++) {
				pas[i].style.display = "none";
				chk[i].style.display = "block";
			}	
		} else {
			$(this).attr('value','false');
			//var pas = document.getElementsByName("paste");
			var pas = document.getElementsByClassName("paste");
			var chk = document.getElementsByName("chkpos");
			document.getElementById("post").style.display="none";
			for(var i=0; i<pas.length; i++) {
			pas[i].style.display = "block";
			chk[i].style.display = "none";
			}	
			$("input[name=chkpos]").prop("checked",false);
		}
	});
	
	$(document).on("click","#post", function() {
		//생성 전, 차주 업무 개수를 미리 받아놓음.
		var before = trNCnt;
		var last = $('#bbsNTable').find("tr:last").find('input[name="nchkpos"]').attr('value');
		if(last == undefined) {
			last = 0;
		} else {
			++ last;
		}
		//15개 이상은 생성할 수 없음!
		var count_result = 1;
		var ommission = 0; //누락건 카운트
		var countresult = 0; //작성건 카운트
		//금주 개수만큼 업무 추가(trCnt)
			//chk가 기준!
		var chk = document.querySelectorAll('input[name="chkpos"]:checked');
		for(var i=0; i < chk.length; i++) {
			if(trNCnt < 15) {
			document.getElementById("nadd").click();
			countresult += 1;
			} else {
				if(count_result != -1) {
					count_result = -1;
				}
				ommission += 1;
			}
		}
		$("input[name=chkpos]").prop("checked",false);
		
		//before 기준으로, trNCnt(추가된것까지 포함!)까지 돌림
		for(var b = before; b < trNCnt; b ++) {
			//데이터 삽입 작업 시작
 			var num = b - before;
				var a = document.getElementById("jobs"+chk[num].value);
				var jobs = a.options[a.selectedIndex].value;
				//작성된 업무 내용
				var content = document.getElementById("bbsContent"+chk[num].value).value;
				//작성된 접수일 내용
				var start = document.getElementById("bbsStart"+chk[num].value).value;
				//작성된 완료목표일 내용
				var target = document.getElementById("bbsTarget"+chk[num].value).value;
				
				//데이터 삽입
					//b가 아닌, 추가로 생성되기 전의 번호를 알아야함! (해당 번호(last) + num로 계산)
					var number = Number(num) + Number(last);
				$("#njobs"+number).val(jobs).prop("selected", true);
					//작성된 업무내용 넣기
				$("#bbsNContent"+number).val(content);
					//작성된 접수일 넣기
				$("#bbsNStart"+number).val(start);
					//작성된 완료목표일 넣기
				$("#bbsNTarget"+number).val(target);
		}
		if(count_result == -1) {
			alert("추가 완료되었습니다.(금주 → 차주)\n최대 15개를 넘을 수 없어 조건에 맞춰 추가되었습니다. \n(등록 "+countresult+"건 / 미등록 "+ommission+"건)");
		} else {
			alert("추가 완료되었습니다.(금주 → 차주)");
		}
		
		var pas = document.getElementsByClassName("paste");
		var chk = document.getElementsByName("chkpos");
		document.getElementById("post").style.display="none";
		for(var i=0; i<pas.length; i++) {
			pas[i].style.display = "block";
			chk[i].style.display = "none";
		}	
	});
		
		
		//차주 -> 금주
		$(document).on("click","#npost_start", function() {
			//재클릭시, 선택창 닫음!
			var val = $(this).attr('value');
			if(val == "false") {
				$(this).attr('value','true');
				var pas = document.getElementsByClassName("npaste");
				var chk = document.getElementsByName("nchkpos");
				document.getElementById("npost").style.display="block";
				for(var i=0; i<pas.length; i++) {
					pas[i].style.display = "none";
					chk[i].style.display = "block";
				}	
			} else {
				$(this).attr('value','false');
				$("input[name=nchkpos]").prop("checked",false);
				var pas = document.getElementsByClassName("npaste");
				var chk = document.getElementsByName("nchkpos");
				document.getElementById("npost").style.display="none";
				for(var i=0; i<pas.length; i++) {
					pas[i].style.display = "block";
					chk[i].style.display = "none";
					}
				}
		});
	
		$(document).on("click","#npost", function() {
		//생성 전, 금주 업무 개수를 미리 받아놓음.
		var before = trCnt;
		var last = $('#bbsTable').find("tr:last").find('input[name="chkpos"]').attr('value');
		if(last == undefined) {
			last = 0;
		} else {
			++ last;
		}
		//15개 이상은 생성할 수 없음!
		var count_result = 1;
		var ommission = 0; //누락건 카운트
		var countresult = 0; //작성건 카운트
		//차주 개수만큼 업무 추가(trNCnt)
			//chk가 기준!
		var chk = document.querySelectorAll('input[name="nchkpos"]:checked');
		for(var i=0; i < chk.length; i++) {
			if(trNCnt < 15) {
			document.getElementById("add").click();
			countresult += 1;
			} else {
				if(count_result != -1) {
					count_result = -1;
				}
				ommission += 1;
			}
		}
		$("input[name=nchkpos]").prop("checked",false);
		
		
		//before 기준으로, trCnt(추가된것까지 포함!)까지 돌림
		for(var b = before; b < trCnt; b ++) {
			//데이터 삽입 작업 시작
 			var num = b - before;
				var a = document.getElementById("njobs"+chk[num].value);
				var jobs = a.options[a.selectedIndex].value;
				//작성된 업무 내용
				var content = document.getElementById("bbsNContent"+chk[num].value).value;
				//작성된 접수일 내용
				var start = document.getElementById("bbsNStart"+chk[num].value).value;
				//작성된 완료목표일 내용
				var target = document.getElementById("bbsNTarget"+chk[num].value).value;
				
				//데이터 삽입
					//b가 아닌, 추가로 생성되기 전의 번호를 알아야함! (해당 번호(last) + num로 계산)
					var number = Number(num) + Number(last);
				$("#jobs"+number).val(jobs).prop("selected", true);
					//작성된 업무내용 넣기
				$("#bbsContent"+number).val(content);
					//작성된 접수일 넣기
				$("#bbsStart"+number).val(start);
					//작성된 완료목표일 넣기
				$("#bbsTarget"+number).val(target);
		}
		if(count_result == -1) {
			alert("추가 완료되었습니다.(금주 → 차주)\n최대 15개를 넘을 수 없어 조건에 맞춰 추가되었습니다. \n(등록 "+countresult+"건 / 미등록 "+ommission+"건)");
		} else {
			alert("추가 완료되었습니다.(차주 → 금주)");
		}
		
		var pas = document.getElementsByClassName("npaste");
		var chk = document.getElementsByName("nchkpos");
		document.getElementById("npost").style.display="none";
		for(var i=0; i<pas.length; i++) {
			pas[i].style.display = "block";
			chk[i].style.display = "none";
		}	
	});
