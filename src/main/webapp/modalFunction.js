/**
Modal 실행 및 보조를 위한 자바스크립트
 **/
 
// <!-- modal 내, password 보이기(안보이기) 기능 -->
		$(document).ready(function(){
		    $('#icon').on('click',function(){
		    	console.log("hello");
		        $('#password').toggleClass('active');
		        if($('#password').hasClass('active')){
		            $(this).attr('class',"glyphicon glyphicon-eye-close")
		            $('#password').attr('type',"text");
		        }else{
		            $(this).attr('class',"glyphicon glyphicon-eye-open")
		            $('#password').attr('type','password');
		        }
		    });
		    
		    //데이터 채우기
		    var ui = document.getElementById("ui").value;
		    var pw = document.getElementById("pw").value;
		    var nm = document.getElementById("nm").value;
		    var rn = document.getElementById("rn").value;
		    var em = document.getElementById("em").value;
		    var ws = document.getElementById("ws").value;
		     $('#updateid').attr('value',ui);
		     $('#password').attr('value',pw);
		     $('#name').attr('value',nm);
		     $('#rank').attr('value',rn);
		     $('#email').attr('value',em);
		     $('#duty').attr('value',ws);
		});
	
	
//	<!-- 모달 툴팁 -->
		$(document).ready(function(){
			$('[data-toggle="tooltip"]').tooltip();
		});

//	<!-- 모달 update를 위한 history 감지 -->
	window.onpageshow = function(event){
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)){ //history.back 감지
			location.reload();
		}
	}
	
	
	// Table sort 정렬
	function sortTable(n) {
		var table, rows, switching, o, x, y, shouldSwitch, dir, switchcount = 0;
		table = document.getElementById("bbsTable");
		switching = true;
		dir = "asc"; //오름차순
		
		// column 개수
		var col = $("#bbsTable").find('tr')[0].cells.length;
		
		// 으름차순 / 내림차순 표시
		if($("#"+n).val() == "△") {
			$("#"+n).attr('type','text');
			$("#"+n).val("▽");
			for(var i=0; i < col; i ++) {
				if(i != n) {
					$("#"+i).val("");
					$("#"+i).attr('type','hidden');
				}
			}
		} else {
			$("#"+n).attr('type','text');
			$("#"+n).val("△");
			for(var i=0; i < col; i ++) {
				if(i != n) {
					$("#"+i).val("");
					$("#"+i).attr('type','hidden');
				}
			}
		}
		
		
		while (switching) {
			switching = false;
			rows = table.getElementsByTagName("tr");
			
			for(o=1; o < (rows.length -1); o++) {
				shouldSwitch = false;
				x = rows[o].getElementsByTagName("td")[n];
				y = rows[o + 1].getElementsByTagName("td")[n];
				
				if(dir == "asc") {
					if(x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
						shouldSwitch=true;
						break;
					}
				} else if(dir == "desc") {
					if(x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
						shouldSwitch = true;
						break;
					}
				}
			}
			
			if(shouldSwitch) {
				rows[o].parentNode.insertBefore(rows[o + 1], rows[o]);
				switching = true;
				switchcount ++;
			} else {
				if(switchcount == 0 && dir == "asc") {
					dir = "desc";
					switching = true;
				}
			}

		}
	}