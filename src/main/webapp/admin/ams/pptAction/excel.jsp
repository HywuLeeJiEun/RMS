<%@page import="java.io.PrintWriter"%>
<%@page import="rmsvation.rmsvationDAO"%>
<%@page import="rmsuser.RmsuserDAO"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFCell"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFRow"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFSheet"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>
<%@page import="java.io.FileInputStream"%>
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
	rmsvationDAO vacaDAO = new rmsvationDAO(); //휴가 정보
	
	String rms_dl =(String) request.getAttribute("rms_dl");
	String[] dl = rms_dl.split("-");
	String vaca_ym = dl[0] + "-" + dl[1];
	String name ="";
	String num_name ="";
	String mon = Integer.parseInt(dl[1]) + "월";
	//ArrayList<String> name = new ArrayList<String>();

	// 이미 rms_vation이 저장되어 있다면,
	if(!vacaDAO.getVacaym(vaca_ym).isEmpty()) {
		//PrintWriter script = response.getWriter();
			//script.println("<script>");
			//script.println("alert('이미 저장된 휴가계획서가 있습니다.')");
			//script.println("history.back();");
			//script.println("</script>");
			
		//저장된 것을 모두 지우고, 새로 저장
		vacaDAO.delVation(vaca_ym);
		
	} 
	
	String filepath = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1]+"\\"+dl[0]+dl[1]+".xlsx";
	//String filepath = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\2023-02\\202302.xlsx";
    FileInputStream file = new FileInputStream(filepath);
    XSSFWorkbook workbook = new XSSFWorkbook(file);

    int rowindex=0;
    int columnindex=0;
    //시트 수 (첫번째에만 존재하므로 0을 준다)
    //만약 각 시트를 읽기위해서는 FOR문을 한번더 돌려준다
    XSSFSheet sheet=workbook.getSheetAt(0); // 첫번쨰 시트
    
    //행의 수
    int rows=sheet.getPhysicalNumberOfRows();
    int cellnumber=0;
    

    //4행(0부터 시작함 유의!)에서 월 데이터를 찾는다.
    XSSFRow frow = sheet.getRow(3);
    	//셀 개수 구하기
   	int fcells = frow.getPhysicalNumberOfCells(); 
    for(int i=0; i <= fcells; i++) {
    	//셀을 돌려 월이 같은지 확인
    	XSSFCell cell = frow.getCell(i);
    	String value = "";
    	if(cell == null) {
    		continue;
    	} else {
    		 //타입별로 내용 읽기
	            switch (cell.getCellType()){
	            case FORMULA:
	                value=cell.getCellFormula();
	                break;
	            case NUMERIC:
	                value=cell.getNumericCellValue()+"";
	                break;
	            case STRING:
	                value=cell.getStringCellValue()+"";
	                break;
	            case BLANK:
	                value=cell.getBooleanCellValue()+"";
	                break;
	            case ERROR:
	                value=cell.getErrorCellValue()+"";
	                break;
	    	}
    	}
    	if(value.contains(mon)) {
    		//System.out.println("찾음");
    		cellnumber = i;
    		//System.out.println(i);
    		break;
    	}
    }
    
    // 이름 모두 읽어오기 (cell은 2로 고정!)
    for(rowindex=7;rowindex<rows;rowindex++){
	    //행을 차례대로 내린다.
	    XSSFRow nrow = sheet.getRow(rowindex);
	    	//셀을 돌려 월이 같은지 확인
	    try {
	    	XSSFCell cell = nrow.getCell(1);
	    	String value = "";
	    	if(cell == null) {
	    		continue;
	    	} else {
	    		 //String만 읽어들이기
		            switch (cell.getCellType()){
		            case FORMULA:
		                value="";
		                break;
		            case NUMERIC:
		                value="";
		                break;
		            case STRING:
		                value=cell.getStringCellValue()+"";
		                break;
		            case BLANK:
		                value="";
		                break;
		            case ERROR:
		                value="";
		                break;
		    	}
	    	}
	    	
	    	if(!value.isEmpty() && value.length() < 5) {
	    		//System.out.println("찾음");
	    		//System.out.println(value);
	    		name += value+"&";
	    		num_name += rowindex+"&";
	    	}
	    } catch (NullPointerException e) {
	    	
	    }
   }
   List<String> user_name = new ArrayList<String>(Arrays.asList(name.split("&")));
   List<String> user_id = new ArrayList<String>();
   for(int i=0; i < user_name.size(); i++) {
		user_id.add(i, userDAO.getId(user_name.get(i)));   
   }
   //user_name.remove(user_name.size()-1);
   List<String> user_num = new ArrayList<String>(Arrays.asList(num_name.split("&")));
   //user_num.remove(user_num.size()-1);
   
   
   //데이터 불러오기 (해당 row(user_num)와 컬럼(cellnumber)에 작업)
   String user_va = "";
 	for(int i=0; i < user_num.size(); i++) {
 		XSSFRow row = sheet.getRow(Integer.parseInt(user_num.get(i))); //해당 있는 행에만 적용
 		XSSFCell cell = row.getCell(Integer.parseInt(dl[1])+1); //3 -> 2월
 		String value = "";
    	if(cell == null) {
    		continue;
    	} else {
    		 //타입별로 내용 읽기
	            switch (cell.getCellType()){
	            case FORMULA:
	                value=cell.getCellFormula();
	                break;
	            case NUMERIC:
	                value=cell.getNumericCellValue()+"";
	                break;
	            case STRING:
	                value=cell.getStringCellValue()+"";
	                break;
	            case BLANK:
	                value=cell.getBooleanCellValue()+"";
	                break;
	            case ERROR:
	                value=cell.getErrorCellValue()+"";
	                break;
	    	}
    	}
 		user_va += value+"&";
 	}

 	//user_va = user_va.replaceAll(".0", "");
 	List<String> user_vaca = new ArrayList<String>(Arrays.asList(user_va.split("&")));

 	
 	// 휴가 Database에 저장하기
 		//row(user_num)의 개수 => 총 인원 / 빈칸의 값은 false로 저장 / 값이 여러개 들어가 있을 수 있음. (,) 
  		for(int i=0; i < user_num.size(); i++) {
 			if(!user_vaca.get(i).equals("false")) {
 				//값이 들어 있다면,
 				String[] vacation = user_vaca.get(i).split(","); //split된 경우, 개수가 하나 이상이라면 length가 1보다 큼!
 				String userid = user_id.get(i);
 				String userinfo = "full";
 				if(vacation.length > 1) {
 					//휴가 일정이 여럿인 경우,
 						for(int j=0; j < vacation.length; j++) {
 							//부가 정보를 취득 (반차인지 아닌지 확인)
 							if(vacation[j].contains("오전")) {
 								userinfo = "오전";
 							} else if(vacation[j].contains("오후")){
 								userinfo = "오후";
 							} else {
 								userinfo = "full";
 							}
 							String day = vacation[j].replace(".0","");
 								   day = day.replaceAll("[^0-9]", ""); //숫자만 남김
 							//DB에 저장 (dl[0]-dl[1](rms_ym) / username / day / 부가정보(userinfo))
 							int result = vacaDAO.writeVation(vaca_ym, userid, day, userinfo);	
 							
 							if(result == -1) {
 								vacaDAO.delVation(vaca_ym);
 								//저장에 실패할 경우, 데이터 삭제
 								PrintWriter script = response.getWriter();
 								script.println("<script>");
 								script.println("alert('엑셀 파일 저장에 문제가 발생하였습니다.')");
 								script.println("history.back();");
 								script.println("</script>");
 							} else {
 								PrintWriter script = response.getWriter();
 								script.println("<script>");
 								script.println("alert('저장이 완료되었습니다.')");
 								script.println("history.back();");
 								script.println("</script>");
 							}
 						}
 				} else {
 					//휴가 일정이 하나인 경우, 
 					if(vacation[0].contains("오전")) {
							userinfo = "오전";
						} else if(vacation[0].contains("오후")){
							userinfo = "오후";
						} else {
							userinfo = "full";//else if(vacation[0].contains("X")) {}
						}
 						String day = vacation[0].replace(".0","");
							   day = day.replaceAll("[^0-9]", ""); //숫자만 남김
						if(day != null && !day.isEmpty()) {
							//DB에 저장 (dl[0]-dl[1](rms_ym) / username / day / 부가정보(userinfo) )
							int result = vacaDAO.writeVation(vaca_ym, userid, day, userinfo);	
							
							if(result == -1) {
								vacaDAO.delVation(vaca_ym);
								//저장에 실패할 경우, 데이터 삭제
								PrintWriter script = response.getWriter();
								script.println("<script>");
								script.println("alert('엑셀 파일 저장에 문제가 발생하였습니다.')");
								script.println("history.back();");
								script.println("</script>");
							} else {
								PrintWriter script = response.getWriter();
								script.println("<script>");
								script.println("alert('저장이 완료되었습니다.')");
								//script.println("history.back();");
								script.println("</script>");
							}
						}
 				}
 				
 			}
 			
 		} 
	
	
	request.setAttribute("rms_dl", rms_dl);
	RequestDispatcher dispatcher = request.getRequestDispatcher("vacationAction.jsp");
	dispatcher.forward(request, response);
%>
</body>
</html>