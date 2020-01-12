// @author Rahul Thapa

import java.util.ArrayList;

public class Person {
	
	String name;
	ArrayList<String> children;
	ArrayList<String> parent;
	ArrayList<String> spouse;
	
	
	public Person(String name) {
		this.name =  name;
		parent = new ArrayList<String>();
		children = new ArrayList<String>();
		spouse = new ArrayList<String>();
	}
	
	public String getName() { return name; }
	
	public void putSpouse(String sName) { spouse.add(sName); }
	
	public void putChildren(String cName) { children.add(cName); }
	
	public void putParent(String pName) { parent.add(pName); }
	
	public boolean containsChildren(String cName) { return children.contains(cName); }
	
	public boolean containsSpouse(String sName) { return spouse.contains(sName); }
	
	public boolean containsParent(String pName) { return parent.contains(pName); }
	
	public ArrayList<String> getChildren() { return children; }
	
	public ArrayList<String> getSpouse() { return spouse; }
	
	public ArrayList<String> getParent() { return parent; }
	
}
