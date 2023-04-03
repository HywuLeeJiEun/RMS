<%@page import="java.io.PrintWriter"%>
<%@page import="java.nio.file.Paths"%>
<%@page import="java.nio.file.Path"%>
<%@page import="java.io.IOException"%>
<%@page import="java.nio.file.Files"%>
<%@page import="java.io.File"%>
<%@page import="java.util.Enumeration"%>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>upload</title>
</head>
<body>
	<% 
	// 메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
	String id = null;
	String rms_dl = "";
	if(session.getAttribute("id") != null){
		id = (String)session.getAttribute("id");
	}
	if(id == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인이 필요한 서비스입니다.')");
		script.println("location.href='../../login.jsp'");
		script.println("</script>");
	} else {
		
		rms_dl = request.getParameter("rms_dl");
		String[] dl = rms_dl.split("-");
		
		request.setCharacterEncoding("utf-8");
		//저장될 위치 (rms_dl을 받아와 데이터 삽입)
		String location = "C:\\Users\\gkdla\\git\\RMS\\src\\main\\webapp\\WEB-INF\\Files\\"+dl[0]+"-"+dl[1];
		int maxSize = 1024 * 1024 * 5; // 키로바이트 * 메가바이트 * 기가바이트   
		 
		//폴더가 없다면, 생성
		File folder = new File(location);
		if(!folder.exists()) {
			//폴더가 없는 경우,
			folder.mkdir();
			//Path file1 = Paths.get(location+"\\새 폴더");
			//Path file2 = Paths.get(location+"\\"+dl[0]+"-"+dl[1]);
			
			//Files.move(file1, file2);
		}
		
		MultipartRequest multi = new MultipartRequest(request,
							 						  location,
													  maxSize,
													  "utf-8",
													  new DefaultFileRenamePolicy());

		
		Enumeration<?> files = multi.getFileNames(); // <input type="file">인 모든 파라메타를 반환
				
		String element = "";
		String filesystemName = "";
		String originalFileName = "";
		String contentType = "";
		long length = 0;		
				
		if (files.hasMoreElements()) { 
			element = (String)files.nextElement();
			filesystemName 			= multi.getFilesystemName(element); 
		}
	
		//파일명 변경 (기존 파일이 있는 경우 삭제!)
		String filename = "calendar"+dl[1]+".pptx";
		File oldFile = new File(location,filesystemName);
		File newFile = new File(location,filename);
		
		if(newFile.exists()) { 
				newFile.delete();
				oldFile.renameTo(newFile); 
		} else {
			File f = new File(location+"\\"+filename);
			f.delete();
			oldFile.renameTo(newFile); 
		}
	
		
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('파일 등록이 완료되었습니다.')");
		script.println("history.back();");
		//script.println("location.href='/RMS/admin/ams/attachment.jsp'");
		script.println("</script>");
	}

	%>

</body>
</html>