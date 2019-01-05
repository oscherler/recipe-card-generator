<?php

function var_error_log( $object=null ){
	ob_start();
	var_dump( $object );
	$contents = ob_get_contents();
	ob_end_clean();
	error_log( trim( $contents ) );
}

$doc = json_decode( file_get_contents('php://stdin') );

#var_error_log( $doc );

$altered = doc( $doc );

#var_error_log( $altered );

$json = json_encode( $altered, JSON_HEX_TAG | JSON_HEX_AMP | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE );
	
echo $json;

function doc( $doc )
{
	$currentSection = [];
	$currentClasses = [];
	$newDoc = [];	
	
	foreach( $doc->blocks as $block )
	{
		if( $block->t === 'Header' && $block->c[0] === 1 )
		{
			if( count( $currentSection ) > 0 )
			{
				$currentClasses[] = 'section';
				$newDoc[] = div( classes( $currentClasses ), $currentSection );
				$currentSection = [];
			}

			$currentClasses = $block->c[1][1];
			$block->c[1][1] = [];
		}
		
		$currentSection[] = $block;
	}
	
	if( count( $currentSection ) > 0 )
	{
		$currentClasses[] = 'section';
		$newDoc[] = div( classes( $currentClasses ), $currentSection );
		$currentSection = [];
	}

	$doc->blocks = $newDoc;

	return $doc;
}

function div( $attrs, $content )
{
	return [
		't' => 'Div',
		'c' => [
			$attrs,
			$content
		]
	];
}

function attrs( $id, $classes, $attrs )
{
	return [
		$id,
		$classes,
		$attrs
	];
}

function classes( $classes )
{
	return attrs( '', $classes, [] );
}
