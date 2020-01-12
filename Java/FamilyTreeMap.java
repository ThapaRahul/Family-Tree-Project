// @author Rahul Thapa

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public class FamilyTreeMap {
	
	HashMap<String, Person> seenPeople;
	
	
	FamilyTreeMap() { 
		seenPeople = new HashMap<String, Person>(); 
	}
	
	public void addMember(Person name) { 
		seenPeople.put(name.getName(), name);
	}
	
	public void addTwoPeople(String p1, String p2) {
		if (!seenPeople.containsKey(p1)) {
			Person parent1 = new Person(p1);
			addMember(parent1);
		}
		
		if (!seenPeople.containsKey(p2)) {
			Person parent2 = new Person(p2);
			addMember(parent2);
		}
		
		seenPeople.get(p1).putSpouse(p2);
		seenPeople.get(p2).putSpouse(p1);
	}
	
	public void addThreePeople(String p1, String p2, String c1) {
		if (!seenPeople.containsKey(p1)) {
			Person parent1 = new Person(p1);
			addMember(parent1);
		}
		
		if (!seenPeople.containsKey(p2)) {
			Person parent2 = new Person(p2);
			addMember(parent2);
		}
		
		if (!seenPeople.containsKey(c1)) {
			Person children1 = new Person(c1);
			addMember(children1);
		}
		
		seenPeople.get(p1).putSpouse(p2);
		seenPeople.get(p1).putChildren(c1);
		
		seenPeople.get(p2).putSpouse(p1);
		seenPeople.get(p2).putChildren(c1);
		
		seenPeople.get(c1).putParent(p1);
		seenPeople.get(c1).putParent(p2);
	}
	
	public boolean hasRelation(String p1, String relation, int cNum, String p2) {
		if (relation.equals("child")) return hasChildRelation(p1, relation, p2);
		else if (relation.equals("sibling")) return hasSiblingRelation(p1, relation, p2);
		else if (relation.equals("ancestor")) return hasAncestorRelation(p1, relation, p2);
		else if (relation.equals("cousin")) return hasCousinRelation(p1, relation, cNum, p2);
		else if (relation.equals("unrelated")) return isUnrelated(p1, relation, p2);
		return false;
	}
	
	private boolean hasChildRelation(String p1, String relation, String p2) {
		return seenPeople.get(p2).containsChildren(p1);
	}
	
	private boolean hasSiblingRelation(String p1, String relation, String p2) {
		ArrayList<String> parentList = seenPeople.get(p1).getParent();
		boolean flag1 = seenPeople.get(parentList.get(0)).containsChildren(p2);
		boolean flag2 = seenPeople.get(parentList.get(0)).containsChildren(p2);
		return flag1 || flag2;
	}
	
	private boolean hasAncestorRelation(String p1, String relation, String p2) {
		HashSet<String> ancestors = recAncestorRelation(p2);
		return ancestors.contains(p1);
		
	}
	
	private String findCommonAncestor(Set<String> ancestorsSet1, Set<String> ancestorsSet2) {
		for (String s: ancestorsSet1) {
			if (ancestorsSet2.contains(s)) {
				return s;
			}
		}
		return "";
	}

	private boolean hasCousinRelation(String p1, String relation, int cNum, String p2) {
		if (p1.equals(p2)) {
			return false;
		}
		if (hasAncestorRelation(p1, relation, p2) || hasAncestorRelation(p2, relation, p1)) {
			return false;
		}
		HashMap<String, Integer> tempMap1 = new HashMap<String, Integer>();
		HashMap<String, Integer> tempMap2 = new HashMap<String, Integer>();
		HashMap<String, Integer> ancestorsWeightMap1 = recAncestorWeight(tempMap1, p1, 0);
		HashMap<String, Integer> ancestorsWeightMap2 = recAncestorWeight(tempMap2, p2, 0);
		String commonAncestor = findCommonAncestor(ancestorsWeightMap1.keySet(),
												   ancestorsWeightMap2.keySet());
		if (commonAncestor.equals("")) {
			return false;
		}
		return (Math.min(ancestorsWeightMap1.get(commonAncestor), ancestorsWeightMap2.get(commonAncestor))-1) == cNum;
	}
	
	private HashMap<String, Integer> recAncestorWeight(HashMap<String, Integer> ancestorMap, String p1, int depth) {
		if (!(seenPeople.get(p1).getParent().size() == 0)) {
			ancestorMap.put(seenPeople.get(p1).getParent().get(0), depth + 1);
			ancestorMap.put(seenPeople.get(p1).getParent().get(1), depth + 1);
			recAncestorWeight(ancestorMap, seenPeople.get(p1).getParent().get(0), depth+1);
			recAncestorWeight(ancestorMap, seenPeople.get(p1).getParent().get(1), depth+1);
		}
		return ancestorMap;
	}
	
	private boolean isUnrelated(String p1, String relation, String p2) {
		HashSet<String> ancestorList1 = recAncestorRelation(p1);
		HashSet<String> ancestorList2 = recAncestorRelation(p2);
		
		if (ancestorList1.contains(p2) || ancestorList2.contains(p1)) {
			return false;
		}
		
		for (String s: ancestorList1) {
			if (ancestorList2.contains(s)) {
				return false;
			}
		}
		return true;
	}
	
	public void relationList(String relation, int cNum, String p1) {
		if (relation.equals("child")) childRelationList(relation, p1);
		else if (relation.equals("sibling")) siblingRelationList(relation, p1);
		else if (relation.equals("ancestor")) ancestorRelationList(relation, p1);
		else if (relation.equals("cousin")) cousinRelationList(relation, cNum, p1);
		else if (relation.equals("unrelated")) unrelatedList(relation, p1);
	}
	
	private void childRelationList(String relation, String p1) {
		ArrayList<String> childrens = seenPeople.get(p1).getChildren();
		Collections.sort(childrens);
		for (String s: childrens) {
			System.out.println(s);
		}	
	}
	
	private void siblingRelationList(String relation, String p1) {
		ArrayList<String> parentList = seenPeople.get(p1).getParent();
		ArrayList<String> siblingList = new ArrayList<String>();
		for (String p: parentList) {
			for (String c: seenPeople.get(p).getChildren()) {
				if (!siblingList.contains(c) && !c.equals(p1)) siblingList.add(c);
			}
		}
		Collections.sort(siblingList);
		for (String s: siblingList) {
			System.out.println(s);
		}
	}
	
	private void ancestorRelationList(String relation, String p1) {
		HashSet<String> ancestors = recAncestorRelation(p1);
		ArrayList<String> ancestorsList = new ArrayList<>(ancestors);
		Collections.sort(ancestorsList);
		for (String s: ancestorsList) {
			System.out.println(s);
		}
		
	}
	
	private HashSet<String> recAncestorRelation(String p1) {
		HashSet<String> ancestors = new HashSet<String>();
		if (!(seenPeople.get(p1).getParent().isEmpty())) {
			ancestors.addAll(seenPeople.get(p1).getParent());
			ancestors.addAll(recAncestorRelation(seenPeople.get(p1).getParent().get(0)));
			ancestors.addAll(recAncestorRelation(seenPeople.get(p1).getParent().get(1)));
		}
		return ancestors;
	}
	
	private void cousinRelationList(String relation, int cNum, String p1) {
		ArrayList<String> cousins = new ArrayList<String>();
		for (String s: seenPeople.keySet()) {
			if (hasCousinRelation(s, relation, cNum, p1)) {
				cousins.add(s);
			}
		}
		
		Collections.sort(cousins);
		for (String s: cousins) {
			System.out.println(s);
		}	
	}
	
	private void unrelatedList(String relation, String p1) {
		ArrayList<String> unrelated = new ArrayList<String>();
		for (String s: seenPeople.keySet()) {
			if (isUnrelated(s, relation, p1)) {
				unrelated.add(s);
			}
		}
		Collections.sort(unrelated);
		for (String s: unrelated) {
			System.out.println(s);
		}
	}
	
	public HashMap<String, Person> seenPeopleMap() {
		return seenPeople;
	}
	
	public String toString() {
		return seenPeople.toString();
	}
}
