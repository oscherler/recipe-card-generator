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
		
		if( $block->t === 'BulletList' && in_array( 'ingredients', $currentClasses ) )
		{
			$rows = [];
			
			foreach( $block->c as $item_blocks )
			{
				foreach( $item_blocks as $item_block )
				{
					list( $quantity, $ingredient ) = unitise( $item_block );
					$rows[] = [ [ $quantity ], [ $ingredient ] ];
				}
			}
			
			$block = table(
				[ '', '' ],
				$rows
			);
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

function unitise( $block )
{
	$content = $block->c;
	$quantity = clone( $block );
	
	if( count( $content ) > 2 && $content[0]->t === 'Emph' && $content[1]->t === 'Space' )
	{
		$quantity->c = $content[0]->c;
		$block->c = array_slice( $content, 2 );
	}
	else
	{
		$quantity->c = [];
	}
	
	return [ $quantity, $block ];
}

function table( $headers, $rows )
{
	$cols = count( $headers );
	$aligns = array_fill( 0, $cols, [ 't' => 'AlignDefault' ] );
	$widths = array_fill( 0, $cols, 0 );
	$headers = array_map( function( $header ) {
		return [
			[
				't' => 'Plain',
				'c' => [ [ 't' => 'Str', 'c' => $header ] ]
			]
		];
	}, $headers );
	
	$c = [
		[], # caption
		$aligns,
		$widths,
		$headers,
		$rows
	];
	
	return [
		't' => 'Table',
		'c' => $c
	];
}

function walk( $x, $action, $format, $meta, $userData )
{
	if( is_array( $x ) )
	{
		$array = array();
		foreach( $x as $item )
		{
			if( is_object( $item ) && isset( $item->t ) && isset( $item->c ) )
			{
				$res = $action( $item->t, $item->c, $format, $meta, $userData );
				if( is_null( $res ) )
				{
					$array[] = walk( $item, $action, $format, $meta, $userData );
				}
				elseif( is_array( $res ) )
				{
					foreach( $res as $z )
					{
						$array[] = walk( $z, $action, $format, $meta, $userData );
					}
				}
				elseif( is_object( $res ) )
				{
					$array[] = walk( $res, $action, $format, $meta, $userData );
				}
				else
				{
					$obj = clone $item;
					$obj->c = "$res";
					$array[] = $obj;
				}
			}
			else
			{
				$array[] = walk( $item, $action, $format, $meta, $userData );
			}
		}

		return $array;
	}
	elseif( is_object( $x ) )
	{
		$obj = clone $x;
		foreach( get_object_vars( $x ) as $k => $v )
		{
			$obj->{ $k } = walk( $v, $action, $format, $meta, $userData );
		}

		return $obj;
	}
	else
	{
		return $x;
	}
}
