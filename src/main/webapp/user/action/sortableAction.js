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
						$(this).find('td').eq(5).find('button').attr('name',"paste"+index_num);
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
					$(this).find('td').eq(4).find('button').attr('name',"npaste"+index_num);

				});

			}
		});
	});	
