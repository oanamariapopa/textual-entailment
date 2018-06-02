import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.apache.commons.lang3.StringUtils;

public class MakeFile {
	public static void main(String args[]) throws IOException {

		BufferedReader br1 = new BufferedReader(new FileReader("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-sumarizat.txt"));
		BufferedReader br2 = new BufferedReader(new FileReader("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-nesumarizat.txt")); 
		PrintWriter writer = new PrintWriter("/home/oana/Dizertatie/Dizertatie/Workspace/SummarizationTool/src/text-inversat.xml", "UTF-8");
		List<String> tList = new ArrayList<String>();
		String lineFile1 = "";
		String composeLineFile1 = "";
		boolean isBetweenT = false;
		while (( lineFile1 = br1.readLine()) != null) {
			String tString = StringUtils.substringBetween(lineFile1,"<t>", "</t>");
			if (tString != null) {
			tList.add(lineFile1);
			continue;
			}
			if(lineFile1.contains("<t>") || isBetweenT ){
				composeLineFile1 = composeLineFile1 + lineFile1;
				isBetweenT = true;
			}
			if (lineFile1.contains("</t>")){
				tList.add(composeLineFile1);
				composeLineFile1 = "";
				isBetweenT = false;
			}
		}
		String lineFile2 = " ";
		int count = 0;
		while ((lineFile2 = br2.readLine()) != null) {
			String tString = StringUtils.substringBetween(lineFile2,"<h>", "</h>");
			if (tString == null) {
				writer.println(lineFile2);
			}
			if (tString != null) {
				writer.println(tList.get(count++).replaceAll("t>", "h>"));
			}
		}
		writer.close();
	}
}
