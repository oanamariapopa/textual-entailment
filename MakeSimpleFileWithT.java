import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;

public class MakeSimpleFileWithT {
	public static void main(String args[]) throws IOException {

		BufferedReader br1 = new BufferedReader(new FileReader("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-sumarizat.txt"));
		BufferedReader br2 = new BufferedReader(new FileReader("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-nesumarizat.txt")); 
		PrintWriter writer = new PrintWriter("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-withT.xml", "UTF-8");
		Map<Integer,String> tMap = new HashMap<Integer, String>();
		Map<Integer,String> hMap = new HashMap<Integer, String>();
		Map<Integer,String> tMapNesumarizat = new HashMap<Integer, String>();
		String lineFile1 = "";
		String composeLineFile1 = "";
		boolean isBetweenT = false;
		int index = 0;
		int indexNesumarizat = 0;
		boolean tExist = false;
		boolean isBetweenPair = false;
		boolean endPair = false;
		
		String lineFile3 = " ";
		while ((lineFile3 = br2.readLine()) != null) {

			String tString = StringUtils.substringBetween(lineFile3, "<t>", "</t>");

			if (tString != null) {
				tMapNesumarizat.put(indexNesumarizat, tString);
				indexNesumarizat++;
			}
			
		}
		
		while ((lineFile1 = br1.readLine()) != null) {

			if (lineFile1.contains("<pair")) {
				isBetweenPair = true;
				tExist = false;
			}

			if ((lineFile1.contains("<t>") || isBetweenT) && isBetweenPair) {
				composeLineFile1 = composeLineFile1 + lineFile1;
				isBetweenT = true;
				tExist = true;
			}

			if (lineFile1.contains("</t>") && isBetweenPair) {
				composeLineFile1 = "";
				isBetweenT = false;
			}

			String hString = StringUtils.substringBetween(lineFile1, "<h>", "</h>");

			if (hString != null && isBetweenPair && !tExist) {
				writer.println("<t>" + tMapNesumarizat.get(index) + "</t>");
				writer.println("<h>" + hString + "</h>");
				continue;
			}

			if (lineFile1.contains("</pair>")) {
				isBetweenPair = false;
				endPair = true;
				index++;
			}
			writer.println(lineFile1);

		}
		writer.close();
	}
}
