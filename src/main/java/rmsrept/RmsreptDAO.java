package rmsrept;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import rmsuser.RmsuserDAO;


public class RmsreptDAO {
	private Connection conn; //자바와 데이터베이스를 연결
	private ResultSet rs; //결과값 저장
	
	
	//기본 생성자
	//1. 메소드마다 반복되는 코드를 이곳에 넣으면 코드가 간소화된다.
	//2. DB 접근을 자바가 직접하는 것이 아닌, DAO가 담당하도록 하여 호출 문제를 해결함.
	public RmsreptDAO() {
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
	//작성일자(시간 추출) 메소드 - main, update
	public java.sql.Timestamp getDateNow() {
		String sql = "select now()";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getTimestamp(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return null; //데이터베이스 오류
	}
	
	
	// RMSREPT 조회하기 (+pageNumber) (승인 및 마감 상태)  [관리자] //bbsAdmin.jsp
	public ArrayList<rmsrept> getrmsAll(int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from rmsrept where rms_sign='승인' or rms_sign='마감' order by rms_dl desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setInt(1, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// RMSREPT 사용자(USER_ID)로 조회하기 (+pageNumber)   //bbs.jsp
	public ArrayList<rmsrept> getrms(String user_id, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from rmsrept where user_id=? order by rms_dl desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, user_id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// RMSREPT 사용자(USER_ID)로 조회하기 (+pageNumber) [미승인된 데이터만 조회]  //bbsUpdateDelete.jsp
	public ArrayList<rmsrept> getrmsSign(String user_id, int pageNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from rmsrept where user_id=? and rms_sign='미승인' order by rms_dl desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, user_id);
	            pstmt.setInt(2, (pageNumber-1) * 10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
		
	
	// RMSREPT 사용자(USER_ID)로 검색하여 조회하기 Search (+pageNumber)   //bbs.jsp
		public ArrayList<rmsrept> getrmsSearch(String user_id, String searchField, String searchText, int pageNumber){//특정한 리스트를 받아서 반환
		      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
		      String SQL ="select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from "
		      		+ "(select * from rmsrept where user_id=?) r"
		      		+ " where "+searchField.trim();
		      try {
		    	  	if(searchText !=null && !searchText.equals("")) {
		    	  		SQL += " LIKE '%"+searchText.trim()+"%' order by rms_dl desc limit ?,10";
		    	  	} else {
		    	  		return list;
		    	  	}
		    	  
		            PreparedStatement pstmt=conn.prepareStatement(SQL);
		            pstmt.setString(1, user_id);
		            pstmt.setInt(2, (pageNumber-1) * 10);
					rs=pstmt.executeQuery();//select
		         while(rs.next()) {
		        	 rmsrept rms = new rmsrept();
		        	 rms.setUser_id(rs.getString(1));
		        	 rms.setRms_dl(rs.getString(2));
		        	 rms.setRms_title(rs.getString(3));
		        	 rms.setRms_sign(rs.getString(4));
		        	 rms.setRms_time(rs.getString(5));
		            list.add(rms);
		         }         
		      } catch(Exception e) {
		         e.printStackTrace();
		      }
		      return list;
		   }
		
	
	//RMSREPT sign 변경하기
	public int updateSign(String user_id, String rms_sign, String rms_dl) {
		String sql = " update rmsrept set rms_sign=? where user_id= ? and rms_dl = ?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, rms_sign); 
			pstmt.setString(2, user_id); 
			pstmt.setString(3, rms_dl); 
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}

	
	
	//RMSEDPS sign 변경하기
	public int updateERPtest(String test, String before_dl) {
		String sql = " update rmsedps set user_id=? where rms_dl = ?";
		 try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, test); 
			pstmt.setString(2, before_dl); 
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		 return -1;
	}
	
	
	//RMSREPT 가장 최근에 작성된 rms_dl 찾기
	public String getMaxDL(String user_id) { 
		 String sql ="select distinct rms_dl from rmsrept where user_id=? order by rms_dl desc";
		 try { PreparedStatement pstmt = conn.prepareStatement(sql);
		 	pstmt.setString(1, user_id); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입 
		 	rs =pstmt.executeQuery(); 
		 	if(rs.next()) { return rs.getString(1); } 
		 }catch (Exception e) { 
		 e.printStackTrace(); } return ""; //데이터베이스 오류 
	 }
	
	
	//RMSREPT 데이터 조회하기 (update, bbsUpdate, ...) //금주 차주 구분
	public ArrayList<rmsrept> getRmsOne(String rms_dl, String user_id, String rms_div){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select * from (select * from rmsrept where rms_dl=? and user_id=?) r where r.rms_div=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
	            pstmt.setString(2, user_id);
	            pstmt.setString(3, rms_div); //금주, 또는 차주 조회
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_job(rs.getString(4));
	        	 rms.setRms_con(rs.getString(5));
	        	 rms.setRms_str(rs.getString(6));
	        	 rms.setRms_tar(rs.getString(7));
	        	 rms.setRms_end(rs.getString(8));
	        	 rms.setRms_div(rs.getString(9));
	        	 rms.setRms_sign(rs.getString(10));
	        	 rms.setRms_time(rs.getString(11));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// 같은 날짜에 보고된 주간보고가 있는지 확인 (bbsDeadline을 사용해 rms에 저장되어 있는지 확인)
	public String getOverlap(String rms_dl,String user_id) {
		String sql = "select rms_dl from rmsrept where rms_dl = ? and user_id = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, rms_dl); //첫번째 '?'에 매개변수로 받아온 'userID'를 대입
			pstmt.setString(2, user_id);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				return rs.getString(1);
			}
		}catch (Exception e) {
			e.printStackTrace();
		}
		return ""; //데이터베이스 오류
	}
	
	
	//RMSREPT 작성하기 (insert)
	public int writeRms(String rms_sign, String user_id, String rms_dl, String rms_title, String rms_job, String rms_con, String rms_str, String rms_tar, String rms_end, String rms_div, java.sql.Timestamp date) {
		String sql = "insert into rmsrept values(?,?,?,?,?,?,?,?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, rms_title);
			pstmt.setString(4, rms_job);
			pstmt.setString(5, rms_con);
			pstmt.setString(6, rms_str);
			pstmt.setString(7, rms_tar);
			pstmt.setString(8, rms_end);
			pstmt.setString(9, rms_div);
			pstmt.setString(10, rms_sign);
			pstmt.setTimestamp(11, date);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
		}
	
	
	//RMSREPT  제거하기 (delete)
	public int Rmsdelete(String user_id, String rms_dl, String rms_div) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rmsrept where user_id = ? and rms_dl = ? and rms_div = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, rms_div);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	
	//RMSREPT  제거하기 (rms_sign을 조건으로 검색) (delete)
	public int RmsdeleteSign(String user_id, String rms_dl, String rms_sign) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rmsrept where user_id = ? and rms_dl = ? and rms_sign = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, rms_sign);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	
	//RMSEDPS erp 권한관리 작성하기 (insert)
	public int write_erp(String user_id, String rms_dl, String e_date, String e_user, String e_text, String e_authority, String e_division) {
		String sql = "insert into rmsedps values(?,?,?,?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, e_date);
			pstmt.setString(4, e_user);
			pstmt.setString(5, e_text);
			pstmt.setString(6, e_authority);
			pstmt.setString(7, e_division);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//RMSEDPS erp 권한관리 제거하기 (delete)
	public int edelete(String user_id, String rms_dl) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from rmsedps where user_id = ? and rms_dl = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
		
	
	//RMSEDPS erp 검색하기 + user_id (select) 
	public ArrayList<rmsedps> geterp(String rms_dl){//특정한 리스트를 받아서 반환
	      ArrayList<rmsedps> list = new ArrayList<rmsedps>();
	      String SQL ="select * from rmsedps where rms_dl=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsedps rms = new rmsedps();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setErp_date(rs.getString(3));
	        	 rms.setErp_user(rs.getString(4));
	        	 rms.setErp_text(rs.getString(5));
	        	 rms.setErp_anum(rs.getString(6));
	        	 rms.setErp_div(rs.getString(7));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	//RMSEDPS erp 검색하기 (select)
	public ArrayList<rmsedps> geterpData(String rms_dl){//특정한 리스트를 받아서 반환
	      ArrayList<rmsedps> list = new ArrayList<rmsedps>();
	      String SQL ="select * from rmsedps where rms_dl=?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsedps rms = new rmsedps();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setErp_date(rs.getString(3));
	        	 rms.setErp_user(rs.getString(4));
	        	 rms.setErp_text(rs.getString(5));
	        	 rms.setErp_anum(rs.getString(6));
	        	 rms.setErp_div(rs.getString(7));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	//RMSREPT 데이터 조회하기 (USER_FD를 통해 찾아낸 USER_ID) bbsRk.jsp => rms_sign = 승인 or 마감  << full 조회 (limit XX) >>
	public ArrayList<rmsrept> getRmsRkfull(String rms_dl, String[] plist){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select distinct r.user_id, rms_dl, rms_title, rms_sign, rms_time from (select * from rmsrept where rms_dl=? and (";
	      		for(int i=0; i<plist.length; i++) {
	      			if(i < plist.length-1) {
	      				SQL += "user_id='"+plist[i].trim()+"' or ";
	      			}else {
	      				SQL += "user_id='"+plist[i].trim()+"'";
	      			}
	      		}
	      		SQL += ")) r inner join rmsuser u on r.user_id = u.user_id where rms_sign='승인' or rms_sign='마감' order by u.user_name";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	//RMSREPT 데이터 조회하기 (USER_FD를 통해 찾아낸 USER_ID) bbsRk.jsp => rms_sign = 승인 or 마감  << full 조회 (limit XX) >>
	public ArrayList<rmsrept> getRmsRkAll(String rms_dl, String[] plist, String rms_div){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select r.user_id, rms_dl, rms_title, rms_job, rms_con, rms_str, rms_tar, rms_end, rms_div, rms_sign, rms_time from (select * from rmsrept where rms_dl=? and (";
	      		for(int i=0; i<plist.length; i++) {
	      			if(i < plist.length-1) {
	      				SQL += "user_id='"+plist[i].trim()+"' or ";
	      			}else {
	      				SQL += "user_id='"+plist[i].trim()+"'";
	      			}
	      		}
	      		SQL += ")) r inner join rmsuser u on r.user_id = u.user_id where (rms_sign='승인' or rms_sign='마감') and rms_div = ? order by u.user_name, r.rms_job";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
	            pstmt.setString(2, rms_div);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_job(rs.getString(4));
	        	 rms.setRms_con(rs.getString(5));
	        	 rms.setRms_str(rs.getString(6));
	        	 rms.setRms_tar(rs.getString(7));
	        	 rms.setRms_end(rs.getString(8));
	        	 rms.setRms_div(rs.getString(9));
	        	 rms.setRms_sign(rs.getString(10));
	        	 rms.setRms_time(rs.getString(11));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	//RMSREPT 데이터 조회하기 (USER_FD를 통해 찾아낸 USER_ID) bbsRk.jsp => rms_sign = 승인 or 마감
	public ArrayList<rmsrept> getRmsRk(String rms_dl, String[] plist, int pageNumber, int maxNumber){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL ="select distinct r.user_id, rms_dl, rms_title, rms_sign, rms_time from (select * from rmsrept where rms_dl=? and (";
	      		for(int i=0; i<plist.length; i++) {
	      			if(i < plist.length-1) {
	      				SQL += "user_id='"+plist[i].trim()+"' or ";
	      			}else {
	      				SQL += "user_id='"+plist[i].trim()+"'";
	      			}
	      		}
	      		SQL += ")) r left join rmsuser u on r.user_id = u.user_id where rms_sign='승인' or rms_sign='마감' order by u.user_name limit ?,? ";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
	            pstmt.setInt(2, (pageNumber-1)*10);
	            pstmt.setInt(3, maxNumber);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// RMSREPT - 승인 또는 마감됨 보고 목록을 불러옴. (목록보기) (sign) //distinct, 승인 or 마감
	public ArrayList<rmsrept> getAllRms_dl(){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL =" select distinct rms_dl from rmsrept where rms_sign='승인' or rms_sign='마감' order by rms_dl desc";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setRms_dl(rs.getString(1));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// PPTXRMS - 데이터가 저장되었는지 확인한다
	public int getPptxRms(String rms_dl, String user_id) {
		String sql = "select rms_dl from pptxrms where rms_dl=? and user_id=?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,  rms_dl);
			pstmt.setString(2,  user_id);
			rs = pstmt.executeQuery();
			if(rs.next()) {
				if(rs.getString(1) != null || !rs.getString(1).isEmpty()) {
					return 1;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return 0; //작성된 기록이 없음!
	}
	
	
	//PPTXRMS - 데이터 저장하기
	public int PptxRmsWrite(String user_id, String rms_dl, String rms_title, String rms_mgrs, String rms_con, String rms_str, String rms_tar, String rms_end, String rms_div, String rms_sign) {
		String sql = "insert into pptxrms values(?,?,?,?,?,?,?,?,?,?)";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			pstmt.setString(3, rms_title);
			pstmt.setString(4, rms_mgrs);
			pstmt.setString(5, rms_con);
			pstmt.setString(6, rms_str);
			pstmt.setString(7, rms_tar);
			pstmt.setString(8, rms_end);
			pstmt.setString(9, rms_div);
			pstmt.setString(10, rms_sign);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류
	}
	
	
	//PPTXRMS  제거하기 (delete) - signOnupdateAction.jsp - PL
	public int pptxdelete(String user_id, String rms_dl) {
		//실제 데이터 또한 삭제한다.
		String sql = "delete from pptxrms where user_id = ? and rms_dl = ?";
		try {
			PreparedStatement pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setString(2, rms_dl);
			return pstmt.executeUpdate();
		}catch (Exception e) {
			e.printStackTrace();
		}
		return -1; //데이터베이스 오류 
	}
	
	
	// PPTXRMS 조회하기, 저장된 내용을 불러와 형태 보여주기(pptx) //signOnReportRk.jsp
	public ArrayList<pptxrms> getPptxRmsData(String rms_dl, String user_id, String rms_div){//특정한 리스트를 받아서 반환
	      ArrayList<pptxrms> list = new ArrayList<pptxrms>();
	      String SQL ="select * from pptxrms where rms_dl=? and user_id=? and rms_div = ?";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setString(1, rms_dl);
	            pstmt.setString(2, user_id);
	            pstmt.setString(3, rms_div);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 pptxrms rms = new pptxrms();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_mgrs(rs.getString(4));
	        	 rms.setRms_con(rs.getString(5));
	        	 rms.setRms_str(rs.getString(6));
	        	 rms.setRms_tar(rs.getString(7));
	        	 rms.setRms_end(rs.getString(8));
	        	 rms.setRms_div(rs.getString(9));
	        	 rms.setRms_sign(rs.getString(10));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	   }
	
	
	// RMSREPT -[관리자] bbsAdmin -> searchbbsRk.jsp로 검색하는 기능
	public ArrayList<rmsrept> getRmsAdminSearch(int pageNumber, String searchField, String searchText){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL =" select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from"
	      		+ " rmsrept where "+searchField.trim()+" like '%"+searchText.trim()+"%' order by rms_dl desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setInt(1, (pageNumber-1)*10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	}
	
	
	// RMSREPT -[관리자] bbsAdmin -> searchbbsRk.jsp로 검색하는 기능
	public ArrayList<rmsrept> getRmsAdminSearch(int pageNumber, String[] searchText){//특정한 리스트를 받아서 반환
	      ArrayList<rmsrept> list = new ArrayList<rmsrept>();
	      String SQL =" select distinct user_id, rms_dl, rms_title, rms_sign, rms_time from rmsrept where";
	      	for(int i=0; i<searchText.length; i++) {
	      		if(i < searchText.length -1) {
	      			SQL += "user_id='"+searchText[i].trim()+"'"+" or ";
	      		} else {
	      			SQL += "user_id='"+searchText[i].trim()+"'";
	      		}
	      	}
	      SQL += "order by rms_dl desc limit ?,10";
	      try {
	            PreparedStatement pstmt=conn.prepareStatement(SQL);
	            pstmt.setInt(1, (pageNumber-1)*10);
				rs=pstmt.executeQuery();//select
	         while(rs.next()) {
	        	 rmsrept rms = new rmsrept();
	        	 rms.setUser_id(rs.getString(1));
	        	 rms.setRms_dl(rs.getString(2));
	        	 rms.setRms_title(rs.getString(3));
	        	 rms.setRms_sign(rs.getString(4));
	        	 rms.setRms_time(rs.getString(5));
	            list.add(rms);
	         }         
	      } catch(Exception e) {
	         e.printStackTrace();
	      }
	      return list;
	}
	
	
	public void WritePptx(String rms_dl, String id) {
		//메인 페이지로 이동했을 때 세션에 값이 담겨있는지 체크
		RmsuserDAO userDAO = new RmsuserDAO(); //사용자 정보
		RmsreptDAO rms = new RmsreptDAO(); //주간보고 목록
	
			String name = userDAO.getName(id);	
		
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

		
					//2. rms 데이터 생성
						//데이터 불러오기 (this, next)
						//금주
						ArrayList<rmsrept> rms_this = rms.getRmsOne(rms_dl, id,"T");
						//차주
						ArrayList<rmsrept> rms_next = rms.getRmsOne(rms_dl, id,"N");
						
						//데이터 가공하기
						String bbsManager = workSet + name;
						String bbsContent = "";
						String bbsStart = "";
						String bbsTarget = "";
						String bbsEnd = "";
						String bbsNContent = "";
						String bbsNStart = "";
						String bbsNTarget = "";
						//금주 업무 (this)
						for(int j=0; j < rms_this.size(); j++) {
							//content, ncotent의 줄바꿈 개수만큼 추가함
							int anum = 0; //rms_this.get(j).getRms_con().split(System.lineSeparator()).length-1;
							String content = "";
								if(rms_this.get(j).getRms_con().indexOf('-') > -1 &&  rms_this.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
									if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
										content = rms_this.get(j).getRms_con() + System.lineSeparator();
									} else {
										content = "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
									}
								} else {
									if(rms_this.get(j).getRms_job().contains("시스템") || rms_this.get(j).getRms_job().contains("기타")) {
										content = "- "+rms_this.get(j).getRms_con() + System.lineSeparator();
									} else {
										content = "- ["+rms_this.get(j).getRms_job()+"] "+ rms_this.get(j).getRms_con() + System.lineSeparator();
									}
								}
								//content 가공하기
								content = content.replaceAll(System.lineSeparator(),""); //줄바꿈 제거
								//바이트로 자르기 (70 - 3과 1) (130 - 4와 2)
								int maxlen = 85;
								float curlen = 0;
								float addlen = 0;
								StringBuilder contentBuilder = new StringBuilder();
								String[] text = content.split(""); 
								for(int i=0; i < content.length(); i++) {								
									if(text[i].matches(".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*")) {
										//한글
										curlen += 3;
										addlen = 3;
									} else if(text[i].matches("^[a-zA-Z0-9]*$")) {
										if(Character.isLowerCase(text[i].charAt(0))) {
											//소문자라면,
											curlen += 1.5;
											addlen = (float) 1.5;
										} else {
											//대문자 라면 ...
											curlen += 2;
											addlen = 2;
										}
									}else if(text[i].matches("^[0-9]+$")){
										//숫자
										curlen += 1.6;
										addlen = (float) 1.6;
									} else {
										if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'") || text[i].contains("\"") || text[i].contains("[") || text[i].contains("]") || text[i].contains("/") || text[i].contains("(") || text[i].contains(")") || text[i].contains("-")) {
											//공백
											curlen += 1;
											addlen = 1;
										} else {
											//기타 특수문자
											curlen += 2;
											addlen = 2;
										}
									}
									if(Math.floor(curlen) >= maxlen ) { 
										contentBuilder.append(text[i]);
										if(i < content.length() -1) {
											if(text[i+1].contains(" ") || text[i+1].contains(",") || text[i+1].contains("'") || text[i+1].contains("\"") || text[i+1].contains("[") || text[i+1].contains("]") || text[i+1].contains("/") || text[i+1].contains("(") || text[i+1].contains(")") || text[i+1].contains("-")) {	
												contentBuilder.append(text[i+1]);
												i++;
											} else {
												contentBuilder.append(System.lineSeparator());
												contentBuilder.append("  ");
											}
										} 	
										curlen = 0;
										curlen += 2; //공백 2개 넣기
										curlen += addlen; 
									} else {
										contentBuilder.append(text[i]);
									}
								}
								
								if(j < rms_this.size()-1) {
								 	bbsContent += contentBuilder.toString() + System.lineSeparator();
								} else {
									bbsContent += contentBuilder.toString();
								}
								 anum = contentBuilder.toString().split(System.lineSeparator()).length-1;
								 bbsStart += rms_this.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
								 if(rms_this.get(j).getRms_tar() == null || rms_this.get(j).getRms_tar().isEmpty()) {
								 	bbsTarget += "[보류]" + System.lineSeparator();
								 } else {
									 if(rms_this.get(j).getRms_tar().length() > 5) {
									 bbsTarget += rms_this.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
									 }else {
										 bbsTarget += "[보류]" + System.lineSeparator();
									 }
								 }
								 bbsEnd += rms_this.get(j).getRms_end() + System.lineSeparator();
								
								 for(int k=0;k < anum; k ++) {
									 bbsStart +=System.lineSeparator();
									 bbsTarget +=System.lineSeparator();
									 bbsEnd +=System.lineSeparator();
								 }
						}
						//차주 (next)
						for(int j=0; j < rms_next.size(); j++) {
							//content, ncotent의 줄바꿈 개수만큼 추가함
							String content = "";
								if(rms_next.get(j).getRms_con().indexOf('-') > -1 &&  rms_next.get(j).getRms_con().indexOf('-') < 2) { // - 가 있는 경우,
									if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
										content = rms_next.get(j).getRms_con() + System.lineSeparator();
									} else {
										content = "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con().replaceFirst("-", "") + System.lineSeparator();
									}
								} else {
									if(rms_next.get(j).getRms_job().contains("시스템") || rms_next.get(j).getRms_job().contains("기타")) {
										content = "- "+rms_next.get(j).getRms_con() + System.lineSeparator();
									} else {
										content = "- ["+rms_next.get(j).getRms_job()+"] "+ rms_next.get(j).getRms_con() + System.lineSeparator();
									}
								}  
								//content 가공하기
								content = content.replaceAll(System.lineSeparator(),""); //줄바꿈 제거
								//바이트로 자르기 (70 - 3과 1) (130 - 4와 2)
								int maxlen = 85;
								float curlen = 0;
								float addlen = 0;
								StringBuilder contentBuilder = new StringBuilder();
								String[] text = content.split(""); 
								for(int i=0; i < content.length(); i++) {								
									if(text[i].matches(".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*")) {
										//한글
										curlen += 3;
										addlen = 3;
									} else if(text[i].matches("^[a-zA-Z0-9]*$")) {
										if(Character.isLowerCase(text[i].charAt(0))) {
											//소문자라면,
											curlen += 1.5;
											addlen = (float) 1.5;
										} else {
											//대문자 라면 ...
											curlen += 2;
											addlen = 2;
										}
									}else if(text[i].matches("^[0-9]+$")){
										//숫자
										curlen += 1.6;
										addlen = (float) 1.6;
									} else {
										if(text[i].contains(" ") || text[i].contains(",") || text[i].contains("'") || text[i].contains("\"") || text[i].contains("[") || text[i].contains("]") || text[i].contains("/") || text[i].contains("(") || text[i].contains(")") || text[i].contains("-")) {
											//공백
											curlen += 1;
											addlen = 1;
										} else {
											//기타 특수문자
											curlen += 2;
											addlen = 2;
										}
									}
									if(Math.floor(curlen) >= maxlen ) { 
										contentBuilder.append(text[i]);
										if(i < content.length() -1) {
											if(text[i+1].contains(" ") || text[i+1].contains(",") || text[i+1].contains("'") || text[i+1].contains("\"") || text[i+1].contains("[") || text[i+1].contains("]") || text[i+1].contains("/") || text[i+1].contains("(") || text[i+1].contains(")") || text[i+1].contains("-")) {	
												contentBuilder.append(text[i+1]);
												i++;
											} else {
												contentBuilder.append(System.lineSeparator());
												contentBuilder.append("  ");
											}
										} 
										curlen = 0;
										curlen += 2; //공백 2개 넣기
										curlen += addlen; 
									} else {
										contentBuilder.append(text[i]);
									}
								}
								
								if(j < rms_this.size()-1) {
								 	bbsNContent += contentBuilder.toString() + System.lineSeparator();
								} else {
									bbsNContent += contentBuilder.toString();
								}
								 int nnum = contentBuilder.toString().split(System.lineSeparator()).length-1;
								 bbsNStart += rms_next.get(j).getRms_str().substring(5).replace("-","/") + System.lineSeparator();
								 if(rms_next.get(j).getRms_tar() == null || rms_next.get(j).getRms_tar().isEmpty()) {
									 bbsNTarget += "[보류]" + System.lineSeparator();
								 } else {
									 if(rms_next.get(j).getRms_tar().length() > 5) {
									 bbsNTarget += rms_next.get(j).getRms_tar().substring(5).replace("-","/") + System.lineSeparator();
									 } else {
										 bbsNTarget += "[보류]" + System.lineSeparator();
									 }
								 }
								 for (int h=0; h < nnum; h++) {
									 bbsNStart += System.lineSeparator();
									 bbsNTarget += System.lineSeparator();
								 }
						}

					//3. 데이터 저장하기
					if(rms_this.size() != 0) {
						if(!rms_this.get(0).getRms_sign().equals("미승인")) {
						rms.PptxRmsWrite(id, rms_dl, rms_this.get(0).getRms_title(), bbsManager, bbsContent, bbsStart, bbsTarget, bbsEnd, "T", rms_this.get(0).getRms_sign());
						rms.PptxRmsWrite(id, rms_dl, rms_next.get(0).getRms_title(), bbsManager, bbsNContent, bbsNStart, bbsNTarget, null, "N", rms_next.get(0).getRms_sign());
						}
					}
	

	}
	

}
