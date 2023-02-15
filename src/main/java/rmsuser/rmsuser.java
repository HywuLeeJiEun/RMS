package rmsuser;

public class rmsuser {
	private String user_id; //사용자 아이디
	private String user_pwd; //사용자 비밀번호
	private String user_name; //사용자 성함
	private String user_rk; //사용자 직급
	private String user_em; //사용자 이메일 (비어있을 수도 있음!)
	private String user_au; //사용자 권한(일반/PL/관리자)
	private String user_fd; //사용자 담당 분야(WEB/ERP) (비어있는 경우, 담당 분야가 없음!)
	public String getUser_id() {
		return user_id;
	}
	public void setUser_id(String user_id) {
		this.user_id = user_id;
	}
	public String getUser_pwd() {
		return user_pwd;
	}
	public void setUser_pwd(String user_pwd) {
		this.user_pwd = user_pwd;
	}
	public String getUser_name() {
		return user_name;
	}
	public void setUser_name(String user_name) {
		this.user_name = user_name;
	}
	public String getUser_rk() {
		return user_rk;
	}
	public void setUser_rk(String user_rk) {
		this.user_rk = user_rk;
	}
	public String getUser_em() {
		return user_em;
	}
	public void setUser_em(String user_em) {
		this.user_em = user_em;
	}
	public String getUser_au() {
		return user_au;
	}
	public void setUser_au(String user_au) {
		this.user_au = user_au;
	}
	public String getUser_fd() {
		return user_fd;
	}
	public void setUser_fd(String user_fd) {
		this.user_fd = user_fd;
	}
	
	
}
