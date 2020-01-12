// @author Rahul Thapa

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Scanner;

public class main {

	public static void main(String[] args) {
		
		FamilyTreeMap familyMap = new FamilyTreeMap();
		Scanner fileScan = new Scanner(System.in);
		String line;
//		Scanner fileScan = null;
//		String line;
//		ArrayList<String> temp = new ArrayList<String>();
		
		
//		try {
//			fileScan = new Scanner(new File("TestData4.txt"));
//		} catch (FileNotFoundException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
		String[] lineArray;
		while (fileScan.hasNext()) {
			line = fileScan.nextLine();
			lineArray = line.split(" ");
			
			if (lineArray[0].equals("E")) {
				if (lineArray.length == 3) {
					familyMap.addTwoPeople(lineArray[1], lineArray[2]);
				}
				else if (lineArray.length == 4) {
					familyMap.addThreePeople(lineArray[1], lineArray[2], lineArray[3]);
				}	
			}
			else if (lineArray[0].equals("X")) {
				System.out.println();
				System.out.println(line);
				boolean flag = false;
				if (lineArray.length == 4) {
					flag = familyMap.hasRelation(lineArray[1], lineArray[2], -1, lineArray[3]);
				}
				else if (lineArray.length == 5) {
					flag = familyMap.hasRelation(lineArray[1], lineArray[2], 
							Integer.parseInt(lineArray[3]), lineArray[4]);
				}
				if (flag == true) System.out.println("Yes");
				else System.out.println("No");
			}
			else if (lineArray[0].equals("W")) {
				System.out.println();
				System.out.println(line);
				if (lineArray.length == 3) {
					familyMap.relationList(lineArray[1], -1, lineArray[2]);
				}
				else if (lineArray.length == 4) {
					familyMap.relationList(lineArray[1],
							Integer.parseInt(lineArray[2]), lineArray[3]);
				}
			}
		}
	}
}
