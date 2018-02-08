package jk.kamoru.flayon.web.security;

public enum Role {

	ADMIN("Admin"), USER("User");
	
	private String name;

	Role(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}
	
}
