package rmsuser;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


public class RmsuserDAO {

	private Connection conn; //자바와 데이터베이스를 연결
	private PreparedStatement pstmt; //쿼리문 설정 및 실행
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public RmsuserDAO() {
		try {
			String dbURL = "jdbc:mariadb://localhost:3306/rms"; //연결할 DB
			String dbID = "root"; //DB 접속 ID
			String dbPassword = "7471350"; //DB 접속 password
			Class.forName("org.mariadb.jdbc.Driver");
			conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
		}catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	
	/*********** 기능 구현(메소드 구현) 영역 ***********/
	//로그인 영역
	public int login(String user_id, String user_pwd) {
		// DB에서 사용될 sql
		String sql = "select user_pwd from rmsuser where user_id = ?";
		try {
			pstmt = conn.prepareStatement(sql); //sql쿼리문을 대기
			pstmt.setString(1, user_id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery(); //쿼리를 실행한 결과를 rs에 저장
			if(rs.next()) {
				if(rs.getString(1).equals(user_pwd)) {
					return 1; //로그인 성공
				}else
					return 0; //비밀번호 틀림
			}
			return -1; //아이디 없음
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -2; //오류
	} // return값에 따른 결과 ( 1 - 성공, 0 - 틀림, -1 - 존재하지 않음. -2 - DB에러 )
	
	
	//RMSUSER - 모달 업데이트 (update) // ModalUpdateAction.jsp
	public int UpdateUser(String password, String name, String email, String user_id) {
		String sql = "update rmsuser set user_pwd=?,user_name=?,user_em=? where user_id=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, password);
			pstmt.setString(2, name);
			pstmt.setString(3, email);
			pstmt.setString(4, user_id);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; // 데이터베이스 오류
	}
	
	
	//아이디를 통해 사용자 정보 가져오기 (RMSUSER 테이블 조회)
	public ArrayList<rmsuser> getUser(String user_id) {
		String sql = "select * from rmsuser where user_id=?";
		ArrayList<rmsuser> list = new ArrayList<rmsuser>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				rmsuser user = new rmsuser();
				user.setUser_id(rs.getString(1));
				user.setUser_pwd(rs.getString(2));
				user.setUser_name(rs.getString(3));
				user.setUser_rk(rs.getString(4));
				user.setUser_em(rs.getString(5));
				user.setUser_au(rs.getString(6));
				user.setUser_fd(rs.getString(7));
				list.add(user);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
			
	
	//name을 출력한다. (성함) USER_NAME
	public String getName(String user_id) {
		String sql = "select user_name from rmsuser where user_id = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//id을 출력한다. (아이디) user_id
	public String getId(String user_name) {
		String sql = "select user_id from rmsuser where user_name = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_name); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//rank를 출력한다 (직급) USER_RK
	public String getRank(String user_id) {
	String sql = "select user_rk from rmsuser where user_id = ?";
	try {
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, user_id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
	rs = pstmt.executeQuery();
		if(rs.next()) {
			if(rs.getString(1) == null) {
			return "";
			}
			return rs.getString(1);
			}
		}catch (Exception e) {
		e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//RMSMGRS(사용자 담당 업무)에 접근하여 업무 number를 조회한다.
	public ArrayList<String> getCode(String user_id) {
		String sql = "select task_num from rmsmgrs where user_id = ?";
		ArrayList<String> list = new ArrayList<String>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			while(rs.next()) {
				list.add(rs.getString(1)); //task_num		
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list; //데이터베이스 오류
	}
	
	
	//RMSTASK(담당 업무 코드)에 접근하여 사용자의 담당 업무명을 알아낸다.
	public String getManager(String task_num) {
		String sql = "select task_wk from rmstask where task_num = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, task_num); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//RMSTASK(담당 업무 코드)에 접근하여 사용자의 담당 업무명을 알아낸다.
	public String getTaskNum(String task_wk) {
		String sql = "select task_num from rmstask where task_wk = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, task_wk);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//RMSMGRS - 업무 확인하기 - workAction.jsp ...
	public int getMgrs(String user_id, String task_num) {
		String sql = "select * from rmsmgrs where user_id = ? and task_num = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, task_num);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return 0;
			}
		}catch (Exception e){
			e.printStackTrace();
		}
		return -1;
	}
	
	
	//RMSMGRS - 업무 추가(insert)하기 - workAction.jsp ...
	public int inMgrs(String user_id, String task_num) {
		String sql = "insert into rmsmgrs values(?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, task_num);
			return pstmt.executeUpdate();
		}catch (Exception e){
			e.printStackTrace();
		}
		return -1;
	}
	
	
	//RMSMGRS - 업무 삭제(Delete)하기 - workDeleteActionSh.jsp ...
	public int delMgrs(String user_id, String task_num) {
		String sql = "delete from rmsmgrs where user_id=? and task_num=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, task_num);
			return pstmt.executeUpdate();
		}catch (Exception e){
			e.printStackTrace();
		}
		return -1;
	}
	
	
	//RMSMGRS - 담당 업무 개수 세기(count) - workAction.jsp
	public int getCountMgrs(String user_id) {
	String sql = "select count(task_num) from rmsmgrs where user_id=?";
	try {
	PreparedStatement pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, user_id);
	rs = pstmt.executeQuery();
		if(rs.next()) {
			return rs.getInt(1);
			}
		}catch (Exception e) {
		e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
			
	
	//RMSTASK 모든 업무 가져오기
	public ArrayList<String> getManagerAll() {
		String sql = "select task_wk from rmstask";
			ArrayList<String> list = new ArrayList<String>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				list.add(rs.getString(1));
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list; //데이터베이스 오류
	}
	
	
	//RMSUSER 담당 분야 가져오기 (user_fd)
	public String getFD(String user_id){
		String sql =  "select user_fd from rmsuser where user_id=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	
	
	//RMSUSER USER_FD(Field) 사용자 담당 분야별로 검색하여 user_id 도출
	public ArrayList<String> getpluser(String user_fd){
		//String sql =  "select * from pluser where work=?";
		String sql =  "select user_id from rmsuser where user_fd=?";
				ArrayList<String> list = new ArrayList<String>();
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_fd);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				list.add(rs.getString(1)); //userid
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return list;
	}
	
	
	//RMSTASK 담당 업무명에 대한 업무 코드 알아보기
	public String getTask(String task_wk){
		String sql =  "select task_num from rmstask where task_wk like '%"+task_wk.trim()+"%'";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	
	
	//RMSTASK 담당 업무명에 대한 업무 코드 알아보기
	public String getMgrs(String task_num){
		String sql =  "select user_id from rmsmgrs where task_num=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, task_num);
			rs = pstmt.executeQuery();
			while(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return "";
	}
	
	
	//RMSUSER - user_fd로 검색하여 user_id 가져오기
	public ArrayList<String> getidFD(String user_fd) {
		String sql = "select user_id from rmsuser where user_fd=?";
			ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, user_fd);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //user_id
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
	
	
	//RMSUSER - user_id 모두 가져오기 - workChange.jsp
	public ArrayList<String> getidfull() {
		String sql = "select if(user_fd ='미정', user_fd, user_id) from rmsuser order by user_name asc";
			ArrayList<String> list = new ArrayList<String>();
			try {
				PreparedStatement pstmt = conn.prepareStatement(sql);
				rs = pstmt.executeQuery();
				while(rs.next()) {
					list.add(rs.getString(1)); //user_id
				}
			}catch (Exception e) {
				e.printStackTrace();
			}
			return list;
		}
}
