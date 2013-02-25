<?php

    // scan wiki list of world heritage data (names, country)
    // the country name is dangeling
    
    
$data=file("WorldHeritage.txt");

echo "DELETE FROM ZPROPOSEDWONDERS;\n";
$country=trim($data[0]);
$cnt=0;

for ($i=0; $i < count($data); $i++)
{
	$name=trim($data[$i]);
	if ($name=="")
	{
		$country=trim($data[$i-1]);
	}
	else if (trim($data[$i+1])!="")
	{
		$name=trim($data[$i]);
		$material = 'na';
		// some heuristics on the material 
		
		if (preg_match("/(park)|(reserve)|(nature)|(glacier)|(falls)|(hills)|(island)|(mount)|(landscape)|(valley)/iU",$name))
		{
			$material='mn'; // mother nature
		}
		else
            if (preg_match("/(reef)|(topics)|(fossil)|(wilder)|(coast)|(forest)/iU",$name))
            {
                $material='mn'; // mother nature
            }
            else
		if (preg_match("/(cathedral)|(castle)|(city)|(town)|(centre)|(palace)|(archaeo)|(tower)|(ruins)/iU",$name))
		{
			$material='st'; // stone
		}
		else
		if (preg_match("/(bridge)/iU",$name))
		{
			$material='mt'; // metal presumed...
		}
		$cnt++;
		$effort=(rand() % 10000)*50+100;
		
		// we did not normalize on $country, this should be done
		$country = sqlite_escape_string($country);
		$name = sqlite_escape_string($name);
        //if ($material != 'mn')
        {
			echo "INSERT INTO ZPROPOSEDWONDERS (Z_PK,Z_ENT,Z_OPT,ZINDEXWONDER,ZEFFORTESTIMATED,ZLOCATION,ZNAME,ZTYPE) ";
			echo "VALUES ($cnt,1,1,$cnt,$effort,'$country','$name','$material');\n";
        }
	}
}


?>