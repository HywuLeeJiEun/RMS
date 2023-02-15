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
	
	
//	<!-- 모달 submit -->
	$('#modalbtn').click(function(){
		$('#modalform').text();
	})

//	<!-- 모달 update를 위한 history 감지 -->
	window.onpageshow = function(event){
		if(event.persisted || (window.performance && window.performance.navigation.type == 2)){ //history.back 감지
			location.reload();
		}
	}