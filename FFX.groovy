import ffx.Main

import org.apache.commons.io.IOUtils;
String pdb = "2jof.pdb"
    
try {
        System.out.print(" Downloading " + pdb + " ...");
        rcsb = "https://files.rcsb.org/download/";
        pb = new ProcessBuilder("wget", rcsb + pdb);
        proc = pb.start();
        proc.waitFor();
        System.out.println(" Done.");
        System.out.println(IOUtils.toString(proc.getInputStream()));
        System.out.println(IOUtils.toString(proc.getErrorStream()));
    } catch (Exception e) {
        System.out.println(" Exception downloading PDB file: " + e.toString());
    }

args = ["Energy", pdb]
Main.ffxScript(args)
