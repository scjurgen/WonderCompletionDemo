<?php
// ToDo: rewrite to python

if (!isset($argv[1]))
{
	echo "Usage ".$argv[0]." filename.png background\n\nbackground:i.e. white";
	exit;
}
@mkdir("./ArtWork");

$filename=$argv[1];
$background=$argv[2];

$sizes=array(
	array( 512,  512,   "iTunesArtwork.png"),
	array( 320,  480,   "Default.png"),
	array( 640,  960,   "Default@2x.png"),
	array( 640,  568*2, "Default-568h@2x.png"),
	array( 768, 1004,   "Default-Portrait~ipad.png"),
	array(1536, 2008,   "Default-Portrait@2x~ipad.png"),
	array(1024,  748,   "Default-Landscape~ipad.png"),
	array(2048, 1496,   "Default-Landscape@2x~ipad.png"),
	
);            

for ($i=0; $i < count($sizes); $i++)
{
	$w=$sizes[$i][0];
	$h=$sizes[$i][1];
	$name="./ArtWork/".$sizes[$i][2];
	// 100, 97
	$cmd = "convert \"$filename\" -strip -resize {$w}x{$h} -background $background -compose Copy " .
				"-gravity center -extent {$w}x{$h} -quality 100 \"$name\"";
	echo $cmd."\n";              
	// i think quality is not relevant...
	system($cmd);
}
?>
