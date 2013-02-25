<?php
// ToDo: rewrite to python
    
    
if (!isset($argv[1]))
{
	echo "Usage ".$argv[0]." filename.png\n\n";
	exit;
}
@mkdir("./ArtWork");

$filename=$argv[1];

$sizes=array(
	array(  57,   57, "DefaultIcon.png"),
	array( 114,  114, "DefaultIcon@2x.png"),
	array(  72,   72, "DefaultIcon~ipad.png"),
	array( 144,  144, "DefaultIcon@2x~ipad.png"),
	array(  29,   29, "Spotlight.png"),
	array(  58,   58, "Spotlight@2x.png"),
	array(  58,   58, "Settings~ipad@2x.png"),
	array( 100,  100, "Spotlight@2x~ipad.png"),
	array( 144,  144, "Default@2x~ipad.png"),
);

for ($i=0; $i < count($sizes); $i++)
{
	$w=$sizes[$i][0];
	$h=$sizes[$i][1];
	$name="./ArtWork/".$sizes[$i][2];
	$cmd = "convert \"$filename\" -strip -resize {$w}x{$h} -background transparent -compose Copy " .
				"-gravity center -extent {$w}x{$h} -quality 100 \"$name\"";
	echo $cmd."\n";
	system($cmd);
}
?>
